//
//  UISubjectCell.swift
//  wiv
//
//  Created by 서동민 on 2019/10/19.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit
import Firebase

class UISubjectCell: UITableViewCell {
    
    var context : UIViewController? = nil
    var subjectInfo : SubjectElement? = nil
    
    
    @IBOutlet weak var lblSubjectNameClassDiv: UILabel!
    @IBOutlet weak var lblGradeDivCredit: UILabel!
    @IBOutlet weak var lblProfessorLocation: UILabel!
    @IBOutlet weak var lblCurrentMax: UILabel!
    
    
    @IBAction func onClickBtnEnroll(_ sender: UIButton) {
       
        //등록에 필요한 정보 로드
        let subscribingSubjectCode = "\(self.subjectInfo!.subjectNo)-\(self.subjectInfo!.classDiv)"
        let subscribingSubjectName = "\(self.subjectInfo!.subjectNm)"
        var subscribingSubjectCodes = UserDefaults.standard.array(forKey:"subscribing_subject_codes")! as! [String]
        var subscribingSubjectNames = UserDefaults.standard.array(forKey:"subscribing_subject_names")! as! [String]
        
        //중복 등록이 아닌지 검사
        for i : Int in 0..<subscribingSubjectCodes.count {
            if subscribingSubjectCodes[i] == subscribingSubjectCode {
                Statics.makeAlertMessage(at: self.context!, title: "알림", message: "이미 알림 설정한 교과목입니다.")
                return
            }
        }
        
        //TODO: 최대 알림 등록 개수를 초과하는지 검사
        
        
        
        //로딩 화면 불러오기
        
        Statics.showLoading(at: self.context!, animated: true, completion: {
            //구독설정
            
            Messaging.messaging().subscribe(toTopic: "\(subscribingSubjectCode)-ios") { error in
                
                //에러 처리
                if error != nil {
                    print("에러가 났습니다")
                    //로딩 창 제거
                    self.context!.dismiss(animated: true, completion: nil)
                    //알림 메시지 띄우기
                    Statics.makeAlertMessage(at: self.context!, title: "알림", message: "과목 알림 설정 도중에 오류가 발생하였습니다. 안정적인 네트워크 환경에서 이용해주세요.")
                    return
                }
                
                //테스트 메시지
                print("subscribed: \(subscribingSubjectCode)")
                
                //알림 설정 과목 저장 변수에 저장
                subscribingSubjectCodes.insert(subscribingSubjectCode, at: 0)
                subscribingSubjectNames.insert(subscribingSubjectName, at: 0)
                UserDefaults.standard.set(subscribingSubjectCodes, forKey: "subscribing_subject_codes")
                UserDefaults.standard.set(subscribingSubjectNames, forKey: "subscribing_subject_names")
                
                //로딩 창 제거
                self.context!.dismiss(animated: true, completion: nil)
                
                //알림 메시지 띄우기
                Statics.makeAlertMessage(at: self.context!, title: "알림", message: "\(subscribingSubjectName) (\(subscribingSubjectCode)분반) 과목의 알림 설정이 완료되었습니다.")
                
            }
        })
        
        
        
        
        
        
    }
    
    
    
}

extension GyoyangViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell") as! UISubjectCell
        let e = self.searchResult[indexPath.row]
        cell.context = self
        cell.subjectInfo = e
        cell.lblSubjectNameClassDiv.text = "\(e.subjectNm) (\(e.subjectNo)-\(e.classDiv)분반)"
        cell.lblGradeDivCredit.text = "\(e.shyr)학년·\(e.subjectDiv)(\(e.subjectDiv2))·\(e.credit)학점"
        cell.lblProfessorLocation.text = "\(e.profNm) 교수님·\(e.classNm)"
        cell.lblCurrentMax.text = "현재/정원: \(e.tlsnCount)/\(e.tlsnLimitCount)"
        
        return cell
    }
}

extension GyoyangViewController : UITableViewDelegate {
    
}

extension JeongongViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell") as! UISubjectCell
        
        let e = self.searchResult[indexPath.row]
        cell.context = self
        cell.subjectInfo = e
        cell.lblSubjectNameClassDiv.text = "\(e.subjectNm) (\(e.subjectNo)-\(e.classDiv)분반)"
        cell.lblGradeDivCredit.text = "\(e.shyr)학년·\(e.subjectDiv)·\(e.credit)학점"
        cell.lblProfessorLocation.text = "\(e.profNm) 교수님·\(e.classNm)"
        cell.lblCurrentMax.text = "현재/정원: \(e.tlsnCount)/\(e.tlsnLimitCount)"
        
        return cell
        
    }
}

extension JeongongViewController : UITableViewDelegate {
    
}

