//
//  GRGSubjectsViewController.m
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 12/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGSubjectsViewController.h"
#import "GRGSubjectTableViewCell.h"
#import "Subject.h"
#import "UIColor+HexColor.h"

@interface GRGSubjectsViewController ()  <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) UITableView* subjectsTableView;
@property (nonatomic,strong) NSArray* tableSubjects;
@end

static NSString* kSubjectCellReuseIdentifier = @"kSubjectCellReuseIdentifier";

@implementation GRGSubjectsViewController

- (instancetype) initWithQualification:(Qualification*)qualification
{
    self = [super init];
    if (self) {
        if (qualification && qualification.subjectsForQualification) {
            _tableSubjects = qualification.subjectsForQualification.allObjects;
            self.title = qualification.name;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.subjectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)
                                                          style:UITableViewStylePlain];
    self.subjectsTableView.delegate = self;
    self.subjectsTableView.dataSource = self;
    [self.subjectsTableView registerClass:[GRGSubjectTableViewCell class] forCellReuseIdentifier:kSubjectCellReuseIdentifier];
    [self.subjectsTableView setRowHeight:kSubjectTableViewCellHeight];
    [self.view addSubview:self.subjectsTableView];
    [self.subjectsTableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableSubjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GRGSubjectTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kSubjectCellReuseIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    Subject* subject = self.tableSubjects[indexPath.row];
    [cell setSubjectTitle:subject.title];
    
    if (subject.colour && subject.colour.length > 0) {
        UIColor* subjectColor = [UIColor colorFromHexString:subject.colour];
        UIImage* colorImage = [self roundImageOfColour:subjectColor size:CGSizeMake(kColourSize, kColourSize)];
        [cell setSubjectImage:colorImage];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Colours

- (UIImage *) roundImageOfColour:(UIColor*)color size:(CGSize)size
{
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context,circlePath.CGPath);
    CGContextClip(context);
    UIGraphicsPushContext(context);
    
    [color setFill];
    [circlePath fill];
    
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@end
