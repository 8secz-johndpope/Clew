//
//  RootContainerView.swift
//  Clew
//
//  Created by Dieter Brehm on 6/10/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import SceneKit.ModelIO
import AVFoundation
import AudioToolbox
import MediaPlayer
import VectorMath
import Firebase
import FirebaseDatabase
import SRCountdownTimer

class RootContainerView: UIView {
    
    // MARK: UI Dimensions

    /// Button frame extends the entire width of screen
    var buttonFrameWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// Height of button frame
    var buttonFrameHeight: CGFloat {
        return UIScreen.main.bounds.size.height * (1/5)
    }
    
    /// Height of settings and help buttons
    var settingsAndHelpFrameHeight: CGFloat {
        return UIScreen.main.bounds.size.height * (1/12)
    }
    
    /// The margin from the settings and help buttons to the bottom of the window
    var settingsAndHelpMargin: CGFloat {
        // height of button frame
        return UIScreen.main.bounds.size.height * (1/24)
    }
    
    /// top margin of direction text label
    var textLabelBuffer: CGFloat {
        return buttonFrameHeight * (1/12)
    }
    
    /// y-origin of the get directions button
    var yOriginOfGetDirectionsButton: CGFloat {
        return UIScreen.main.bounds.size.height - settingsAndHelpFrameHeight - settingsAndHelpMargin
    }
    
    /// y-origin of the settings and help buttons
    var yOriginOfSettingsAndHelpButton: CGFloat {
        get {
            // y-origin of button frame
            return UIScreen.main.bounds.size.height - settingsAndHelpFrameHeight - settingsAndHelpMargin
        }
    }
    
    /// y-origin of button frame
    var yOriginOfButtonFrame: CGFloat {
        return UIScreen.main.bounds.size.height - buttonFrameHeight - settingsAndHelpFrameHeight - settingsAndHelpMargin
    }
    
    /// y-origin of announcement frame
    var yOriginOfAnnouncementFrame: CGFloat {
        return UIScreen.main.bounds.size.height/15
    }
    
    // MARK: - UIViews for all UI button containers
    
    /// button for getting directions to the next keypoint
    var getDirectionButton: UIButton!
    
    /// button for bringing up the settings menu
    var settingsButton: UIButton!
    
    /// button for bringing up the help menu
    var helpButton: UIButton!
    
    /// the view on which the user can pause tracking
    var pauseTrackingView: UIView!
    
    /// the view on which the user can initiate the tracking resume procedure
    var resumeTrackingView: UIView!
    
    /// the view on which the user can confirm the tracking resume procedure
    var resumeTrackingConfirmView: UIView!
    
    /// a banner that displays an announcement in the top quarter of the screen.
    /// This is used for displaying status updates or directions.
    /// This should only be used to display time-sensitive content.
    var announcementText: UILabel!
    
    /// the view on which the user can rate the quality of their navigation experience
    var routeRatingView: UIView!
    
    /// a timer that counts down during the alignment procedure
    /// (alignment is captured at the end of the time)
    var countdownTimer: SRCountdownTimer!
    
    /// Button view container for stop recording button
    var stopRecordingView: UIView!
    
    /// Button view container for start recording button.
    var recordPathView: UIView!
    
    /// Button view container for start navigation button
    var startNavigationView: UIView!
    
    /// Button view container for stop navigation button
    var stopNavigationView: UIView!

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: Settings Button
        settingsButton = UIButton(frame: CGRect(x: 0,
                                                y: yOriginOfSettingsAndHelpButton,
                                                width: buttonFrameWidth/2,
                                                height: settingsAndHelpFrameHeight))
        settingsButton.isAccessibilityElement = true
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.accessibilityLabel = "Settings"
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // MARK: Help Button
        helpButton = UIButton(frame: CGRect(x: buttonFrameWidth/2,
                                            y: yOriginOfSettingsAndHelpButton,
                                            width: buttonFrameWidth/2,
                                            height: settingsAndHelpFrameHeight))
        helpButton.isAccessibilityElement = true
        helpButton.setTitle("Help", for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
        helpButton.accessibilityLabel = "Help"
        helpButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // MARK: Directions Button
        // an invisible button which can be pressed to get the directions
        // to the next waypoint.
        getDirectionButton = UIButton(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: buttonFrameWidth,
                                                    height: yOriginOfButtonFrame))
        getDirectionButton.isAccessibilityElement = true
        getDirectionButton.accessibilityLabel = "Get Directions"
        getDirectionButton.isHidden = true

        // MARK: Announcement Text
        announcementText = UILabel(frame: CGRect(x: 0,
                                                 y: yOriginOfAnnouncementFrame,
                                                 width: buttonFrameWidth,
                                                 height: buttonFrameHeight*(1/2)))
        announcementText.textColor = UIColor.white
        announcementText.textAlignment = .center
        announcementText.isAccessibilityElement = false
        announcementText.lineBreakMode = .byWordWrapping
        announcementText.numberOfLines = 2
        announcementText.font = announcementText.font.withSize(20)
        announcementText.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        announcementText.isHidden = true
        
        // MARK: countdown element
        countdownTimer = SRCountdownTimer(frame: CGRect(x: buttonFrameWidth*1/10, y: yOriginOfButtonFrame/10, width: buttonFrameWidth*8/10, height: buttonFrameWidth*8/10))
//        countdownTimer.delegate = self
        countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 100)
        countdownTimer.labelTextColor = UIColor.white
        countdownTimer.timerFinishingText = "End"
        countdownTimer.lineWidth = 10
        countdownTimer.lineColor = UIColor.white
        countdownTimer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        countdownTimer.isHidden = true
        /// hide the timer as an accessibility element and announce through VoiceOver by posting appropriate notifications
        countdownTimer.accessibilityElementsHidden = true
        
        /// add all  sub views
        addSubview(recordPathView)
        addSubview(stopRecordingView)
        addSubview(startNavigationView)
        addSubview(pauseTrackingView)
        addSubview(resumeTrackingView)
        addSubview(resumeTrackingConfirmView)
        addSubview(stopNavigationView)
        addSubview(announcementText)
        addSubview(getDirectionButton)
        addSubview(settingsButton)
        addSubview(helpButton)
        addSubview(routeRatingView)
        addSubview(countdownTimer)
    }
}
