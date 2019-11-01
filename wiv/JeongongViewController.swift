//
//  JeongongViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/17.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import BEMCheckBox

class JeongongViewController: UIViewController, UITextFieldDelegate {
    
    var selectedDeptIdx = 0
    var selectedSubDeptIdx = 0
    
    var depts : [String ] = []
    var subDepts : [SubDeptElement] = []
    var searchResult : [SubjectElement] = []
    
    
    var deptPicker : ActionSheetStringPicker?
    var subDeptPicker : ActionSheetStringPicker?
    
    
    @IBOutlet weak var btnDept: UIButton!
    @IBOutlet weak var btnSubDept: UIButton!
    
    @IBOutlet weak var lblSelectedDept: UILabel!
    @IBOutlet weak var lblSelectedSubDept: UILabel!
    @IBOutlet weak var hiddenableView: UIStackView!
    
    
    @IBOutlet weak var chkVacantSubject: BEMCheckBox!
    @IBOutlet weak var btnFilter: UIButton!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchList: UITableView!
    @IBOutlet weak var lblSearchStatus: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnFilter.layoutMargins = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        
        //소프트키보드 리턴 키 수정
        txtSearch.returnKeyType = .done
        
        //공석이 있는 과목만 조회 체크박스 설정
        chkVacantSubject.on = UserDefaults.standard.bool(forKey: "jeongong_vacant_subject_enabled")
        btnFilter.isHidden = !chkVacantSubject.on
        
        //대학, 학부/과 정보 로드
        let storyboard = self.storyboard!
        let loadingView = storyboard.instantiateViewController(withIdentifier: "Loading")
        loadingView.modalPresentationStyle = .overFullScreen
        loadingView.modalTransitionStyle = .crossDissolve
        self.present(loadingView, animated: true, completion: {
            let fetchSubDepts = HttpConnector()
            fetchSubDepts.taskCompleted = { result in
                let appInfo = Statics.getArrayDictionaryFromJSON(jsonString: result, tag: "dept_info")
                for i : Int in 0..<appInfo.count {
                    if !self.depts.contains(appInfo[i]["dept_name"]!) {
                        self.depts.append(appInfo[i]["dept_name"]!)
                    }
                    self.subDepts.append(SubDeptElement(withNo: Int(appInfo[i]["no"]!)!, deptCode: appInfo[i]["dept"]!, deptName: appInfo[i]["dept_name"]!, subDeptCode: appInfo[i]["sub_dept"]!, subDeptName: appInfo[i]["sub_dept_name"]!))
                }
                
                //픽커 조정
                DispatchQueue.main.sync {
                    self.deptPicker = ActionSheetStringPicker(title: "대학 선택", rows: self.depts, initialSelection: self.selectedDeptIdx, doneBlock: { picker, indexes, values in
                        
                        //대표 레이블을 조정하고, 픽커 내용을 변경한다
                        self.lblSelectedDept.text = values as? String
                        var newSubDeptArray : [String] = []
                        for i : Int in 0..<self.subDepts.count {
                            if values as? String == self.subDepts[i].deptName {
                                newSubDeptArray.append(self.subDepts[i].subDeptName)
                            }
                        }
                        
                        //새로 선택된 대학 기준으로 학부/과 픽커 조정
                        //인덱스를 가장 처음으로 돌린 후, 대표 레이블을 조정하고, 픽커 내용을 변경한다
                        self.selectedSubDeptIdx = 0
                        self.lblSelectedSubDept.text = newSubDeptArray[self.selectedSubDeptIdx]
                        self.subDeptPicker = ActionSheetStringPicker(title: "학부/과 선택", rows: newSubDeptArray, initialSelection: self.selectedSubDeptIdx, doneBlock : { picker, indexes, values in
                            self.lblSelectedSubDept.text = values as? String
                            return
                        }, cancel: { ActionStringCancelBlock in return}, origin: self.btnSubDept)
                        
                        
                        self.selectedDeptIdx = indexes
                        return
                    }, cancel: { ActionStringCancelBlock in
                        
                        return}, origin: self.btnDept)
                    
                    //학부/과 픽커 최초 초기화가 필요하다
                    var newSubDeptArray : [String] = []
                    for i : Int in 0..<self.subDepts.count {
                        if self.lblSelectedDept.text == self.subDepts[i].deptName {
                            newSubDeptArray.append(self.subDepts[i].subDeptName)
                        }
                    }
                    self.selectedSubDeptIdx = 0
                    self.lblSelectedSubDept.text = newSubDeptArray[self.selectedSubDeptIdx]
                    self.subDeptPicker = ActionSheetStringPicker(title: "학부/과 선택", rows: newSubDeptArray, initialSelection: self.selectedSubDeptIdx, doneBlock : { picker, indexes, values in
                        self.lblSelectedSubDept.text = values as? String
                        return
                    }, cancel: { ActionStringCancelBlock in return}, origin: self.btnSubDept)
                }
            }
            fetchSubDepts.getData(url: "fetch_dept_info.php", parameters: "secCode=onlythiswivappcancallthisfetchdeptinfophpfile!")
            
            self.dismiss(animated: true, completion: nil)
        })
        
        
        
