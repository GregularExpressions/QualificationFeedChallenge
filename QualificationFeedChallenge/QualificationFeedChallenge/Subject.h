//
//  Subject.h
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Subject : NSManagedObject

@property (nonatomic, retain) NSString * subjectID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * colour;
@property (nonatomic, retain) NSManagedObject *qualificationForSubject;

@end
