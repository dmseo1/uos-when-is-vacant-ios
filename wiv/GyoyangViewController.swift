//
//  GyoyangViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/17.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit
import BEMCheckBox

class GyoyangViewController: UIViewController, UITextFieldDelegate {
    
    var isFilterHidden = false

    var searchResult : [SubjectElement] = []
    @IBOutlet weak var screenStack: UIStackView!
    @IBOutlet weak var searchList: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var chkVacantSubject: BEMCheckBox!
    @IBOutlet weak var lblVacantSubject: UILabel!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnHideFilter: UIButton!
    
    @IBOutlet weak var lblSearchStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblVacantSubject.adjustsFontSizeToFitWidth = true
        
        searchList.backgroundColor = UIColor.black.withAlphaComponent(0)
        searchList.dataSource = self
        searchList.delegate = self
        
        //공석이 있는 과목만 조회 체크박스 설정
        chkVacantSubject.on = UserDefaults.standard.bool(forKey: "gyoyang_vacant_subject_enabled")
        btnFilter.isHidden = !chkVacantSubject.on
        
        
        txtSearch.returnKeyType = .done
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        
        /*
         let storyboard = self.storyboard!
         let nextView = storyboard.instantiateViewController(withIdentifier: "GyoyangFilter")
         self.present(nextView, animated: true, completion: nil)
         */
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func onChangedChkVacantSubject(_ sender: BEMCheckBox) {
        
        UserDefaults.standard.set(sender.on, forKey: "gyoyang_vacant_subject_enabled")
        
        switch(sender.on) {
        case true:
            self.btnFilter.isHidden = false
        case false:
            self.btnFilter.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickHideFilter(_ sender: UIButton) {
        switch(isFilterHidden) {
        case true:
            screenStack.arrangedSubviews[0].isHidden = false
            btnHideFilter.setTitle("▲ 필터 숨기기", for: .normal)
            isFilterHidden = false
        case false:
            screenStack.arrangedSubviews[0].isHidden = true
            btnHideFilter.setTitle("▼ 필터 보이기", for: .normal)
            isFilterHidden = true
        }
    }
    
    
    @IBAction func onClickBtnSearch(_ sender: UIButton) {
        //소프트키보드 내리기
        txtSearch.resignFirstResponder()
        //상태 라벨 안보이기
        lblSearchStatus.isHidden = true
        
        let storyboard = self.storyboard!
        let loadingView = storyboard.instantiateViewController(withIdentifier: "Loading")
        loadingView.modalPresentationStyle = .overFullScreen
        loadingView.modalTransitionStyle = .crossDissolve
        self.present(loadingView, animated: true, completion: {
            
            let storage = UserDefaults.standard
            let onlyVacant = storage.bool(forKey: "gyoyang_vacant_subject_enabled")
            let gsOx = !onlyVacant || storage.bool(forKey: "gyoyang_div_gs_enabled") ? "o" : "x"
            let gpOx = !onlyVacant || storage.bool(forKey: "gyoyang_div_gp_enabled") ? "o" : "x"
            let gjOx = !onlyVacant || storage.bool(forKey: "gyoyang_div_gj_enabled") ? "o" : "x"
            let roOx = !onlyVacant || storage.bool(forKey: "gyoyang_div_ro_enabled") ? "o" : "x"
            
            let exEx = onlyVacant && storage.bool(forKey: "gyoyang_ex_ex_enabled")
            let exGh = onlyVacant && storage.bool(forKey: "gyoyang_ex_gh_enabled")
            let exS1 = onlyVacant && storage.bool(forKey: "gyoyang_ex_s1_enabled")
            let exS2 = onlyVacant && storage.bool(forKey: "gyoyang_ex_s2_enabled")
            let exFo = onlyVacant && storage.bool(forKey: "gyoyang_ex_fo_enabled")
            
            //검색 대학, 학부/과의 코드를 설정
            let fetchSearchPos = HttpConnector()
            fetchSearchPos.taskCompleted = { url in
                let fetchSearchResult = HttpConnectorOthers()
                fetchSearchResult.taskCompleted = { result in

                    let subjectList = Statics.getArrayDictionaryFromJSON(jsonString: result, tag: "subject_search_result")
                    self.searchResult.removeAll()
                    for i : Int in 0..<subjectList.count {
                        
                        //TODO: 필터 내용을 여기에 추가한다
                        var subject = SubjectElement()
                        subject.fill(from: subjectList[i])
                        let sn = subject.subjectNm
                        
                        if onlyVacant {
                            let cnt = Int(subject.tlsnCount) ?? 0
                            let limitCnt = Int(subject.tlsnLimitCount) ?? 0
                            if cnt >= limitCnt {
                                continue
                            }
                        }
                        
                        if subject.dayNightNm == "계약" || subject.dayNightNm == "" {
                            continue
                        }
                        
                        if sn.contains("한국어") { continue }
                        
                        if exEx {
                            if subject.subjectDiv2 == "학문기초" && (sn.contains("및실험") ||
                                sn.contains("및실습") || sn.contains("창의주제탐구세미나")) {
                                continue
                            }
                        }
                        
                        if exGh {
                            if subject.subjectDiv2 == "공학소양" {
                                continue
                            }
                        }
                        
                        if exS1 {
                            if subject.subjectNo == "01330" {
                                continue
                            }
                        }
                        
                        if exS2 {
                            if subject.subjectNo == "01331" {
                                continue
                            }
                        }
                        
                        if exFo {
                            if subject.subjectDiv2 == "외국어" && (sn.contains("중국어") || sn.contains("일본어") || sn.contains("스페인어") || sn.contains("베트남어") || sn.contains("러시아어") || sn.contains("독일어") || sn.contains("불어") || sn.contains("라틴어")) {
                                continue
                            }
                        }
                        
                        self.searchResult.append(subject)
                    }
                    
                    
                    DispatchQueue.main.sync {
                        self.searchList.reloadData()
                        if self.searchResult.count == 0 {
                            self.lblSearchStatus.text = "조건에 맞는 과목이 없습니다."
                            self.lblSearchStatus.isHidden = false
                        }
                        let indexPath = NSIndexPath(row: NSNotFound, section: 0)
                        self.searchList.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
                
                DispatchQueue.main.sync {
                    fetchSearchResult.getData(url: url, parameters: "secCode=onlythiswivappcancallthisdeptsearchphpfile!&gj=gyoyang&gs=\(gsOx)&gp=\(gpOx)&gz=\(gjOx)&ro=\(roOx)&subjectNm=\(self.txtSearch.text!)")
                }
                
            }
            fetchSearchPos.getData(url: "fetch_search_pos.php", parameters: "secCode=onlythiswivappcancallthisfetchsearchposphpfile!&token=\(UserDefaults.standard.string(forKey: "token") ?? "FIRST")&os=ios")
            
            
        })
        
    }
    
    
}
