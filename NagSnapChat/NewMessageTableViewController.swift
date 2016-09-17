//
//  NewMessageTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class NewMessageTableViewController: FriendsTableViewController
{
    private var image: UIImage!
}

// MARK: - Resize Image

extension NewMessageTableViewController
{
    func resizeImage(originalImage: UIImage) -> UIImage
    {
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


