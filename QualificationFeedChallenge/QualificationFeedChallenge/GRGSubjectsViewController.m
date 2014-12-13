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
    // Dispose of any resources that can be recreated.
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
