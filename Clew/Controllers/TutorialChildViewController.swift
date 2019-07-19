//
//  TutorialChildViewController.swift
//  Clew
//
//  Created by Terri Liu on 2019/7/2.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class TutorialChildViewController: UIViewController, ClewObserver {
    var tutorialParent: TutorialViewController? {
        return parent as? TutorialViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view = TransparentTouchView(frame:CGRect(x: 0,
                                                 y: 0,
                                                 width: UIScreen.main.bounds.size.width,
                                                 height: UIScreen.main.bounds.size.height))
    }

    func createCalloutToView(withTagID tagID: Int, calloutText: String)->UIView? {
        guard let grandParent = tutorialParent?.parent as? ViewController,
            let viewToCallout = grandParent.view.viewWithTag(tagID) else {
                return nil
        }
        
        let buttonLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - UIScreen.main.bounds.size.width*2/5, y: UIScreen.main.bounds.size.height/6, width: UIScreen.main.bounds.size.width*4/5, height: 200))
        buttonLabel.text = calloutText
        buttonLabel.textColor = UIColor.black
        buttonLabel.backgroundColor = UIColor.white
        buttonLabel.textAlignment = .center
        buttonLabel.numberOfLines = 0
        buttonLabel.lineBreakMode = .byWordWrapping
        buttonLabel.layer.masksToBounds = true
        buttonLabel.layer.cornerRadius = 8.0
        buttonLabel.font = UIFont.systemFont(ofSize: 24.0)
        buttonLabel.layer.borderColor = UIColor.black.cgColor
        buttonLabel.layer.borderWidth = 3.0
        
        view.addSubview(buttonLabel)



        let xCenter = viewToCallout.frame.midX
        let 
        let yCenter = viewToCallout.frame.maxY + 50
        print("1 - locationText")
        print(viewToCallout.frame.minX)
        buttonLabel.center = CGPoint(x: xCenter, y: UIScreen.main.bounds.size.height/8 + 100)



        view.addSubview(buttonLabel)
        return buttonLabel
    }

    func createCalloutArrowToView(withTagID tagID: Int)-> UIView? {
        guard let grandParent = tutorialParent?.parent as? ViewController,
            let viewToCallout = grandParent.view.viewWithTag(tagID) else {
                return nil
            }
        let arrowImage = UIImage(named: "calloutArrow")
        let imageView = UIImageView(image: arrowImage!)
        view.addSubview(imageView)
        imageView.isHidden = false
        let xCenter = viewToCallout.frame.midX
        imageView.frame = CGRect(x: xCenter - imageView.frame.width/8, y: 375, width: 100, height: 100)
        return imageView
    }

    func finishAnnouncement(announcement: String) { }
    func didReceiveNewCameraPose(transform: simd_float4x4)  {}
    func didTransitionTo(newState: AppState) {}
}
