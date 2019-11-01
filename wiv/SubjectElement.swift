//
//  SubjectElement.swift
//  wiv
//
//  Created by 서동민 on 2019/10/20.
//  Copyright © 2019 서동민. All rights reserved.
//

import Foundation

struct SubjectElement {
    var category = 1   //전공과 전공이 아닌 것을 구분. 1: 교양, 2: 전공
    var subjectDiv = "" //대분류
    var subjectDiv2 = ""    //소분류
    var subjectNo = ""
    var classDiv = ""   //분반
    var subjectNm = ""
    var dayNightNm = ""
    var shyr = ""
    var credit = ""
    var profNm = ""
    var classNm = ""    //수업일시,장소
    var tlsnCount = ""
    var tlsnLimitCount = ""
    
    init() {
        
    }

    mutating func fill(from dict : [String:String]) {
        self.subjectDiv = dict["subject_div"]!
        if self.subjectDiv.contains("전공") {
            category = 2
        }
        self.subjectDiv2 = dict["subject_div2"]!
        self.subjectNo = dict["subject_no"]!
        self.classDiv = dict["class_div"]!
        self.subjectNm = dict["subject_nm"]!
        self.dayNightNm = dict["day_night_nm"]!
        self.shyr = dict["shyr"]!
        self.credit = dict["credit"]!
        self.profNm = dict["prof_nm"]!
        self.classNm = dict["class_nm"]!
        self.tlsnCount = dict["tlsn_count"]!
        self.tlsnLimitCount = dict["tlsn_limit_count"]!
    }
}
