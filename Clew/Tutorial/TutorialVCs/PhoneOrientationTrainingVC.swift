//
//  PhoneOrientationTrainingVC.swift
//  Clew
//
//  Created by Terri Liu on 2019/6/28.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import Foundation
import SceneKit
import SRCountdownTimer
import FLAnimatedImage

class PhoneOrientationTrainingVC: TutorialChildViewController, SRCountdownTimerDelegate {

    var lastHapticFeedbackTime = Date()

    /// Timer that is visible to the user on the screen during phone orientation training
    var countdownTimer: SRCountdownTimer!

    /// Timer that is used in conjunction with the 'countdownTimer'. Used to trigger state transition
    var countdown:Timer?

    // View that contains 'congratsLabel' and 'nextButton'
    var congratsView: UIView!
    var introView: UIView!

    // Label that congratulates user for completing phone orientation training and provides details on the next part of the tutorial
    var congratsLabel: UILabel!
    var alignLabel: UILabel!

    // Button for moving to the next state of the tutorial
    var nextButton: UIButton!
    
    var gotItButton: UIButton!
    
    var skipButton: UIButton!
    
    // Label that describes the task in the phone orientation state
    
    let gifView = FLAnimatedImageView()
    var phoneOrientationLabel: UILabel!
    var phoneOrientationGIF: FLAnimatedImage!
    
    // View for giving a darker tint on the screen
    var backgroundShadow: UIView! = TutorialShadowBackground()
    
    // Timer for tracking time since PhoneOrientationTrainingVC was first opened
    var timeSinceOpen : Date?
    
    // Time to delay displaying the 'countdownTimer' to prevent the VoiceOver of the timer and the initial tracking session announcement from overlapping
    var timeAfterTrackingSessionMessage : TimeInterval?
    
    // Used to control enabling/disabling haptic feedback
    var runHapticFeedback : Bool? = true
    
