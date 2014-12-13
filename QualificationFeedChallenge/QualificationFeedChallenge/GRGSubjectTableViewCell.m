//
//  GRGSubjectTableViewCell.m
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 12/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGSubjectTableViewCell.h"

@interface GRGSubjectTableViewCell()
@property (nonatomic,strong) UILabel* titleLabel;
@end

@implementation GRGSubjectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, screenWidth, self.contentView.frame.size.height)];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void) setSubjectTitle:(NSString*)title
{
    [self.titleLabel setText:title];
}

@end
