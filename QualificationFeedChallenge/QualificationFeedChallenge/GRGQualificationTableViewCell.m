//
//  GRGQualificationTableViewCell.m
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 10/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGQualificationTableViewCell.h"

@interface GRGQualificationTableViewCell ()
@property (nonatomic,strong) UILabel* nameLabel;
@property (nonatomic,strong) UILabel* subjectCountLabel;
@end

@implementation GRGQualificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat subjectCountSize = 30.0f;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, screenWidth-(subjectCountSize*2), kTableViewCellHeight)];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [self.contentView addSubview:self.nameLabel];
        
        self.subjectCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-20-subjectCountSize,
                                                                           kTableViewCellHeight/2-subjectCountSize/2,
                                                                           subjectCountSize,
                                                                           subjectCountSize)];
        [self.subjectCountLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.contentView addSubview:self.subjectCountLabel];
    }
    return self;
}

- (void) setNameText:(NSString*)name
{
    [self.nameLabel setText:name];
}

- (void) setSubjectCount:(NSString*)subjectCount
{
    [self.subjectCountLabel setText:subjectCount];
}

@end
