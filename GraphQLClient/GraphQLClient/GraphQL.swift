//
//  GraphQL.swift
//  KanalD_iphone
//
//  Created by Serkan Kayaduman on 14.12.2022.
//  Copyright © 2022 Demiroren Teknoloji. All rights reserved.
//

import UIKit

public class GraphQL: NSObject {
    
    var baseUrl: URL
    var authorization: [String: String]? = nil
    var timeout: TimeInterval = 20
    
    public init(baseUrl: URL, authorization: [String: String]? = nil) {
        self.baseUrl = baseUrl
        self.authorization = authorization
        super.init()
    }
    
    private func readFile(fileName:String) -> String? {
        let bundle = Bundle(for: GraphQL.self)
        
        if fileName.contains(".") {
            let fileArray = fileName.split(separator: ".")
            if  fileArray.count > 0, let ext = fileArray.last {
                
                let name = String(fileName.prefix(fileName.count - ext.count - 1))
                
                if let path = bundle.path(forResource: name, ofType: String(ext)) {
                    let text = try? String(contentsOf: URL(fileURLWithPath: path))
                    return text
                }
            }
        }
        return nil
    }
    
    private func prepareRequest(queryFileName:String, parameters:[String:Any]?) throws -> NSMutableURLRequest? {
        guard let query = self.readFile(fileName: queryFileName) else { return nil }
        
        let graphqlData = [ "query" : query, "variables" : parameters ?? [String:Any]()] as [String : Any]
        
        let httpBody = try JSONSerialization.data(withJSONObject: graphqlData)
        
        let request = NSMutableURLRequest(url: self.baseUrl)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = self.timeout
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("\(httpBody.count)", forHTTPHeaderField: "Content-Length")
        
        if let author = self.authorization {
            for key:String in author.keys {
                if let value = author[key] {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
        }
        request.httpBody = httpBody
        
        return request
    }
    
    public func fetchData(queryFileName:String, parameters:[String:Any]?, result:((Data?, String?)->Void)?) {
        do {
            if let request = try self.prepareRequest(queryFileName: queryFileName, parameters: parameters) {
                self.fetching(request: request) { [weak self] data, error in
                    self?.sendResult(result: result, error: error, data: data as? Data)
                }
            } else {
                result?(nil, "Could not read Graph QL file. Plase check the file name with the file.")
            }
        } catch let exception {
            result?(nil, "GraphQL file cannot parse json : \(exception)")
        }
    }
    
    public func fetchJson(queryFileName:String, parameters:[String:Any]?, result:((Any?, String?)->Void)?) {
        self.fetchData(queryFileName: queryFileName, parameters: parameters) {data, error in
            if let e = error {
                result?(nil, e)
            } else if let dt = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: dt)
                    
                    if let json = jsonData as? [String: Any] {
                        var graphQLError : String? = nil
                        
                        if let errors = json["errors"] as? [[String:Any]], errors.count > 0 {
                            if let err = errors[0]["message"] as? String {
                                if let loc = errors[0]["locations"] as? [[String:Any]], loc.count > 0 {
                                    graphQLError = "\(err) (line:\(loc[0]["line"] ?? ""))"
                                } else {
                                    graphQLError = err
                                }
                            }
                        }
                        
                        if let graphQLData = json["data"] {
                            result?(graphQLData, graphQLError)
                        } else {
                            result?(json, graphQLError)
                        }
                    } else {
                        result?(jsonData, nil)
                    }
                } catch let exception {
                    result?(nil, "The server data cannot parse json : \(exception)")
                }
            }
        }
    }
    
    
    private func sendResult<T>(result:((T?, String?)->Void)?, error:String? = nil, data:T? = nil) {
        DispatchQueue.main.async {
            if let res = result {
                res(data, error)
            }
        }
    }
    
    
    //MARK: - base connection method
    private func fetching(request:NSMutableURLRequest, result:@escaping((Any?, String?)->Void), workingCount:Int = 0) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {responseData, httpResponse, error in
            if let e = error {
                result(nil, e.localizedDescription)
            } else if let http = httpResponse as? HTTPURLResponse, let response = responseData {
                
                if http.statusCode >= 200 && http.statusCode <= 299 {
                    if response.count > 0 {
                        result(response, nil)
                    } else {
                        result(nil, "The service return empty result.")
                    }
                } else if http.statusCode >= 300 && http.statusCode <= 399 {
                    self.redirectUrl(request: request, response: http, result: result, redirectQuantity: workingCount)
                } else {
                    result(nil, "Status Code: \(http.statusCode) \n\(String(data: response, encoding: .utf8) ?? "")")
                }
            } else {
                result(nil, "The data can not be taken from server.")
            }
        }
        task.resume()
    }
    
    private func redirectUrl(request:NSMutableURLRequest, response:HTTPURLResponse, result:@escaping((Any?, String?)->Void), redirectQuantity:Int) {
        if redirectQuantity < 7 {
            let location = response.allHeaderFields.first { (key, value) in
                return key.description == "Location"
            }
            if let newUrl = location?.value as? String {
                request.url = URL(string: newUrl)
                self.fetching(request: request, result: result, workingCount: redirectQuantity + 1)
            } else {
                result(nil, "The data can not be taken from server.")
            }
        } else {
            result(nil, "The data can not be taken from server. (Redirect Quantity : \(redirectQuantity)")
        }
    }
    
}


