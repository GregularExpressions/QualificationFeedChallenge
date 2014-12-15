//
//  UIColor+HexColor.h
//  QualificationFeedChallenge
//
//  Created by Greg on 15/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end
