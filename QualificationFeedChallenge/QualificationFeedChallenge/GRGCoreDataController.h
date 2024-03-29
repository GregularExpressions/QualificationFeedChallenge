//
//  GRGCoreDataController.h
//  QualificationFeedChallenge
//
//  Created by Greg on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Qualification.h"
#import "Subject.h"

@interface GRGCoreDataController : NSObject
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
#pragma mark - Singleton
+ (GRGCoreDataController*) sharedController;
#pragma mark - Core Data
/**
 * Create a new NSManagedObjectContext with the main thread context as it's parent context
 */
- (NSManagedObjectContext*) getNewBackgroundManagedObjectContext;
/**
 * Move an array of NSManagedObjects from their existing context to a new one. i.e when
 * you want to bring them to the main thread for UI.
 */
- (NSArray*) moveManagedObjects:(NSArray*)managedObjects toContext:(NSManagedObjectContext*)newContext;
- (BOOL) save:(NSError**)saveError onContext:(NSManagedObjectContext*)context isBackgroundContext:(BOOL)background;
#pragma mark - ManagedObjects:
- (Qualification*) getNewQualificationItemOnManagedObjectContext:(NSManagedObjectContext*)context;
- (NSArray*) getAllQualificationsOnManagedObjectContext:(NSManagedObjectContext*)context;
- (NSArray*) getAllQualificationsOnManagedObjectContext:(NSManagedObjectContext*)context whereQualificationIDIn:(NSArray*)qualificationIDs;
- (Subject*) getNewSubjectOnManagedObjectContext:(NSManagedObjectContext*)context;
- (NSArray*) getAllSubjectOnManagedObjectContext:(NSManagedObjectContext*)context whereSubjectIDIn:(NSArray*)subjectIDs;
@end
