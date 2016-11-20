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
    
    fileprivate var image: UIImage!
    fileprivate var videoFilePath: String!
    fileprivate var imagePicker: UIImagePickerController!
    
    fileprivate var recipients = [String]()
    fileprivate var outgoingUsers = [PFUser]()
    
    
    // MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if imagePicker == nil && image == nil && videoFilePath == nil {
            showCamera()
        }
    }
    
    // MARK: - HELPER METHODS

    func showCamera() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
        imagePicker.videoMaximumDuration = 10
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setUpMessage() {
        var fileData: Data!
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
            
            fileData = try? Data(contentsOf: URL(fileURLWithPath: videoFilePath))
            fileName = "video.mov"
            fileType = "video"
        }
        
        uploadMessage(fileData, fileName: fileName, fileType: fileType)
    }
    
    
    func uploadMessage(_ fileData: Data, fileName: String, fileType: String) {
        
        // 1. Create a new PFFile for our new image or video
        // 2. Save that PFFile to Parse
        // 3. Construct a new message
        // 4. Save the message to Parse
        
        let messageFile = PFFile(name: fileName, data: fileData)
        
        messageFile?.saveInBackground(block: { (success, error) in
            if error == nil {
                
                let message = PFObject(className: "Messages")
                message["senderName"] = self.currentUser.username
                
                // configure message
                message["senderId"] = self.currentUser.objectId!
                message["recipientIds"] = self.recipients
                message["file"] = messageFile
                message["fileType"] = fileType
                
                // save msessage in background
                message.saveInBackground(block: { (success, error) in
                    if error == nil {
                        
                        
                        // Push Notifications
                        // !!!IMPORTANT!!!
                        // ===TOUSE===
                        
                        let pushQuery = PFInstallation.query()
                        pushQuery?.whereKey("user", containedIn: self.outgoingUsers)
                        
                        let push = PFPush()
                        push.setQuery(pushQuery as! PFQuery<PFInstallation>?)
                        
                        let username = PFUser.current()!.username
                        let pushDataDictionary = ["alert": "New message from \(username!)", "badge": "Increment", "sound": ""]
                        
                        push.setData(pushDataDictionary)
                        push.sendInBackground()
                        
                        
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
    
    @IBAction func sendDidTap(_ sender: AnyObject) {
        if image == nil && videoFilePath == nil {
            print("You should send something")
        } else {
            setUpMessage()
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let recipient = self.friends[indexPath.row]
        
        if cell?.accessoryType == .checkmark {
            // already selected, uncheck
            cell?.accessoryType = .none
            if let index = recipients.index(of: recipient.objectId!) {
                self.recipients.remove(at: index)
                self.outgoingUsers.remove(at: index)
                
                print(recipients)
                
            }
            
        } else {
            // isn't selected, check
            cell?.accessoryType = .checkmark
            
            self.recipients.append(recipient.objectId!)
            self.outgoingUsers.append(recipient)
            
            print(recipients)

        }
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension NewMessageTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        cancel()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            // photo
            self.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        } else {
            // video
            videoFilePath = (info[UIImagePickerControllerMediaURL] as! URL).path
            UISaveVideoAtPathToSavedPhotosAlbum(videoFilePath, nil, nil, nil)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


// MARK: - Resize Image

extension NewMessageTableViewController {
    func resizeImage(_ originalImage: UIImage) -> UIImage {
        let height: CGFloat = 480.0
        let ratio = image.size.width / image.size.height
        let width = height * ratio
        
        let newSize = CGSize(width: width, height: height)
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        originalImage.draw(in: newRectangle)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}


