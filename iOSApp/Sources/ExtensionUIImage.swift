//
//  ExtensionUIImage.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/17/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    /**
     A singleton shared NSURL cache used for images from URL
     */
    static var shared: NSCache<AnyObject, AnyObject>! {
        struct StaticSharedCache {
            static var shared: NSCache<AnyObject, AnyObject>? = NSCache()
        }
        
        return StaticSharedCache.shared!
    }
    
    
    // MARK: Image from UIView
    /**
     Creates an image from a UIView.
     
     - Parameter fromView: The source view.
     
     - Returns A new image
     */
    convenience init?(fromView view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        //view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
    
    func imageMasked(_ color : UIColor) -> UIImage?{
        let rect : CGRect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.width)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1, y: -1.0)
        context?.setBlendMode(.hue)
        context?.clip(to: rect, mask: self.cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let tintImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintImage
    }

    // MARK: Crop
    
    /**
     Creates a cropped copy of an image.
     
     - Parameter bounds: The bounds of the rectangle inside the image.
     
     - Returns A new image
     */
    func crop(bounds: CGRect) -> UIImage? {
        return UIImage(cgImage: (self.cgImage?.cropping(to: bounds)!)!,
                       scale: 0.0, orientation: self.imageOrientation)
    }
    
    func cropToSquare() -> UIImage? {
        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        let shortest = min(size.width, size.height)
        
        let left: CGFloat = (size.width > shortest) ? (size.width - shortest) / 2 : 0
        let top: CGFloat = (size.height > shortest) ? (size.height - shortest) / 2 : 0
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let insetRect = rect.insetBy(dx: left, dy: top)
        
        return crop(bounds: insetRect)
    }
    // MARK: Resize
    
    /**
     Creates a resized copy of an image.
     
     - Parameter size: The new size of the image.
     - Parameter contentMode: The way to handle the content in the new size.
     
     - Returns A new image
     */
    func resize(toSize: CGSize, contentMode: UIViewContentMode = .scaleToFill) -> UIImage? {
        let horizontalRatio = size.width / self.size.width;
        let verticalRatio = size.height / self.size.height;
        var ratio: CGFloat!
        
        switch contentMode {
        case .scaleToFill:
            ratio = 1
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            ratio = min(horizontalRatio, verticalRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width * ratio, height: size.height * ratio)
        
        // Fix for a colorspace / transparency issue that affects some types of
        // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        let transform = CGAffineTransform.identity
        
        // Rotate and/or flip the image if required by its orientation
        context?.concatenate(transform);
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality(rawValue: 3)!
        
        //CGContextSetInterpolationQuality(context, CGInterpolationQuality(kCGInterpolationHigh.value))
        
        // Draw into the context; this scales the image
        context?.draw(self.cgImage!, in: rect)
        
        // Get the resized image from the context and a UIImage
        let newImage = UIImage(cgImage: (context?.makeImage()!)!, scale: self.scale, orientation: self.imageOrientation)
        return newImage;
    }
    
    // MARK: Image From URL
    /**
     Creates a new image from a URL with optional caching. If cached, the cached image is returned. Otherwise, a place holder is used until the image from web is returned by the closure.
     
     - Parameter url: The image URL.
     - Parameter placeholder: The placeholder image.
     - Parameter shouldCacheImage: Weather or not we should cache the NSURL response (default: true)
     - Parameter closure: Returns the image from the web the first time is fetched.
     
     - Returns A new image
     */
    class func image(fromURL url: String, placeholder: UIImage, shouldCacheImage: Bool = true, closure: @escaping (_ image: UIImage?) -> ()) -> UIImage? {
        // From Cache
        if shouldCacheImage {
            if let image = UIImage.shared.object(forKey: url as AnyObject) as? UIImage {
                closure(nil)
                return image
            }
        }
        // Fetch Image
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if let nsURL = URL(string: url) {
            session.dataTask(with: nsURL, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    DispatchQueue.main.async {
                        closure(nil)
                    }
                }
                if let data = data, let image = UIImage(data: data) {
                    if shouldCacheImage {
                        UIImage.shared.setObject(image, forKey: url as AnyObject)
                    }
                    DispatchQueue.main.async {
                        closure(image)
                    }
                }
                session.finishTasksAndInvalidate()
            }).resume()
        }
        return placeholder
    }
    func addShadow(blurSize: CGFloat = 6.0) -> UIImage {
        
        let shadowColor = UIColor(white:0.0, alpha:0.8).cgColor
        
        let context = CGContext(data: nil,
                                width: Int(self.size.width + blurSize),
                                height: Int(self.size.height + blurSize),
                                bitsPerComponent: self.cgImage!.bitsPerComponent,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.setShadow(offset: CGSize(width: blurSize/2,height: -blurSize/2),
                          blur: blurSize,
                          color: shadowColor)
        context.draw(self.cgImage!,
                     in: CGRect(x: 0, y: blurSize, width: self.size.width, height: self.size.height),
                     byTiling:false)
        
        return UIImage(cgImage: context.makeImage()!)
    }
}
