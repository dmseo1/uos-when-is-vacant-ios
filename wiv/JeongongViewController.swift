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

class JeongongViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var isFilterHidden = false
    
    
    var depts :	[String] = []
    var subDeptsOfSelectedDept : [String] = []

    var subDepts : [SubDeptElement] = []

    var searchResult : [SubjectElement] = []
    
    
    var deptPicker : ActionSheetStringPicker?
    var subDeptPicker : ActionSheetStringPicker?
    
    @IBOutlet weak var screenStack: UIStackView!
    
  
    @IBOutlet weak var hiddenableView: UIStackView!
    
    
    @IBOutlet weak var btnPckDept: UITextField!
    @IBOutlet weak var btnPckSubDept: UITextField!
    
    

    
    @IBOutlet weak var chkVacantSubject: BEMCheckBox!
    @IBOutlet weak var btnFilter: UIButton!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var btnHideFilter: UIButton!
    
 
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchList: UITableView!
    @IBOutlet weak var lblSearchStatus: UILabel!
    
    var selectedDept = ""
    var selectedSubDept = ""
   
    
    
    
    required init?(coder: NSCoder) {
        print("implemented!!!")
    
        super.init(coder: coder)
     
        //fatalError("init(coder:) has not been implemented")
       
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPckDept.tintColor = .clear
        btnPckSubDept.tintColor = .clear
       
        
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
                    //학부/과
                    if(!self.depts.contains(appInfo[i]["dept_name"] ?? "")) {
                        self.depts.append(appInfo[i]["dept_name"] ?? "")
                    }
                  
                    
                    let subDept = SubDeptElement(
                        withNo: Int(appInfo[i]["no"] ?? "0") ?? 0,
                        deptCode: appInfo[i]["dept"] ?? "",
                        deptName: appInfo[i]["dept_name"] ?? "",
                        subDeptCode: appInfo[i]["sub_dept"] ?? "",
                        subDeptName: appInfo[i]["sub_dept_name"] ?? ""
                    )
                    self.subDepts.append(subDept)
                }
                
            
                DispatchQueue.main.async {
                    
                    //픽커 버튼 초기 세팅
                    self.btnPckDept.text = self.depts[0]
                    self.selectedDept = self.depts[0]
                    
                    for i : Int in 0..<self.subDepts.count {
                        if self.subDepts[i].deptName == self.selectedDept {
                            self.subDeptsOfSelectedDept.append(self.subDepts[i].subDeptName)
                        }
                    }
                    self.btnPckSubDept.text = self.subDeptsOfSelectedDept[0]
                    self.selectedSubDept = self.subDeptsOfSelectedDept[0]
                    
                    
                    //픽커 생성 및 초기화
                    self.createPickerView(tagNo : 1)
                    self.createPickerView(tagNo : 2)
                    self.dismissPickerView(tagNo : 1)
                    self.dismissPickerView(tagNo : 2)
                    loadingView.dismiss(animated: false, completion: nil)
                }
            }
            fetchSubDepts.getData(url: "fetch_dept_info.php", parameters: "secCode=onlythiswivappcancallthisfetchdeptinfophpfile!")
        })
        
        let tappingOutsideTxtField = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tappingOutsideTxtField)
        
        searchList.backgroundColor = UIColor.black.withAlphaComponent(0)
        searchList.dataSource = self
        searchList.delegate = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickBtnDept(_ sender: UIButton) {
        print("enabled")
        deptPicker?.show()
    }
    
    @IBAction func onClickBtnSubDept(_ sender: UIButton) {
        print("enabled")
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
    
    
    @IBAction func onClickBtnHideFilter(_ sender: UIButton) {
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
        
        //TODO: 픽커 감추기
        
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
            
            //검색 대학, 학부/과의 코드를 탐색(검색에 쓰기 위함)
            var searchingDeptCode = ""
            var searchingSubDeptCode = ""
            print("셀렉티드: \(self.selectedSubDept)")
            for i : Int in 0..<self.subDepts.count {
                print("네임: \(self.subDepts[i].subDeptName)")
                if self.subDepts[i].subDeptName == self.selectedSubDept {
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
                    
                    
                    DispatchQueue.main.async {
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
                
                DispatchQueue.main.async {
                    fetchSearchResult.getData(url: url, parameters: "secCode=onlythiswivappcancallthisdeptsearchphpfile!&gj=jeongong&dept=\(searchingDeptCode)&subDept=\(searchingSubDeptCode)&subjectNm=\(self.txtSearch.text!)")
                    
                    print("CODE:\(searchingDeptCode), \(searchingSubDeptCode)")
                }
                
            }
            fetchSearchPos.getData(url: "fetch_search_pos.php", parameters: "secCode=onlythiswivappcancallthisfetchsearchposphpfile!")
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 1:
            return depts.count
        case 2:
            return subDeptsOfSelectedDept.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 1:
            return depts[row]
        case 2:
            return subDeptsOfSelectedDept[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView.tag) {
        case 1:
            selectedDept = depts[row]
            btnPckDept.text = selectedDept
            subDeptsOfSelectedDept.removeAll()
            for i : Int in 0..<subDepts.count {
                if(subDepts[i].deptName == selectedDept) {
                    subDeptsOfSelectedDept.append(subDepts[i].subDeptName)
                }
            }
            btnPckSubDept.text = subDeptsOfSelectedDept[0]
            selectedSubDept = subDeptsOfSelectedDept[0]
        case 2:
            selectedSubDept = subDeptsOfSelectedDept[row]
            btnPckSubDept.text = selectedSubDept
        default:
            print("This could not be happened!")
            
        }
    }
    
    
    func createPickerView(tagNo : Int) {
        let pickerView = UIPickerView()
        pickerView.tag = tagNo
        pickerView.delegate = self
        switch(tagNo) {
        case 1:
            btnPckDept.inputView = pickerView
        case 2:
            btnPckSubDept.inputView = pickerView
        default:
            print("It could not be happened!")
        }
    }
    
    func dismissPickerView(tagNo : Int) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        switch(tagNo) {
        case 1:
              btnPckDept.inputAccessoryView = toolBar
        case 2:
              btnPckSubDept.inputAccessoryView = toolBar
        default:
            print("It could not be happened!")
            	
        }
      
    }
    
    @objc func action() {
       view.endEditing(true)
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
