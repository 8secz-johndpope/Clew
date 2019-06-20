//
//  ResumeTrackingController.swift
//  Clew
//
//  Created by Dieter Brehm on 6/18/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import UIKit

/// A View Controller for handling resuming a route navigation
class ResumeTrackingController: UIViewController {
    
    /// button for resuming navigation
    var resumeButton: UIButton!

    /// called when the view has loaded.  We setup various app elements in here.
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(x: 0,
                            y: 0,
                            width: UIScreen.main.bounds.size.width,
                            height: UIScreen.main.bounds.size.height)

        let label = UILabel(frame: CGRect(x: 15,
                                          y: UIScreen.main.bounds.size.height/5,
                                          width: UIScreen.main.bounds.size.width-30,
                                          height: UIScreen.main.bounds.size.height/2))
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let mainText = "Return to the last paused location and press Resume for further instructions."
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = label.font.withSize(20)
        label.text = mainText
        label.tag = UIView.mainTextTag
        view.addSubview(label)
        
        
        /// The button that the allows the user to resume a paused route
        resumeButton = UIButton.makeImageButton(view,
                                                alignment: UIConstants.ButtonContainerHorizontalAlignment.center,
                                                appearance: UIConstants.ButtonAppearance.textButton(label: "Resume"),
                                                label: "Resume")
        
        
        if let parent: UIViewController = parent {
            resumeButton.addTarget(parent,
                                     action: #selector(ViewController.confirmResumeTracking),
                                     for: .touchUpInside)
        }
        
        // Do any additional setup after loading the view.
        view.addSubview(resumeButton)
    }
}
