//
//  GRGQualificationTableViewCell.h
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 10/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kTableViewCellHeight = 44.0f;
@interface GRGQualificationTableViewCell : UITableViewCell
- (void) setNameText:(NSString*)name;
- (void) setSubjectCount:(NSString*)subjectCount;
@end
