//
//  UIImage+ScaleExt.m
//  Renter
//
//  Created by Harly on 15/8/3.
//
//

#import "UIImage+ScaleExt.h"

@implementation UIImage (ScaleExt)

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)cutImage:(UIImage*)image toSize:(CGSize)imageSize
{
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < (imageSize.width / imageSize.height)) {
        newSize.width = image.size.width;
        newSize.height = image.size.width * imageSize.height / imageSize.width;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));
        
    } else {
        newSize.height = image.size.height;
        newSize.width = image.size.height * imageSize.width / imageSize.height;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
        
    }
    
    return [UIImage imageWithCGImage:imageRef];
}


@end
