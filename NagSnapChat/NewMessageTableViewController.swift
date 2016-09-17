//
//  NewMessageTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class NewMessageTableViewController: FriendsTableViewController {
    
    // MARK: - PROPERTIES
    
    let cellAccessoryColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    
    private var image: UIImage!
    private var videoFilePath: String!
    private var imagePicker: UIImagePickerController!
    
    private var recipients = [String]()
    private var outgoingUsers = [PFUser]()
    
    
    // MARK: - viewWillAppear

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if imagePicker == nil && image == nil && videoFilePath == nil {
            showCamera()
        }
    }
    
    // MARK: - HELPER METHODS

    func showCamera() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)!
        imagePicker.videoMaximumDuration = 10
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setUpMessage() {
        var fileData: NSData!
        var fileName: String!
        var fileType: String!
        
        if image != nil {
            // Photo message
            
            let resizedImage = self.resizeImage(self.image)
            fileData = UIImagePNGRepresentation(resizedImage)
            fileName = "photo.png"
            fileType = "photo"
            
        } else {
            // Video message
            
            fileData = NSData(contentsOfFile: videoFilePath)
            fileName = "video.mov"
            fileType = "video"
        }
        
        uploadMessage(fileData, fileName: fileName, fileType: fileType)
    }
    
    
    func uploadMessage(fileData: NSData, fileName: String, fileType: String) {
        
        // 1. Create a new PFFile for our new image or video
        // 2. Save that PFFile to Parse
        // 3. Construct a new message
        // 4. Save the message to Parse
        
        let messageFile = PFFile(name: fileName, data: fileData)
        
        messageFile?.saveInBackgroundWithBlock({ (success, error) in
            if error == nil {
                
                let message = PFObject(className: "Messages")
                message["senderName"] = self.currentUser.username
                
                // configure message
                message["senderId"] = self.currentUser.objectId!
                message["recipientIds"] = self.recipients
                message["file"] = messageFile
                message["fileType"] = fileType
                
                // save msessage in background
                message.saveInBackgroundWithBlock({ (success, error) in
                    if error == nil {
                        // saved successfully, go back to inbox
                        self.cancel()
                        
                    } else {
                        print(error)
                    }
                })
                
                
            } else {
                print(error)
            }
        })
        
        
        
    }
    
    // MARK: - ACTIONS
    
    @IBAction func cancel() {
        imagePicker = nil
        recipients.removeAll()
        image = nil
        videoFilePath = nil
        
        // Return to Tab #1
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func sendDidTap(sender: AnyObject) {
        if image == nil && videoFilePath == nil {
            print("You should send something")
        } else {
            setUpMessage()
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let recipient = self.friends[indexPath.row]
        
        if cell?.accessoryType == .Checkmark {
            // already selected, uncheck
            cell?.accessoryType = .None
            if let index = recipients.indexOf(recipient.objectId!) {
                self.recipients.removeAtIndex(index)
                self.outgoingUsers.removeAtIndex(index)
                
                print(recipients)
                
            }
            
        } else {
            // isn't selected, check
            cell?.accessoryType = .Checkmark
            
            self.recipients.append(recipient.objectId!)
            self.outgoingUsers.append(recipient)
            
            print(recipients)

        }
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension NewMessageTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cancel()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            // photo
            self.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        } else {
            // video
            videoFilePath = (info[UIImagePickerControllerMediaURL] as! NSURL).path
            UISaveVideoAtPathToSavedPhotosAlbum(videoFilePath, nil, nil, nil)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}


// MARK: - Resize Image

extension NewMessageTableViewController {
    func resizeImage(originalImage: UIImage) -> UIImage {
        let height: CGFloat = 480.0
        let ratio = image.size.width / image.size.height
        let width = height * ratio
        
        let newSize = CGSizeMake(width, height)
        let newRectangle = CGRectMake(0, 0, width, height)
        
        UIGraphicsBeginImageContext(newSize)
        originalImage.drawInRect(newRectangle)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}


