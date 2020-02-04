//
//  HttpConnector.swift
//  wiv
//
//  Created by 서동민 on 15/10/2019.
//  Copyright © 2019 서동민. All rights reserved.
//

import Foundation

class HttpConnector {
    var taskCompleted : ((String) -> Void)?
    var taskFailed : (() -> Void)?
    func getData(url : String, parameters : String) {
        if let fullURL = URL(string : "\(Statics.basicURL)\(url)") {
            var request = URLRequest(url : fullURL)
            request.httpMethod = "POST"
            request.httpBody = parameters.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    //print("error = \(error!)")
                    self.taskFailed?()
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("response = \(response!)")
                    self.taskFailed?()
                }
                if let result = String(data: data, encoding: .utf8) {
                    Statics.debugPrint("fetchedData", result)
                    self.taskCompleted?(result)
                }
            })
            task.resume()
        }
    }
}

class HttpConnectorOthers {
    var taskFailed : (() -> Void)?
    var taskCompleted : ((String) -> Void)?
    func getData(url : String, parameters : String) {
        if let fullURL = URL(string : "\(url)") {
            var request = URLRequest(url : fullURL)
            request.httpMethod = "POST"
            request.httpBody = parameters.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    //print("error = \(error!)")
                    self.taskFailed?()
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("response = \(response!)")
                    self.taskFailed?()
                    
                }
                if let result = String(data: data, encoding: .utf8) {
                    Statics.debugPrint("fetchedData", result)
                    self.taskCompleted?(result)
                }
            })
            task.resume()
        }
    }
}

protocol UIModifyAvailableListener {
    var taskCompleted : ((_ : String) -> Void)? { get set }
    var taskFailed : (() -> Void)? { get set }
}
