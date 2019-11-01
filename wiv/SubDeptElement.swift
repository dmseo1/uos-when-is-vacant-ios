//
//  SubDeptElement.swift
//  wiv
//
//  Created by 서동민 on 2019/10/20.
//  Copyright © 2019 서동민. All rights reserved.
//

import Foundation

struct SubDeptElement {
    var subDeptNo = 0
    var deptCode = ""
    var deptName = ""
    var subDeptCode = ""
    var subDeptName = ""
    init(withNo : Int, deptCode : String, deptName : String, subDeptCode : String, subDeptName : String) {
        self.subDeptNo = withNo
        self.deptCode = deptCode
        self.deptName = deptName
        self.subDeptCode = subDeptCode
        self.subDeptName = subDeptName
    }
}
