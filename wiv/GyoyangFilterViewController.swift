//
//  GyoyangFilterViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/18.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit

class GyoyangFilterViewController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var popupRoot: UIView!
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var swGs: UISwitch!
    @IBOutlet weak var swGp: UISwitch!
    @IBOutlet weak var swGj: UISwitch!
    @IBOutlet weak var swRo: UISwitch!
   
    @IBOutlet weak var swOptEx: UISwitch!
    @IBOutlet weak var swOptGh: UISwitch!
    @IBOutlet weak var swOptS1: UISwitch!
    @IBOutlet weak var swOptS2: UISwitch!
    @IBOutlet weak var swOptFo: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = UserDefaults.standard
        swGs.isOn = storage.bool(forKey: "gyoyang_div_gs_enabled")
        swGp.isOn = storage.bool(forKey: "gyoyang_div_gp_enabled")
        swGj.isOn = storage.bool(forKey: "gyoyang_div_gj_enabled")
        swRo.isOn = storage.bool(forKey: "gyoyang_div_ro_enabled")
        
        swOptEx.isOn = storage.bool(forKey: "gyoyang_ex_ex_enabled")
        swOptGh.isOn = storage.bool(forKey: "gyoyang_ex_gh_enabled")
        swOptS1.isOn = storage.bool(forKey: "gyoyang_ex_s1_enabled")
        swOptS2.isOn = storage.bool(forKey: "gyoyang_ex_s2_enabled")
        swOptFo.isOn = storage.bool(forKey: "gyoyang_ex_fo_enabled")
        //popupRoot.sizeToFit()
        btnClose.titleLabel?.sizeToFit()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onChangedSwGs(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_div_gs_enabled")
    }
    
    @IBAction func onChangedSwGp(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_div_gp_enabled")
    }
    @IBAction func onChangedSwGj(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_div_gj_enabled")
    }
    @IBAction func onChangedSwRo(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_div_ro_enabled")
    }
    
    
    @IBAction func onChangedSwOptEx(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_ex_ex_enabled")
    }
    
    @IBAction func onChangedSwOptGh(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_ex_gh_enabled")
    }
    
    @IBAction func onChangedSwOptS1(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_ex_s1_enabled")
    }
    
    @IBAction func onChangedSwOptS2(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_ex_s2_enabled")
    }
    
    @IBAction func onChangedSwOptFo(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "gyoyang_ex_fo_enabled")
    }
}
