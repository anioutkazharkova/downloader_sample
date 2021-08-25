//
//  FileBackgroundDownloader.swift
//  FileBackgroundDownloader
//
//  Created by Anna Zharkova on 23.08.2021.
//

import Foundation

class FileBackgroundDownloader :NSObject {
    static let shared = FileBackgroundDownloader()
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var backgroundConfig: URLSessionConfiguration = {
        var config = URLSessionConfiguration.background(withIdentifier: "background_session")
        config.allowsCellularAccess = true //разрешаем не только Wi-Fi
        config.waitsForConnectivity = true //ожидаем сеть, на случай прерываний
        config.shouldUseExtendedBackgroundIdleMode = true //поддерживаем сеть в фоне
        config.sessionSendsLaunchEvents = true //разрешаем запуск App после загрузки
        
        return config
    }()
    
    private lazy var urlSession: URLSession? = {
        return URLSession(configuration:backgroundConfig, delegate: self, delegateQueue: queue)
    }()
    
    var backgroundCompletionHandler: (() -> Void)? = nil
    
    private var requestsQueue = [DownloadRequestItem]()
    private var loadedData:Data? = nil
    
    private var currentDownloadTask: URLSessionDownloadTask? = nil
    
    func backgroundDownloadRequest(path: String, method: Method, parameters: [String:Any] = [:], completion: @escaping CompletionHandler) {
        guard let url = URL(string: path) else {
            return
        }
        var item = DownloadRequestItem(url: path, method: method.rawValue, parameters: parameters,completionHandler: completion)
        
        let request = URLRequest(url: url)
        // self.startInBackTask {
        if let loadedData = self.loadedData {
            self.currentDownloadTask = self.urlSession?.downloadTask(withResumeData: loadedData)
        } else {
            self.currentDownloadTask = self.urlSession?.downloadTask(with: request)
        }
        item.taskId = self.currentDownloadTask?.taskIdentifier ?? 0
        self.requestsQueue.append(item)
        //self.currentDownloadTask?.countOfBytesClientExpectsToSend = 200
        //self.currentDownloadTask?.countOfBytesClientExpectsToReceive = 500 * 1024
        self.currentDownloadTask?.resume()
        //  }
    }
    
    func cancel() {
        self.currentDownloadTask?.cancel(byProducingResumeData: { downloadedData in
            self.loadedData = downloadedData
        })
    }
    
    func request(id: Int)->DownloadRequestItem? {
        return self.requestsQueue.filter{$0.taskId == id}.first
    }
    
    func deleteRequest(id: Int) {
        if let item = self.requestsQueue.filter({$0.taskId == id}).first,
        let index = self.requestsQueue.firstIndex(of: item) {
            self.requestsQueue.remove(at: index)
        }
    }
    
}

extension FileBackgroundDownloader : URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}

extension FileBackgroundDownloader : URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //save some file
        deleteRequest(id: downloadTask.taskIdentifier)
    }
}
