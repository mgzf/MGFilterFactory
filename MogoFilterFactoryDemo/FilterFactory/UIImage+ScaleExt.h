//
//  UIImage+ScaleExt.h
//  Renter
//
//  Created by Harly on 15/8/3.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (ScaleExt)

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage *)cutImage:(UIImage*)image toSize:(CGSize)imageSize;
@end
