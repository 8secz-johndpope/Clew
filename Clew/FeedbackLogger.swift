//
//  FeedbackLogger.swift
//  Clew
//
//  Created by tad on 6/7/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

//imports lobraries
import Foundation
import Firebase


class FeedbackLogger {

    //creates a reference to the feedback folder within firebase
    let feedbackRef = Storage.storage().reference().child("feedback")
    
    //MARK: functions
    //a function which saves the feedback and publishis it to the firebase website
    func writeFeedbackToFirebase(name : String, data : Data, audio audioFileURL : URL?) -> Int {
        
        //creates an intiger which stores the return value of the function (0 for no errors and 1 for a failed build)
        var returnValue = 0
        
        //creates a reference to the location we want to save the new file
        let fileRef = feedbackRef.child("\(name)_\(UUID().uuidString)_metadata.json")
        
        let fileType = StorageMetadata()
        fileType.contentType = "application/json"
        
        // Upload the file to the path defined by fileRef then checks for any errors
        let uploadTask = fileRef.putData(data, metadata: fileType){ (metadata, error) in
            guard metadata != nil else {
                // prints an errorstatement to the console
                print("could not upload feedback to firebase", error!.localizedDescription)
                //sets the return value equal to 1 if an error ocurred
                returnValue = 1
                //quits the conditional
                return
            }
        }
        
        //MARK: Audio Recording to Firebase
        // if there was an audio note recording attached to the feedback submission then send it to firebase as well
        if audioFileURL != nil{
            if let data = try? Data(contentsOf: audioFileURL!) {
                //sets the file type to the proper audio file
                let fileType = StorageMetadata()
                fileType.contentType = "audio/wav"
                
                let fileRef = feedbackRef.child("\(name)_\(UUID().uuidString).wav")
                let uploadTask = fileRef.putData(data, metadata: fileType){ (metadata, error) in
                    guard metadata != nil else {
                        returnValue = 1
                        // prints an errorstatement to the console
                        print("could not upload audio recording to firebase", error!.localizedDescription)
                        //quits the conditional
                        return
                    }
                }
            }
        }
        
        
        return returnValue
    }
    
    //takes in all the different pieces of data and combines them into a properly formatted string of type Data
    func makeData(name: String, message: String, country inputCountry: String?, phone: String, email: String) -> Data? {
        
        var country: String = "NONE"
        
        //performs input processing on the country Field
        if inputCountry == "Country (optional)"{
            country = "NONE"
        }else{
            country = inputCountry!
        }
        
        //places the data into a dictionary to be formatted into JSON later
        let body: [String : Any] = ["FeedbackDate": "\(Date().description(with: .current))",
                                    "PhoneNumber": phone,
                                    "Email": email,
                                    "Name": name,
                                    "Country": country,
                                    "Message": message,
                                    "AppInstanceID": Analytics.appInstanceID()]
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            //returns the data properly combined and formatted
            return data
        }catch {
        print(error.localizedDescription)
        }
        return nil
    }
    //combines the information together and saves a file to Firebase containing the user's feedback
    func saveFeedback(name: String, message: String, country: String?, phone: String, email: String,audio: URL?) -> Int{
        //calls the functions to create the properly formatted data and upload the result to firebase
        return writeFeedbackToFirebase(name: name, data: makeData(name: name, message: message, country: country, phone: phone, email: email)!,audio: audio)
    }
}
