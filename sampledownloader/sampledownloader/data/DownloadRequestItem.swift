//
//  DownloadRequestItem.swift
//  DownloadRequestItem
//
//  Created by Anna Zharkova on 22.08.2021.
//

import Foundation


enum Method : String{
    case get = "GET"
    case post = "POST"
}


struct DownloadRequestItem : Equatable{
    static func == (lhs: DownloadRequestItem, rhs: DownloadRequestItem) -> Bool {
        return lhs.url == rhs.url && lhs.method == rhs.method && lhs.taskId == rhs.taskId
    }
    
    let url: String
    let method: String
    let parameters: [String: Any]
    let completionHandler: CompletionHandler?
    
    var taskId: Int = 0
}
