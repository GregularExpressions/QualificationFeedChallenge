//
//  ViewController.m
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGQualificationViewController.h"
#import "GRGAPIController.h"
#import "GRGQualificationTableViewCell.h"
#import "Qualification.h"
#import "GRGSubjectsViewController.h"

@interface GRGQualificationViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) UITableView* qualificationsTableView;
@property (nonatomic,strong) UIActivityIndicatorView* activityView;
@property (nonatomic,strong) NSArray* tableQualifications;
@end

static NSString* kQualificationCellReuseIdentifier = @"kQualificationCellReuseIdentifier";

@implementation GRGQualificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.qualificationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                       self.view.frame.size.height,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height)
                                                      style:UITableViewStylePlain];
    self.qualificationsTableView.delegate = self;
    self.qualificationsTableView.dataSource = self;
    [self.qualificationsTableView registerClass:[GRGQualificationTableViewCell class] forCellReuseIdentifier:kQualificationCellReuseIdentifier];
    [self.qualificationsTableView setRowHeight:kTableViewCellHeight];
    [self.view addSubview:self.qualificationsTableView];
    
    GRGAPIController* apiController = [[GRGAPIController alloc] init];
    __weak GRGQualificationViewController* weakSelf = self;
    [apiController getDataWithCompletion:^(NSError *error, NSArray *qualificationsArray) {
        weakSelf.tableQualifications = qualificationsArray;
        [weakSelf.qualificationsTableView reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.qualificationsTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }];
    
    self.title = @"Qualifications";
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
    return self.tableQualifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GRGQualificationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kQualificationCellReuseIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    Qualification* qualification = self.tableQualifications[indexPath.row];
    [cell setNameText:qualification.name];
    [cell setSubjectCount:[NSString stringWithFormat:@"%@",@(qualification.subjectsForQualification.count)]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Qualification* qualification = self.tableQualifications[indexPath.row];
    GRGSubjectsViewController* subjectsViewController = [[GRGSubjectsViewController alloc] initWithQualification:qualification];
    [self.navigationController pushViewController:subjectsViewController animated:YES];
}

@end
