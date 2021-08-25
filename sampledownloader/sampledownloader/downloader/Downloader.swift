//
//  Downloader.swift
//  Downloader
//
//  Created by Anna Zharkova on 23.08.2021.
//

import Foundation
import UIKit
class Downloader : NSObject {
    var taskID: UIBackgroundTaskIdentifier? = nil
    static let shared = Downloader()
    
    private var isBackground: Bool = false
    
    private var requestsQueue = [DownloadRequestItem]()
    
    private let foregroundConfig = URLSessionConfiguration.default
    
    private lazy var backgroundConfig: URLSessionConfiguration = {
        var config = URLSessionConfiguration.background(withIdentifier: "background_session")
        config.allowsCellularAccess = true //разрешаем не только Wi-Fi
        config.waitsForConnectivity = true //ожидаем сеть, на случай прерываний
        config.shouldUseExtendedBackgroundIdleMode = true //поддерживаем сеть в фоне
        config.sessionSendsLaunchEvents = true //разрешаем запуск App после загрузки
        
        return config
    }()
    
    private var urlSession: URLSession? = nil
    
    private var currentTask: URLSessionTask? = nil
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var backgroundCompletionHandler: (() -> Void)? = nil
    
    func changeBackground(background: Bool) {
        self.isBackground = background
        
        resetSession()
        if isBackground {
            self.urlSession = URLSession(configuration:backgroundConfig, delegate: self, delegateQueue: queue)
        } else {
            self.urlSession = URLSession(configuration: foregroundConfig, delegate: self, delegateQueue: nil)
        }
    }
    
    func backgroundRequest(path: String, method: Method, parameters: [String:Any] = [:], completion: @escaping CompletionHandler) {
        guard let url = URL(string: path) else {
            return
        }
        var item = DownloadRequestItem(url: path, method: method.rawValue, parameters: parameters,completionHandler: completion)
        let request = URLRequest(url: url)
        
        self.startInBackTask {
        self.currentTask = self.urlSession?.dataTask(with: request)
        item.taskId = self.currentTask?.taskIdentifier ?? 0
        
        self.requestsQueue.append(item)
            self.currentTask?.resume()
        }
    }
    
    private func foregroundRequest(path: String, method: Method, parameters: [String:Any] = [:],
                                   completion: @escaping CompletionHandler) {
        guard let url = URL(string: path) else {
            DispatchQueue.main.async {
                completion(.failure(ErrorResponse(type: .other)))
            }
            return
        }
        var item = DownloadRequestItem(url: path, method: method.rawValue, parameters: parameters,completionHandler: completion)
       
        let request = URLRequest(url: url)
        self.startInBackTask {
            self.currentTask = self.urlSession?.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let item = self.request(url: request.url?.path ?? "", method: request.httpMethod ?? Method.get.rawValue) {
                        let content = item.decodeForType(data: data)
                        
                        DispatchQueue.main.async {
                            item.completionHandler?(.success(content))
                            self.deleteRequest(id: item.taskId)
                        }
                    }
                }
                else  {
                    DispatchQueue.main.async {
                        if let request = self.request(url: request.url?.path ?? "", method: request.httpMethod ?? Method.get.rawValue) {
                            request.completionHandler?(.failure(ErrorResponse(type: .network)))
                            self.requestsQueue.removeFirst()
                        }
                    }
                }
            }
            item.taskId = self.currentTask?.taskIdentifier ?? 0
            self.requestsQueue.append(item)
            self.currentTask?.resume()
        }
    }
    
    private func resetSession() {
        cancel()
    }
    
    private func cancel(){
        self.currentTask?.cancel()
        self.urlSession?.getAllTasks(completionHandler: { tasks in
            tasks.forEach{
                $0.cancel()
            }
        })
    }
    
    func request(id: Int)->DownloadRequestItem? {
        return self.requestsQueue.filter{$0.taskId == id}.first
    }
    
    func request(url: String, method: String)->DownloadRequestItem? {
        return self.requestsQueue.filter{$0.url == url && $0.method == method}.first
    }
    
    func deleteRequest(id: Int) {
        if let item = self.requestsQueue.filter({$0.taskId == id}).first,
        let index = self.requestsQueue.firstIndex(of: item) {
            self.requestsQueue.remove(at: index)
        }
    }
}

extension Downloader {
    func startInBackTask(completion: @escaping ()->Void) {
        self.taskID = UIApplication.shared.beginBackgroundTask(withName:"back.task") { [weak self] in
            guard let self = self else {return}
            self.endTask()
        }
        completion()
    }
    
    private func endTask() {
        if (taskID != nil  && taskID != .invalid) {
            UIApplication.shared.endBackgroundTask(self.taskID!)
            self.taskID = .invalid
        }
    }
}

extension Downloader : URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}

extension Downloader : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if let request = request(id: dataTask.taskIdentifier), !dataTask.progress.isCancelled {
            let content = request.decodeForType(data: data)
            request.completionHandler?(.success(content))
            
            self.deleteRequest(id: dataTask.taskIdentifier)
            self.endTask()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if  let request = request(id: task.taskIdentifier), !task.progress.isCancelled {
            request.completionHandler?(.failure(error!))
            
            self.deleteRequest(id: task.taskIdentifier)
            self.endTask()
        }
    }
}
