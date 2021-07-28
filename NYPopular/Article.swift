//
//  Article.swift
//  NYPopular
//
//  Created by Mohamed Anas on 7/28/21.
//

import Foundation

struct Article: Codable{
    var url: String
    var date: String
    var title: String
    var byLine: String
    
    struct ArticleKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            return nil
        }
        
        static let url = ArticleKeys(stringValue: "url")
        static let date = ArticleKeys(stringValue: "published_date")
        static let title = ArticleKeys(stringValue: "title")
        static let byLine = ArticleKeys(stringValue: "byline")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ArticleKeys.self)
        
        url = try container.decodeIfPresent(String.self, forKey: ArticleKeys.url!) ?? ""
        date = try container.decodeIfPresent(String.self, forKey: ArticleKeys.date!) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: ArticleKeys.title!) ?? ""
        byLine = try container.decodeIfPresent(String.self, forKey: ArticleKeys.byLine!) ?? ""
    }
}
