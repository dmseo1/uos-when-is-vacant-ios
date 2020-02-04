//
//  Statics.swift
//  wiv
//
//  Created by 서동민 on 15/10/2019.
//  Copyright © 2019 서동민. All rights reserved.
//

import Foundation
import UIKit

class Statics {
    static var basicURL = "http://52.78.173.4/wiv/"
    static let internetConnectionFailedDialog = UIAlertController(title: "알림", message: "인터넷 연결이 불안정하여 어플리케이션을 실행할 수 없습니다. 어플리케이션 종료 후 다시 실행해주세요.", preferredStyle: .alert)
    static var maxWatchingSubjects = 3
    static let isDebugMode = false
    
    //로딩 화면 보여주기
    static func showLoading(at context : UIViewController, animated : Bool, completion : (() -> Void)?) {
        let storyboard = context.storyboard!
        let loadingView = storyboard.instantiateViewController(withIdentifier: "Loading")
        loadingView.modalPresentationStyle = .overFullScreen
        loadingView.modalTransitionStyle = .crossDissolve
        context.present(loadingView, animated: animated, completion: completion)
    }
    
    //경고 메시지 띄우기
    static func makeAlertMessage(at context : UIViewController, title : String, message : String) {
        let dialog = UIAlertController(title : title, message : message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        dialog.addAction(action)
        context.present(dialog, animated: true, completion: nil)
    }
    
    //단일 JSON 처리
    static func getDictionaryFromJSON(jsonString : String, tag : String) -> [String:String] {
        let jsonObject = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as! [String:[String:String]]
        return jsonObject[tag]!
    }
    
    //JSON 배열 처리
    static func getArrayDictionaryFromJSON(jsonString : String, tag : String) -> [[String:String]] {
        let jsonObject = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
            as! [String: [[String:String]]]
        return jsonObject[tag]!
    }
    
    //디버그 프린트 제어
    static func debugPrint(_ tag: String, _ content : String) {
        if isDebugMode {
            print("\(tag) : \(content)")
        }
    }
}

