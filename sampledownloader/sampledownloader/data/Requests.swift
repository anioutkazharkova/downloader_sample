//
//  Requests.swift
//  Requests
//
//  Created by Anna Zharkova on 19.08.2021.
//

import Foundation

enum Requests {
    case everythingRaw
    case everything(query: String)
    case top
    case cats
    
    var value: String {
        switch self {
        case .everythingRaw:
            return "everything?q="
        case .everything(let query):
            return "everything?q=\(query)"
        case .top:
            return "top-headlines?language=en"
        case .cats:
            return "gallery/search/?q_all=cats&q_type=jpg"
        }
    }
}

struct RequestConfig {
    let baseUrl: String
    let headers: [String:Any]
}

extension Requests {
    func config()->RequestConfig? {
        switch self {
        case .everything(_), .top:
            return RequestConfig(baseUrl: "https://newsapi.org/v2/",
                                 headers: ["X-Api-Key":"5b86b7593caa4f009fea285cc74129e2"])
        default:
            return nil
        }
    }
}
