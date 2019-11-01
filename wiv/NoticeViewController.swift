//
//  NoticeViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/28.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {
    
    @IBOutlet weak var lblNoticeTitle: UILabel!
    @IBOutlet weak var lblNoticeContent: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNoticeTitle.text = UserDefaults.standard.string(forKey: "app_notice_title") ?? "등록된 공지가 없습니다"
        
        lblNoticeContent.text = UserDefaults.standard.string(forKey: "app_notice_content") ?? "내용이 없습니다."
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
