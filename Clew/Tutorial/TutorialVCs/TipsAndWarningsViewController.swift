//
//  TipsAndWarningsViewController.swift
//  Clew
//
//  Created by Terri Liu on 2019/7/2.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import FLAnimatedImage

class TipsAndWarningsViewController: UIViewController {
    func transitionToMainApp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.dismiss(animated: false)
        appDelegate.window = UIWindow(frame:UIScreen.main.bounds)
        appDelegate.window?.makeKeyAndVisible()
        appDelegate.window?.rootViewController = ViewController()
    }
    
    /// Closes the viewcontroller
    @IBAction func CloseTips(_ sender: UIButton) {
        transitionToMainApp()
    }
}
