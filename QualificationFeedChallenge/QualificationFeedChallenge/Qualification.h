//
//  Qualification.h
//  QualificationFeedChallenge
//
//  Created by Greg Gunner on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subject;

@interface Qualification : NSManagedObject

@property (nonatomic, retain) NSString * qualificationID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSSet *subjectsForQualification;
@end

@interface Qualification (CoreDataGeneratedAccessors)

- (void)addSubjectsForQualificationObject:(Subject *)value;
- (void)removeSubjectsForQualificationObject:(Subject *)value;
- (void)addSubjectsForQualification:(NSSet *)values;
- (void)removeSubjectsForQualification:(NSSet *)values;

@end
