//
//  ImageCache.swift
//  BlueCart
//
//  Created by David Rothschild on 11/7/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

/// Create cache to store the images for a better user experience
class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol!
    static let shared = ImageCache()
    
    private init() {
        // Purge cache on memory pressure
        observer = NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

