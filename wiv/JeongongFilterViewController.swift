//
//  JeongongFilterViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/20.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit

class JeongongFilterViewController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var popupRoot: UIView!
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var swJs: UISwitch!
    @IBOutlet weak var swJp: UISwitch!
    @IBOutlet weak var swOptHs: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = UserDefaults.standard
        swJs.isOn = storage.bool(forKey: "jeongong_div_js_enabled")
        swJp.isOn = storage.bool(forKey: "jeongong_div_jp_enabled")
        
        swOptHs.isOn = storage.bool(forKey: "jeongong_ex_hs_enabled")
        
        //popupRoot.sizeToFit()
        btnClose.titleLabel?.sizeToFit()
        // Do any additional setup after loading the view.
    }
   
    
    @IBAction func onChangedSwJs(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "jeongong_div_js_enabled")
    }
    
    @IBAction func onChangedSwJp(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "jeongong_div_jp_enabled")
    }
    
    @IBAction func onChangedSwOptHs(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "jeongong_ex_hs_enabled")
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
