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
@property (nonatomic,strong) UIImageView* colourImageView;
@end

@implementation GRGSubjectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat colourImageX = screenWidth-8-kColourSize;
        
        self.colourImageView = [[UIImageView alloc] initWithFrame:CGRectMake(colourImageX, self.contentView.frame.size.height/2-kColourSize/2, kColourSize, kColourSize)];
        [self.colourImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.colourImageView setBackgroundColor:self.contentView.backgroundColor];
        [self.colourImageView setOpaque:YES];
        [self.contentView addSubview:self.colourImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, colourImageX, self.contentView.frame.size.height)];
        [self.contentView addSubview:self.titleLabel];
        
    }
    return self;
}

- (void)prepareForReuse
{
    [self.colourImageView setImage:nil];
}

- (void) setSubjectTitle:(NSString*)title
{
    [self.titleLabel setText:title];
}

- (void) setSubjectImage:(UIImage*)subjectImage
{
    [self.colourImageView setImage:subjectImage];
}

@end
