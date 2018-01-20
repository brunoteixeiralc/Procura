//
//  UIImageView+DownloadImage.swift
//  procura
//
//  Created by Bruno Corrêa on 16/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreImage

extension UIImageView{
    
    func loadImage(url: URL, thumbnail:Bool) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url,completionHandler: { [weak self] url, response, error in
            if error == nil, let url = url,let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        if thumbnail{
                            weakSelf.image = image
                        }else{
                           weakSelf.image = self?.blurEffect(image: image)
                        }
                    }
                 }
            }
        })

        downloadTask.resume()
        return downloadTask
    }
    
    func blurEffect(image:UIImage) -> UIImage {
        
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: image)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
    }
}
