//
//  Request.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

class Request : NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession,
                             task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest,
                  completionHandler: @escaping (URLRequest?) -> Void) {
        debugPrint(response)
    }
}
