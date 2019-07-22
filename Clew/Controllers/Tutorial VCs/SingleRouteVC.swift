//
//  SingleRouteVC.swift
//  Clew Dev
//
//  Created by occamlab on 6/19/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import UIKit

class SingleRouteVC: TutorialChildViewController {
    
    var nextButton: UIButton!
    var backgroundShadow: UIView! = TutorialShadowBackground()
    var announcementManager = AnnouncementManager()
    var clewGreen = UIColor(red: 103/255, green: 188/255, blue: 71/255, alpha: 1.0)
    var landmarkNextButton: UIButton!
    var recordNextButton: UIButton!
    var pauseNextButton: UIButton!
    var navigateNextButton: UIButton!
    var landmarkArrow: UIView?
    var landmarkCallout: UIView?
    var recordArrow: UIView?
    var recordCallout: UIView?
    var pauseArrow: UIView?
    var pauseCallout: UIView?
    var navigateArrow: UIView?
    var navigateCallout: UIView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backgroundShadow)
        
        createObjects()
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: landmarkCallout)
        
        self.view.addSubview(landmarkCallout!)
        self.view.addSubview(landmarkNextButton)
        self.view.addSubview(landmarkArrow!)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
    }
    
    func createObjects() {
        landmarkCallout = createCalloutToView(withTagID: UIView.recordPathButtonTag, calloutText: "The Landmark button helps create saved routes. We'll return to this later, for now click on the 'next' button.", buttonAccessibilityName: "Landmark Button")
        landmarkArrow = createCalloutArrowToView(withTagID: UIView.addLandmarkButtonTag)
        recordCallout = createCalloutToView(withTagID: UIView.recordPathButtonTag, calloutText: "The Record button allows you to start recording a route, click the 'record' button to continue.", buttonAccessibilityName: "Record Button")
        recordArrow = createCalloutArrowToView(withTagID: UIView.recordPathButtonTag)
        
        landmarkNextButton = createNextButton(buttonAction: #selector(landmarkNextButtonAction))
        recordNextButton = createNextButton(buttonAction: #selector(recordNextButtonAction))
        pauseNextButton = createNextButton(buttonAction: #selector(pauseNextButtonAction))
        navigateNextButton = createNextButton(buttonAction: #selector(navigateNextButtonAction))
    }
    
    func createNextButton(buttonAction: Selector) -> UIButton {
        nextButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - UIScreen.main.bounds.size.width*1/5, y: UIScreen.main.bounds.size.width*3/10 + UIScreen.main.bounds.size.height*1/10 + 100, width: UIScreen.main.bounds.size.width*2/5, height: UIScreen.main.bounds.size.height*1/10))
        nextButton.backgroundColor = clewGreen
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.setTitle("Next", for: .normal)
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = 10.0
        nextButton.layer.borderWidth = 3.0
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
        nextButton.isAccessibilityElement = true
        nextButton.isUserInteractionEnabled = true
        nextButton.addTarget(self, action: buttonAction, for: .touchUpInside)
        return nextButton
    }
    
    @objc func landmarkNextButtonAction(sender: UIButton!) {
        landmarkArrow!.removeFromSuperview()
        landmarkCallout!.removeFromSuperview()
        landmarkNextButton.removeFromSuperview()
        self.view.addSubview(recordCallout!)
        self.view.addSubview(recordNextButton)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: recordCallout)
    }
    
    @objc func recordNextButtonAction(sender: UIButton!) {
        recordNextButton.removeFromSuperview()
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: recordCallout)
        self.view.addSubview(recordArrow!)
        backgroundShadow.removeFromSuperview()
    }
    
    @objc func pauseNextButtonAction(sender: UIButton!) {
        pauseNextButton.removeFromSuperview()
        pauseArrow!.removeFromSuperview()
        pauseCallout!.removeFromSuperview()
        navigateCallout = createCalloutToView(withTagID: UIView.startNavigationButtonTag, calloutText: "Navigate button allows you to navigate the route, click the next button and then click the navigate button to continue", buttonAccessibilityName: "Navigate Button")
        self.view.addSubview(navigateCallout!)
        self.view.addSubview(navigateNextButton!)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: navigateCallout)
    }
    
    @objc func navigateNextButtonAction(sender: UIButton!) {
        navigateNextButton.removeFromSuperview()
        backgroundShadow.removeFromSuperview()
        navigateArrow = createCalloutArrowToView(withTagID: UIView.startNavigationButtonTag)
        self.view.addSubview(navigateArrow!)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: navigateCallout)
    }
    
    override func didTransitionTo(newState: AppState) {
        if case .recordingRoute = newState {
            tutorialParent?.state = .recordingSingleRoute
            recordCallout!.removeFromSuperview()
            recordArrow!.removeFromSuperview()
        }
        
        if case .readyToNavigateOrPause = newState {
            self.view.addSubview(backgroundShadow)  
            tutorialParent?.state = .teachTheNavigationOfASingleRoute
            // Delaying the callout introduction until after the view has successfully been added
            // TODO: think about healthier ways this can be done
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                self.pauseCallout = self.createCalloutToView(withTagID: UIView.startNavigationButtonTag, calloutText: "The Pause button allows you to create saved routes, we'll return to this later, click the 'next' button to continue.", buttonAccessibilityName: "Pause Button")
                self.pauseArrow = self.createCalloutArrowToView(withTagID: UIView.pauseSessionButtonTag)
                self.view.addSubview(self.pauseCallout!)
                self.view.addSubview(self.pauseArrow!)
                UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: self.pauseCallout)
            }
            
            self.view.addSubview(pauseNextButton!)
        }
        
        if case .navigatingRoute = newState {
            tutorialParent?.state = .teachTheNavigationOfASingleRoute
            navigateArrow!.removeFromSuperview()
            navigateCallout!.removeFromSuperview()
        }
        
        if case .ratingRoute = newState {
            tutorialParent?.state = .endTutorial
            announcementManager.remove()
            //            removeObserver(tutorialViewController) TODO: fix
        }
        
    }
}

