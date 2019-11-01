//
//  EnrollTabController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/17.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit

class EnrollTabController: UITabBarController {

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

}

extension UIButton {
    
    var isChecked : Bool {
        get {
            return (self.currentBackgroundImage == UIImage(named: "checkmark.rectangle"))
        }
    }
    
}
