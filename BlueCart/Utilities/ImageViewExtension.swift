//
//  ImageViewExtension.swift
//  BlueCart
//
//  Created by David Rothschild on 11/7/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

/// Handle loading image from network or from cache
/// Avoid image flickering
/// Overview:
///  - Keep track of current URLSessionTask from last task
///  - Track current URL being requested
///  - When starting a new request, can cancel any prior request
///  - When updating the image view, check that the URL associated with the image matches current image
extension UIImageView {
    
    private static var taskKey = 0
    private static var urlKey = 0
    
    // MARK: - Computed properties
    /// Add new properties to existing class
    /// Using associated object API to assocate these properties with UIImage object
    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Computed property
    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Functions
    func loadImageAsync(with urlString: String?) {
        
        /// Cancel prior task, if any
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        /// Reset imageview's image
        self.image = nil
        
        /// Allow supplying of `nil` to remove old image and then return immediately
        guard let urlString = urlString else { return }
        
        /// Check cache for image
        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            self.image = cachedImage
            
            return
        }
        
        /// Download image because it was not in the cache
        let url = URL(string: urlString)!
        currentURL = url
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil
            
            /// Error handling
            if let error = error {
                
                /// Don't report cancelation errors
                if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                print(error)
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Unable to extract the image")
                return
            }
            
            /// Save downloaded image to cache
            ImageCache.shared.save(image: downloadedImage, forKey: urlString)
            
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.image = downloadedImage
                }
            }
        }
        
        /// Save and start new task
        currentTask = task
        task.resume()
    }
}
