//
//  UIWatchingSubjectCell.swift
//  wiv
//
//  Created by 서동민 on 2019/10/17.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit
import Firebase

class UIWatchingSubjectCell: UITableViewCell {
    
    var context : UIViewController? = nil
    
    var watchingSubjectCode : String = ""
    
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var subjectInfo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBAction func onClickBtnDelete(_ sender: UIButton) {
        Statics.showLoading(at: context!, animated: true, completion: {
            Messaging.messaging().unsubscribe(fromTopic: "\(self.watchingSubjectCode)-ios") { error in
                //에러 처리
                if error != nil {
                    //로딩 창 제거
                    self.context!.dismiss(animated: true, completion: nil)
                    //알림 메시지 띄우기
                    Statics.makeAlertMessage(at: self.context!, title: "알림", message: "과목 알림 설정 해제 중 오류가 발생하였습니다. 안정적인 네트워크 환경 하에서 이용해주세요.")
                    return
                }
                
                
                var subscribingSubjectCodes = UserDefaults.standard.array(forKey:"subscribing_subject_codes")! as! [String]
                var subscribingSubjectNames = UserDefaults.standard.array(forKey:"subscribing_subject_names")! as! [String]
                
                
                //테스트 메시지
                print("unsubscribed: \(self.watchingSubjectCode)")
                
                var watchingSubjectName = "";
                //알림 설정 과목 저장 변수에 저장
                for i : Int in 0..<(subscribingSubjectCodes.count) {
                    if subscribingSubjectCodes[i] == self.watchingSubjectCode {
                        watchingSubjectName = subscribingSubjectNames[i]
                        subscribingSubjectCodes.remove(at: i)
                        subscribingSubjectNames.remove(at: i)
                        break
                    }
                }
                
                UserDefaults.standard.set(subscribingSubjectCodes, forKey: "subscribing_subject_codes")
                UserDefaults.standard.set(subscribingSubjectNames, forKey: "subscribing_subject_names")
                
                //로딩 창 제거
                self.context!.dismiss(animated: true, completion: nil)
                
                //알림 메시지 띄우기
                Statics.makeAlertMessage(at: self.context!, title: "알림", message: "\(watchingSubjectName) (\(self.watchingSubjectCode)분반) 과목의 알림 해제가 완료되었습니다.")
                
                self.context!.viewWillAppear(true)
            }
        })
    }
    
}

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.watchingSubjectNames.count } // 각 row 마다 데이터 세팅.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 첫 번째 인자로 등록한 identifier, cell은 as 키워드로 앞서 만든 custom cell class화 해준다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchingSubjectCell") as! UIWatchingSubjectCell
        cell.context = self
        cell.watchingSubjectCode = watchingSubjectCodes[indexPath.row]
        cell.subjectName.text = watchingSubjectNames[indexPath.row]
        cell.subjectInfo.text = watchingSubjectCodes[indexPath.row]
        return cell
    }
}

extension MainViewController : UITableViewDelegate {
    
}
