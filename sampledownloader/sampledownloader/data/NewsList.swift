//
//  NewsList.swift
//  NewsList
//
//  Created by Anna Zharkova on 11.08.2021.
//

import Foundation
// MARK: Model for news list
class NewsList: Codable,Identifiable {
    var status: String?
    var total: Int = 0
    var articles: [NewsItem]?

    enum CodingKeys : String, CodingKey {
        case total = "totalResults"
        case articles = "articles"
        case status = "status"
    }

}
