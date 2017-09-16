//
//  ImageDownload.swift
//  MyDeals
//
//  Created by Mathieu Corti on 8/25/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import Foundation
import UIKit

//
// Solution provided by @Leo Dabus to Asynchronously download images from URL
// https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
//

extension UIImageView {

    func downloadAsyncFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
    
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    return
            }
            DispatchQueue.main.async() {
                () -> Void in self.image = image
            }
            }.resume()
    }
    
    func downloadFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        if let data = try? Data(contentsOf: url) {
            self.contentMode = .scaleAspectFit
            self.image = UIImage(data: data)
        }
    }

    func downloadAsyncFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        guard let url = URL(string: link) else {
            return
        }
        downloadAsyncFrom(url: url, contentMode: mode)
    }
    
    func downloadFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        if let url = URL(string: link) {
            downloadFrom(url: url)
        }
        
    }

}

func isValidImageUrl(link: String) -> Bool {
    
    guard let url = URL(string: link), let data = try? Data(contentsOf: url), let _ = UIImage(data: data) else {
        return false
    }
    return true

}
