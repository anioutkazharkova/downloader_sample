//
//  NewsItem.swift
//  NewsItem
//
//  Created by Anna Zharkova on 11.08.2021.
//

import Foundation
class NewsItem: Codable,Identifiable {
    
    let uuid = UUID().uuidString
    
    var source: Source?
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: Date? = nil
    var content: String?
    var favorite: Bool = false
    enum  CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
    
}

extension NewsItem: Equatable {
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        return  lhs.url == rhs.url
    }
}

class Source:Codable, Equatable {
    var id: String?
    var name: String?
    
    init() {}
    enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    static func == (lhs: Source, rhs: Source) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
