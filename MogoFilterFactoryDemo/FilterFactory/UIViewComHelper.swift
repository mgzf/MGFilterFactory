//
//  UIViewComHelper.swift
//  MogoPartner
//
//  Created by Harly on 2016/12/21.
//  Copyright © 2016年 mogoroom. All rights reserved.
//

import UIKit
import SDWebImage

class UIViewComHelper: NSObject {

    static func realFontSize (_ font:UIFont? , title:NSString? , maxSize:CGSize) -> CGSize
    {
        let attribute = [NSFontAttributeName:font as AnyObject]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = title?.boundingRect(with: maxSize, options: option , attributes: attribute, context: nil).size
        return size!;
    }
    
    static func setShadowForView (_ view:UIView ,  needCornerRadius:Bool)
    {
        view.makeInsetShadow(withRadius: 5, alpha: 0.1)
        if needCornerRadius
        {
            view.layer.cornerRadius = 5
        }
        
    }
    
    static func setupWebResizeImage(_ originalUrlString:String?,
                                    forImageView imageView:UIImageView,
                                                 withPlaceHoldImage placeHolderImage:String?)
        
    {
        imageView.sd_cancelCurrentImageLoad()
        if let urlString = originalUrlString
        {
            
            let url = URL(string: urlString)
            
            if let placeHolderImageString = placeHolderImage {
                
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: placeHolderImageString), options: .cacheMemoryOnly, completed: { (image, error, type, url) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    guard let finalUrl = url else { return }
                    guard finalUrl.absoluteString == urlString else { return }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    
                    UIView.animate(withDuration: 0.3, animations: { 
                        imageView.alpha = 1
                    }, completion: { (_) in
                        let cutImage = UIImage.cut(realImage, to: imageView.bounds.size)
                        SDWebImageManager.shared().saveImage(toCache: cutImage, for: finalUrl)
                        imageView.image = cutImage
                    })
                })
//                imageView.sd_setImage(with: (url as URL!), placeholderImage: UIImage(named: placeHolderImageString), completed: { (image, error, type, url) in
//                    guard error == nil else { return }
//                    guard let realImage = image else { return }
//                    
//                    guard let finalUrl = url else { return }
//                    
//                    guard finalUrl.absoluteString == urlString else { return }
//                    guard type == .none else { return }
//                    imageView.alpha = 0
//                    UIView.animate(withDuration: 0.3, animations: {
//                        imageView.alpha = 1
//                    }, completion: {  _ in
//                        let cuttImage = UIImage.cut(realImage, to: imageView.bounds.size)
//                        SDWebImageManager.shared().saveImage(toCache: cuttImage, for: finalUrl)
//                        imageView.image = cuttImage
//                    })
//                })
            }
            else
            {
                imageView.sd_setImage(with: url, completed: { (image, error , type, url) in
                    guard error == nil else { return }
                    guard let realImage = image else { return }
                    
                    guard let finalUrl = url else { return }
                    
                    guard finalUrl.absoluteString == urlString else { return }
                    guard type == .none else { return }
                    imageView.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1
                        }, completion: {  _ in
                            let cuttImage = UIImage.cut(realImage, to: imageView.bounds.size)
                            SDWebImageManager.shared().saveImage(toCache: cuttImage, for: finalUrl)
                            imageView.image = cuttImage
                    })
                })
            }
        }
    }
}
