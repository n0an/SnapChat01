//
//  PhotoViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

// ***SOLUTION***
// ImageView with scaling, scrolling


class PhotoViewController: UIViewController
{
    
    // MARK: - PROPERTIES
    
    var message: PFObject! {
        didSet {
            startDownloadingPhoto()
        }
    }
    
    
    func startDownloadingPhoto() {
        // Clear imageView
        self.imageView = nil
        
        if self.message != nil {
            let imageFile = self.message["file"] as! PFFile
            imageFile.getDataInBackground(block: { (photoData, error) in
                
                if error == nil {
                    
                    let image = UIImage(data: photoData!)
                    self.imageView = UIImageView(image: image)
                    self.updateUI()
                    
                } else {
                    let alertVC = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alertVC.addAction(okAction)
                    
                    self.present(alertVC, animated: true, completion: nil)
                    

                    print(error)
                }
            })
        }
    }
    
    // MARK: - Photo View Controller Internal
    
    fileprivate var imageView: UIImageView!
    fileprivate var scrollView: UIScrollView!
    
    func updateUI()
    {
        
        let senderName = self.message["senderName"] as! String
        
        title = "Sent by \(senderName)"
        
        // 1
        setUpScrollView()
        
        // 3: set up zoom feature for scroll view
        scrollView.delegate = self
        
        // 6: setup the initial zoom scale for scroll view
        setZoomScaleFor(scrollView.bounds.size)
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        // 8: when the view first loaded, center the image
        recenterImage()
    }
    
    // 10: dealing with device rotation
    override func viewWillLayoutSubviews() {
        
        if imageView != nil && scrollView != nil {
            // 11: when device rotates, we also need to change the size of the image too (by changing zoom scale)
            setZoomScaleFor(scrollView.bounds.size)
            // if the current zoom scale is less than the new min, assign the zoomscale to the min
            if scrollView.zoomScale < scrollView.minimumZoomScale {
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
            
            recenterImage()
        }
    }
    
    // MARK: - Set up scroll view
    
    // 2
    fileprivate func setUpScrollView()
    {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize = imageView.bounds.size
        
        // set up the view hierarchy
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
    }
    //-2
    
    // 5: set up zooming properties for scroll view
    fileprivate func setZoomScaleFor(_ scrollViewSize: CGSize)
    {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        // set up zooming properties
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
    }
    
    // 7: recenter the image
    fileprivate func recenterImage()
    {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size    // need to use frame with respect to the scroll view because bounds.size is always the big size of the original image
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        
        // center the image by using the scroll view content inset
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
    
}

extension PhotoViewController: UIScrollViewDelegate
{
    // 4: implement scroll view delegate method for zooming features
    // which view in the scrollview to zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // 9: when we zoomed in the image, scroll it around, we want to center the image too
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
}