    // Color used in other colors in Clew
    var clewGreen = UIColor(red: 103/255, green: 188/255, blue: 71/255, alpha: 1.0)
    var skipYellow = UIColor(red: 254/255, green: 243/255, blue: 62/255, alpha: 1.0)
    
    
    /// Callback function for when `countdownTimer` updates.  This allows us to announce the new value via voice
    /// - Parameter newValue: the new value (in seconds) displayed on the countdown timer
    @objc func timerDidUpdateCounterValue(newValue: Int) {
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: String(newValue))
    }

    /// Callback function for when the 'next' button in the congratsView popup is tapped. This changes the state of the TutorialViewController.
    @objc func nextButtonAction(sender: UIButton!) {
        tutorialParent?.state = .readyToRecordSingleRoute
    }
    
    // Callback function for when the 'skip' button is tapped
    @objc func skipButtonAction(sender: UIButton!) {
        skipNavigationProcesses()
//        tutorialParent?.state = .readyToRecordSingleRoute
    }
    
    @objc func gotItButtonAction(sender: UIButton!) {
        introView.removeFromSuperview()
        countdownTimer = SRCountdownTimer(frame: CGRect(x: UIConstants.buttonFrameWidth*1/10,
                                                        y: UIConstants.yOriginOfButtonFrame/10,
                                                        width: UIConstants.buttonFrameWidth*8/10,
                                                        height: UIConstants.buttonFrameWidth*8/10))
        countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 100)
        countdownTimer.labelTextColor = UIColor.white
        countdownTimer.timerFinishingText = "End"
        countdownTimer.lineWidth = 10
        countdownTimer.lineColor = UIColor.white
        countdownTimer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        countdownTimer.isHidden = true
        countdownTimer.delegate = self
        countdownTimer.accessibilityElementsHidden = true
        self.view.addSubview(backgroundShadow)
        self.view.addSubview(countdownTimer)
    }
    
    /// Callback function for when 'countdown' = 0. This stops haptic feedback and triggers a popup to be shown that congratulates the user for completing phone orientation training.
    @objc func timerCalled() {
        runHapticFeedback = false
        countdownTimer.removeFromSuperview()
        congratsView = createCongratsView()
        self.view.addSubview(congratsView)
        // start VoiceOver at 'congratsLabel'
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: congratsLabel)
    }

    func createIntroView() -> UIView {
        introView = UIView(frame:CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.size.width,
                                           height: UIScreen.main.bounds.size.height))
        introView.backgroundColor = clewGreen
        alignLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - UIScreen.main.bounds.size.width*2/5, y: UIScreen.main.bounds.size.height/8, width: UIScreen.main.bounds.size.width*4/5, height: 200))
        alignLabel.text = "ALIGN YOUR PHONE!"
        alignLabel.textColor = UIColor.white
        alignLabel.textAlignment = .center
        alignLabel.numberOfLines = 0
        alignLabel.lineBreakMode = .byWordWrapping
        alignLabel.layer.masksToBounds = true
        alignLabel.font = UIFont.systemFont(ofSize: 35.0)
        alignLabel.isAccessibilityElement = true
        alignLabel.accessibilityLabel = "Congratulations! You have successfully oriented your phone. Now you will be recording a simple single route."
        introView.addSubview(alignLabel)
        
        gotItButton = UIButton(frame: CGRect(x: UIConstants.buttonFrameWidth/(7/3),
                                            y: UIConstants.yOriginOfSettingsAndHelpButton + 10,
                                            width: UIConstants.buttonFrameWidth/5,
                                            height: UIConstants.buttonFrameWidth/7))
        gotItButton.isAccessibilityElement = true
        gotItButton.setTitle("Got it", for: .normal)
        gotItButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
        gotItButton.accessibilityLabel = "Got It"
        gotItButton.setImage(UIImage(named: "buttonBackground2"), for: .normal)
        gotItButton.addTarget(self, action: #selector(gotItButtonAction), for: .touchUpInside)
        introView.addSubview(gotItButton)
        
        skipButton = SkipButton().createSkipButton(buttonAction:
            #selector(skipButtonAction))
        introView.addSubview(skipButton)
        
        gifView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "PhoneOrientation", withExtension: "gif")!)
        phoneOrientationGIF = FLAnimatedImage(animatedGIFData: imageData)
        
        return introView
    }
    
    /// Initializes a view and the button in that view. The view will be shown after the user completes phone orientation training
    func createCongratsView() -> UIView {
        congratsView = UIView(frame:CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.size.width,
                                           height: UIScreen.main.bounds.size.height))
        congratsView.backgroundColor = clewGreen
        congratsLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - UIScreen.main.bounds.size.width*2/5, y: UIScreen.main.bounds.size.height/8, width: UIScreen.main.bounds.size.width*4/5, height: 200))
        congratsLabel.text = "Congratulations! \n You have successfully oriented your phone. \n Now you will be recording a simple single route."
        congratsLabel.textColor = UIColor.black
        congratsLabel.backgroundColor = UIColor.white
        congratsLabel.textAlignment = .center
        congratsLabel.numberOfLines = 0
        congratsLabel.lineBreakMode = .byWordWrapping
        congratsLabel.layer.masksToBounds = true
        congratsLabel.layer.cornerRadius = 8.0
        congratsLabel.font = UIFont.systemFont(ofSize: 24.0)
        congratsLabel.layer.borderWidth = 3.0
        congratsLabel.isAccessibilityElement = true
        congratsLabel.accessibilityLabel = "Congratulations! You have successfully oriented your phone. Now you will be recording a simple single route."
        congratsView.addSubview(congratsLabel)

        nextButton = NextButton().createNextButton(buttonAction: #selector(nextButtonAction))
        congratsView.addSubview(nextButton)
        
        return congratsView
    }
    
    func transitionToMainApp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.dismiss(animated: false)
        appDelegate.window = UIWindow(frame:UIScreen.main.bounds)
        appDelegate.window?.makeKeyAndVisible()
        appDelegate.window?.rootViewController = ViewController()
    }
    
    /// function that creates alerts for the home button
    func skipNavigationProcesses() {
        // Create alert to warn users of lost information
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "If you exit this process right now, you won't be orienting your phone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Skip this part of the tutorial.", style: .default, handler: { action -> Void in
            // proceed to home page
            self.transitionToMainApp()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            (appDelegate.window?.rootViewController as? ViewController)?.tutorialViewController.state = .readyToRecordSingleRoute
//            self.tutorialParent?.state = .readyToRecordSingleRoute
        }
        ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action -> Void in
            // nothing to do, just stay on the page
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// Called when the view appears on screen. Initializes and starts 'timeSinceOpen'.
    /// - Parameter animated: True if the appearance is animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timeSinceOpen = Date()


    }


    /// Called when the view has loaded. Make new countdownTimer that will only be used in PhoneorientationTrainingVC
    override func viewDidLoad() {
        introView = createIntroView()
        self.view.addSubview(introView)
        
//        countdownTimer = SRCountdownTimer(frame: CGRect(x: UIConstants.buttonFrameWidth*1/10,
//                                                        y: UIConstants.yOriginOfButtonFrame/10,
//                                                        width: UIConstants.buttonFrameWidth*8/10,
//                                                        height: UIConstants.buttonFrameWidth*8/10))
//        countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 100)
//        countdownTimer.labelTextColor = UIColor.white
//        countdownTimer.timerFinishingText = "End"
//        countdownTimer.lineWidth = 10
//        countdownTimer.lineColor = UIColor.white
//        countdownTimer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        countdownTimer.isHidden = true
//        countdownTimer.delegate = self
//        countdownTimer.accessibilityElementsHidden = true
//        view.addSubview(backgroundShadow)
//        view.addSubview(countdownTimer)
    }

    /// Send haptic feedback with different frequencies depending on the angle of the phone. Handle transition to the next state when the angle of the phone falls in the range of optimal angle. As the user orients the phone closer to the desired range of the angle, haptic feedback becomes faster. When optimal angle is achieved for a desired amount of time, state transition takes place.
    /// - Parameter transform: the position and orientation of the phone
    override func didReceiveNewCameraPose(transform: simd_float4x4) {

        let angleFromVertical = acos(-transform.columns.0.y)
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        let intendedInterval = TimeInterval(1/(4*exp(-pow(angleFromVertical, 2))))
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastHapticFeedbackTime)
        
        timeAfterTrackingSessionMessage = 3
        
        // handles when the angle the user is holding the phone falls in between the desired optimal angle
        if abs(timeSinceOpen!.timeIntervalSinceNow) > timeAfterTrackingSessionMessage! {
            if abs(angleFromVertical) < 0.5 {
                if countdown == nil {
                    print("angle falls in range")
                    countdownTimer.isHidden = false
                    /// NOTE: to change the time that the user needs to hold the phone in the optimal angle for state transition to happen, change both the 'beginingValue' and 'timeInterval'
                    countdownTimer.start(beginingValue: 3, interval: 1)
                    countdown = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerCalled), userInfo: nil, repeats: false) }
            } else {
            countdownTimer.isHidden = true
            countdown?.invalidate()
            countdown = nil }
        }
        /// send haptic feedback in varying frequency depending on how accurate the angle the user is holding up their phone
        if runHapticFeedback! {
            if timeInterval > intendedInterval {
                feedbackGenerator.impactOccurred()
                lastHapticFeedbackTime = now
            }
        }
    }
}
