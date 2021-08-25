//
//  Saver+Type.swift
//  Saver+Type
//
//  Created by Anna Zharkova on 19.08.2021.
//

import Foundation


extension DownloadRequestItem {
    func getType()->Requests? {
        if self.url.contains(Requests.top.value) {
            return Requests.top
        }
        if self.url.contains(Requests.everythingRaw.value) {
            return Requests.everythingRaw
        }
        return nil
    }
    
    func decodeForType(data: Data)->Any? {
        if self.url.contains(Requests.top.value) || self.url.contains( Requests.everythingRaw.value){
          return  JsonHelper.shared.decodeData(data: data, NewsList.self)
        }
        return data
    }
    
    func urlRequest()->URLRequest? {
        guard let url = URL(string: self.url) else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = method
        let type  = getType()
        let headers = type?.config()?.headers ?? [String:Any]()
        for header in headers {
            request.addValue(header.value as! String, forHTTPHeaderField: header.key)
        }
        return request
    }
}