        let tappingOutsideTxtField = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tappingOutsideTxtField)
        
        searchList.backgroundColor = UIColor.black.withAlphaComponent(0)
        searchList.dataSource = self
        searchList.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickBtnDept(_ sender: UIButton) {
        deptPicker?.show()
    }
    
    @IBAction func onClickBtnSubDept(_ sender: UIButton) {
        subDeptPicker?.show()
    }
    
    
    @IBAction func OnChangedChkVacantSubject(_ sender: BEMCheckBox) {
        UserDefaults.standard.set(sender.on, forKey: "jeongong_vacant_subject_enabled")
        switch(sender.on) {
        case true :
            self.btnFilter.isHidden = false
        case false :
            self.btnFilter.isHidden = true
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //소프트 키보드 내리기
        txtSearch.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        //소프트 키보드 내리기
        txtSearch.resignFirstResponder()
    }
    
    @IBAction func onClickBtnSearch(_ sender: UIButton) {
        //소프트키보드 내리기
        txtSearch.resignFirstResponder()
        
        //조회 상태 레이블 감추기
        lblSearchStatus.isHidden = true
        
        let storyboard = self.storyboard!
        let loadingView = storyboard.instantiateViewController(withIdentifier: "Loading")
        loadingView.modalPresentationStyle = .overFullScreen
        loadingView.modalTransitionStyle = .crossDissolve
        self.present(loadingView, animated: true, completion: {
            
            let storage = UserDefaults.standard
            let onlyVacant = storage.bool(forKey: "jeongong_vacant_subject_enabled")
            let divJs = !onlyVacant || storage.bool(forKey: "jeongong_div_js_enabled")
            let divJp = !onlyVacant || storage.bool(forKey: "jeongong_div_jp_enabled")
            let exHs = onlyVacant && storage.bool(forKey: "jeongong_ex_hs_enabled")
            
            //검색 대학, 학부/과의 코드를 설정
            var searchingDeptCode = ""
            var searchingSubDeptCode = ""
            for i : Int in 0..<self.subDepts.count {
                if self.subDepts[i].subDeptName == self.lblSelectedSubDept.text {
                    searchingDeptCode = self.subDepts[i].deptCode
                    searchingSubDeptCode = self.subDepts[i].subDeptCode
                    break
                }
            }
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
                        
                        if onlyVacant {
                            let cnt = Int(subject.tlsnCount) ?? 0
                            let limitCnt = Int(subject.tlsnLimitCount) ?? 0
                            if cnt >= limitCnt {
                                continue
                            }
                        }
                        
                        if !divJs {
                            if subject.subjectDiv == "전공선택" {
                                continue
                            }
                        }
                        
                        if !divJp {
                            if subject.subjectDiv == "전공필수" {
                                continue
                            }
                        }
                        
                        if exHs {
                            if subject.subjectNm.contains("학업설계상담") {
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
                    fetchSearchResult.getData(url: url, parameters: "secCode=onlythiswivappcancallthisdeptsearchphpfile!&gj=jeongong&dept=\(searchingDeptCode)&subDept=\(searchingSubDeptCode)&subjectNm=\(self.txtSearch.text!)")
                }
                
            }
            fetchSearchPos.getData(url: "fetch_search_pos.php", parameters: "secCode=onlythiswivappcancallthisfetchsearchposphpfile!")
            
            
        })
        
        
        
        
        
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
