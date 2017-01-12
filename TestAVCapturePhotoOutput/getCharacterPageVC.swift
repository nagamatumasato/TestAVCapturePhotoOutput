//
//  getCharacterPageVC.swift
//  TestAVCapturePhotoOutput
//
//  Created by M on 2017/01/10.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import AVFoundation


class getCharacterPageVCViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "ViewControllerID")
        nextView.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(nextView, animated: true, completion: nil)

    }
}
