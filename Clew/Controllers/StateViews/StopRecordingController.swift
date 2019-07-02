//
//  StopRecordingController.swift
//  Clew
//
//  Created by Dieter Brehm on 6/18/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import UIKit

/// A View Controller for handling the stop recording state
class StopRecordingController: UIViewController {
    
    /// Button for stopping a route recording
    var stopRecordingButton: UIButton!

    /// called when the view has loaded.  We setup various app elements in here.
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(x: 0,
                            y: UIConstants.yOriginOfButtonFrame,
                            width: UIConstants.buttonFrameWidth,
                            height: UIConstants.buttonFrameHeight)
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let label = UILabel(frame: CGRect(x: 15,
                                          y: UIScreen.main.bounds.size.height/5,
                                          width: UIScreen.main.bounds.size.width-30,
                                          height: UIScreen.main.bounds.size.height/2))
        
        var mainText : String?
        if let mainText: String = mainText {
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = label.font.withSize(20)
            label.text = mainText
            label.tag = UIView.mainTextTag
            view.addSubview(label)
        }
        
        stopRecordingButton = UIButton.makeImageButton(view,
                                                       alignment: UIConstants.ButtonContainerHorizontalAlignment.center,
                                                       appearance: UIConstants.ButtonAppearance.imageButton(image: UIImage(named: "StopRecording")!),
                                                       label: NSLocalizedString("Stop recording", comment: "The name of the button that allows user to stop recording."))
        
        if let parent: UIViewController = parent {
            stopRecordingButton.addTarget(parent,
                                          action: #selector(ViewController.stopRecording),
                                          for: .touchUpInside)
        }

        // Do any additional setup after loading the view.
        view.addSubview(stopRecordingButton)
    }
}
