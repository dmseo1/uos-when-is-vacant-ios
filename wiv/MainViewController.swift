//
//  MainViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/17.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MainViewController: UIViewController {
    let storage = UserDefaults.standard
    lazy var watchingSubjectCodes : [String] = {
        return (storage.array(forKey: "subscribing_subject_codes") ?? []) as [String]
    }()
    lazy var watchingSubjectNames : [String] = {
        return (storage.array(forKey: "subscribing_subject_names") ?? []) as [String]
    }()
    
    
    @IBOutlet weak var imgNotice: UIImageView!
    @IBOutlet weak var lblNoticeTitle: UILabel!
    @IBOutlet weak var btnSettings: UIImageView!
    
    @IBOutlet weak var imgWatching: UIImageView!
    @IBOutlet weak var lblWatchingSubjects: UILabel!
    @IBOutlet weak var btnDeleteAllWatchingSubjects: UIButton!
    
    
    @IBOutlet weak var watchingSubjectList: UITableView!
    @IBOutlet weak var btnSearchSubject: UIButton!
    
    @IBOutlet weak var lblNoWatchingSubject: UILabel!
    
    var deleteWatchingSubjectsLock : NSLock {
        return NSLock()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgNotice.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_notice.png"))
        btnSettings.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_settings.png"))
        imgWatching.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_ws_noti.png"))
        
        //공지 기본값 처리
        lblNoticeTitle.text = UserDefaults.standard.string(forKey: "app_notice_title") ?? "등록된 공지가 없습니다"
        let lblNoticeTitleGesture = UITapGestureRecognizer(target: self, action: #selector(lblNoticeTitleClicked(_:)))
        imgNotice.addGestureRecognizer(lblNoticeTitleGesture)
        lblNoticeTitle.addGestureRecognizer(lblNoticeTitleGesture)
        
        //설정 버튼 누름 처리
        let btnSettingsGesture = UITapGestureRecognizer(target: self, action:
            #selector(btnSettingsClicked(_:)))
        btnSettings.addGestureRecognizer(btnSettingsGesture)
        
        Statics.showLoading(at: self, animated: true, completion: {
            
            let myHttpConnector = HttpConnector()
            myHttpConnector.taskCompleted = { result in
                let appInfo = Statics.getDictionaryFromJSON(jsonString: result, tag: "app_info")
                let appSettings = UserDefaults.standard
                for (key, value) in appInfo {
                    appSettings.set(value, forKey: key)
                }
                
                //앱 기초 정보 업데이트
                Statics.basicURL = appSettings.string(forKey: "basic_url")!
                DispatchQueue.main.async {
                    self.lblWatchingSubjects.text = "알림 과목(\(self.watchingSubjectNames.count)/\(appSettings.string(forKey: "num_max_watching_subjects") ?? "3"))"
                    
                }
                
                //필터, 알림 설정 과목 저장변수 초기화
                if !self.storage.bool(forKey: "is_not_first_executed") {
                    self.storage.set(true, forKey: "gyoyang_div_gs_enabled")
                    self.storage.set(true, forKey: "gyoyang_div_gp_enabled")
                    self.storage.set(true, forKey: "gyoyang_div_gj_enabled")
                    self.storage.set(true, forKey: "gyoyang_div_ro_enabled")
                    
                    self.storage.set(true, forKey: "jeongong_div_js_enabled")
                    self.storage.set(true, forKey: "jeongong_div_gp_enabled")
                    
                    let subscribingSubjectCodes : [String] = []
                    let subscribingSubjectNames : [String] = []
                    self.storage.set(subscribingSubjectCodes, forKey: "subscribing_subject_codes")
                    self.storage.set(subscribingSubjectNames, forKey: "subscribing_subject_names")
                    
                    self.storage.set(true, forKey: "is_not_first_executed")
                    
                }
                
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            myHttpConnector.taskFailed = {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        let action = UIAlertAction(title: "확인", style: .default, handler: { action in
                            Statics.showLoading(at: self, animated: true, completion: nil)
                        })
                        Statics.internetConnectionFailedDialog.addAction(action)
                        self.present(Statics.internetConnectionFailedDialog, animated: true, completion: nil)
                    })
                }
            }
            myHttpConnector.getData(url: "fetch_app_info.php", parameters: "secCode=onlythiswivappcancallthisfetchappvariablesphpfile!&token=\(UserDefaults.standard.string(forKey:"token") ?? "FIRST")")
        })
        
        
        self.navigationItem.title = " "
        watchingSubjectList.backgroundColor = UIColor.black.withAlphaComponent(0)
        watchingSubjectList.dataSource = self
        watchingSubjectList.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        //공지사항 가져오기
       
        let fetchNotice = HttpConnector()
        fetchNotice.taskCompleted = { result in
            DispatchQueue.main.async {
                //결과물 저장
                let dict = Statics.getDictionaryFromJSON(jsonString: result, tag: "notice_info")
                
                //제목
                let title = dict["title"]
                let content = dict["content"]
                
                //제목을 레이블에 표시
                self.lblNoticeTitle.text = title
                
                //제목과 내용을 앱 데이터에 저장
                UserDefaults.standard.set(title, forKey: "app_notice_title")
                UserDefaults.standard.set(content, forKey: "app_notice_content")
            }
        }
        fetchNotice.taskFailed = {}
        fetchNotice.getData(url: "fetch_notice.php", parameters: "secCode=onlythiswivappcancallthisfetchnoticephpfile!")
       
        
        
        //왓칭 과목 현황 업데이트
        watchingSubjectCodes = (UserDefaults.standard.array(forKey: "subscribing_subject_codes") ?? []) as [String]
        watchingSubjectNames = (UserDefaults.standard.array(forKey: "subscribing_subject_names") ?? []) as [String]
        watchingSubjectList.reloadData()
        
        //알림 과목이 0개일 때 알림 메시지 띄우기
        if watchingSubjectCodes.count == 0 {
            lblNoWatchingSubject.isHidden = false
        } else {
            lblNoWatchingSubject.isHidden = true
        }
        
        //왓칭 과목 현황 레이블(과목수) 업데이트
        lblWatchingSubjects.text = "알림 과목(\(watchingSubjectNames.count)/\(UserDefaults.standard.string(forKey: "num_max_watching_subjects") ?? "3"))"
        
    }
    
    //과목 조회 버튼 클릭시
    @IBAction func onClickBtnSearchSubject(_ sender: UIButton) {
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Enroll") {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.navigationController?.pushViewController(uvc, animated: true)
        }
    }
    
    //모두 해제 버튼 클릭시
    @IBAction func onClickBtnDeleteAllWatchingSubjects(_ sender: Any) {
        let arrToDel = (UserDefaults.standard.array(forKey: "subscribing_subject_names") ?? [])
        
        //해제할 과목이 없는 경우
        if arrToDel.count == 0 {
            Statics.makeAlertMessage(at: self, title: "알림", message: "알림 해제할 과목이 없습니다.")
            return
        }
        
        //해제할 과목이 하나 이상인 경우
        Statics.showLoading(at: self, animated: false, completion: {
            self.unsubscribeAll(curPos : 0, maxPos : arrToDel.count - 1)
        })
    }
    
    func unsubscribeAll(curPos :Int, maxPos : Int) {
        //현재 저장소 상태 호출
        let curSubscribingSubjectNames = (UserDefaults.standard.array(forKey: "subscribing_subject_names") ?? []) as [String]
        let curSubscribingSubjectCodes = (UserDefaults.standard.array(forKey: "subscribing_subject_codes") ?? []) as [String]
        
        Messaging.messaging().unsubscribe(fromTopic: "\(curSubscribingSubjectCodes[0])-ios") { error in
            //에러 처리
            if error != nil {
                //로딩 창 제거
                self.dismiss(animated: true, completion: nil)
                //알림 메시지 띄우기
                Statics.makeAlertMessage(at: self, title: "알림", message: "과목 알림 설정 해제 중 오류가 발생하였습니다. 안정적인 네트워크 환경 하에서 이용해주세요.")
                return
            }
            
            
            if curPos < maxPos {
                //저장소에 현재 상태 저장
                self.deleteWatchingSubjectsLock.lock()
                print("unsubscribed: \(curSubscribingSubjectCodes[0])")
                UserDefaults.standard.set(Array(curSubscribingSubjectCodes[1..<curSubscribingSubjectCodes.count]), forKey: "subscribing_subject_codes")
                UserDefaults.standard.set(Array(curSubscribingSubjectNames[1..<curSubscribingSubjectCodes.count]), forKey: "subscribing_subject_names")
                self.deleteWatchingSubjectsLock.unlock()
                	
                //다음 것 삭제
                self.unsubscribeAll(curPos : curPos + 1, maxPos : maxPos)
            } else { //마지막 과목 삭제시
                //저장소에 빈 배열 저장
                UserDefaults.standard.set([], forKey: "subscribing_subject_codes")
                UserDefaults.standard.set([], forKey: "subscribing_subject_names")
                //로딩 창 제거
                self.dismiss(animated: true, completion: nil)
                
                //알림 메시지 띄우기
                Statics.makeAlertMessage(at: self, title: "알림", message: "모든 과목 알림이 해제되었습니다.")
                
                //삭제 후 리스트 새로고침
                DispatchQueue.main.async {
                    self.viewWillAppear(true)
                }
            }
            
        } //end unsubscribe
    }
    
    @objc func btnSettingsClicked(_ sender : UITapGestureRecognizer) {
        Statics.makeAlertMessage(at: self, title: "알림", message: "준비중입니다!")
    }
    
    @objc func lblNoticeTitleClicked(_ sender : UITapGestureRecognizer) {
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Notice") {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.navigationController?.pushViewController(uvc, animated: true)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
