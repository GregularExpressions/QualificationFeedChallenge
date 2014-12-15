//
//  GRGSubjectTableViewCell.h
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 12/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kSubjectTableViewCellHeight = 44.0f;
static CGFloat kColourSize = 20.0f;
@interface GRGSubjectTableViewCell : UITableViewCell
- (void) setSubjectTitle:(NSString*)title;
- (void) setSubjectImage:(UIImage*)subjectImage;
@end
