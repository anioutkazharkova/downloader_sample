//
//  ImageBackgroundManager.swift
//  ImageBackgroundManager
//
//  Created by Anna Zharkova on 21.08.2021.
//

import Foundation

class ImageBackgroundManager {
    static let shared = ImageBackgroundManager()
    
    var itemsInMemory = [String:Data]()
    private var currentIndex = 0
    let semaphore = DispatchSemaphore(value: 1)
    
    let urls = ["https://i.imgur.com/LLVV3Qb.jpg", "https://i.imgur.com/m2X8ESA.jpg", "https://i.imgur.com/8KVm9pZ.jpg", "https://i.imgur.com/4Kbvc3s.jpg", " https://i.imgur.com/bdp0nWa.jpg", "https://i.imgur.com/p7Xb9wu.jpg", "https://i.imgur.com/3MpdyB2.jpg", "https://i.imgur.com/OasGB4m.jpg"
    ]
    
    func processDownload() {
        semaphore.wait()
        let currentUrl = urls[currentIndex]
        FileBackgroundDownloader.shared.backgroundRequest(path: currentUrl, method: .get) { [weak self] (result:DataRequestResult) in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                self.itemsInMemory[currentUrl] = data as? Data
                print("result: \(currentUrl)")
              
                if self.currentIndex + 1 < self.urls.count {
                    self.currentIndex += 1
                    self.semaphore.signal()
                    
                    self.processDownload()
                    
                }else {
                    self.semaphore.signal()
                    print("All done")
                }
            default:
                self.semaphore.signal()
                break
            }
        }
    }
    
}
