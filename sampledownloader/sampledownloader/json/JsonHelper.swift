//
//  JsonHelper.swift
//  JsonHelper
//
//  Created by Anna Zharkova on 19.08.2021.
//

import Foundation

class JsonHelper {
    static let shared = JsonHelper()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func decodeData<T:Codable>(response: HTTPURLResponse, data: Data, _ type: T.Type)->Result<T,Error> {
        let code = response.statusCode
        let string = String(data: data, encoding: .utf8)
        print(string)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        if code >= 200 && code < 400 {
            do {
            let result = try decoder.decode(T.self, from: data)
                return Result.success(result)
            }
            catch {
                return Result.failure(error)
            }
        } else {
            return Result.failure(ErrorResponse(type: .tech))
        }
    }
    
    func decodeData<T:Codable>(data: Data, _ type: T.Type)->T? {
        let string = String(data: data, encoding: .utf8)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
            do {
            let result = try decoder.decode(T.self, from: data)
            return result
            }
            catch {
                return nil
            }
    }
    
    
    func encodeData<T:Codable>(item: T)->Data? {
        do {
        return  try? encoder.encode(item)
        } catch {return nil }
    }
}
