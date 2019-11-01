//
//  LoadingViewController.swift
//  wiv
//
//  Created by 서동민 on 2019/10/20.
//  Copyright © 2019 서동민. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var pgBar: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        pgBar.startAnimating()
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

}
