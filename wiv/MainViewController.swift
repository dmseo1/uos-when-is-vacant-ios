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
    
    @IBOutlet weak var watchingSubjectList: UITableView!
    @IBOutlet weak var btnSearchSubject: UIButton!
    
    
    @IBAction func onClickBtnSearchSubject(_ sender: UIButton) {
        
        if let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Enroll") {
            uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.navigationController?.pushViewController(uvc, animated: true)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgNotice.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_notice.png"))
        btnSettings.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_settings.png"))
        imgWatching.kf.setImage(with: URL(string: "\(Statics.basicURL)app_image/ico_ws_noti.png"))
        
        //공지 기본값 처리
        lblNoticeTitle.text = UserDefaults.standard.string(forKey: "app_notice_title") ?? "등록된 공지가 없습니다"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(lblNoticeTitleClicked(_:)))
        imgNotice.addGestureRecognizer(gesture)
        lblNoticeTitle.addGestureRecognizer(gesture)
        
        
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
            myHttpConnector.getData(url: "fetch_app_info.php", parameters: "secCode=onlythiswivappcancallthisfetchappvariablesphpfile!")
        })
        
        
        
        
        
        
        
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.3019607843, blue: 0.6078431373, alpha: 1)
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
        
        //왓칭 과목 현황 레이블(과목수) 업데이트
        lblWatchingSubjects.text = "알림 과목(\(watchingSubjectNames.count)/\(UserDefaults.standard.string(forKey: "num_max_watching_subjects") ?? "3"))"
        
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


