//
//  GRGCoreDataController.h
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FeedItem.h"
#import "FeedImageItem.h"

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
- (FeedItem*) getNewFeedItemOnManagedObjectContext:(NSManagedObjectContext*)context;
- (NSArray*) getAllFeedItemsOnManagedObjectContext:(NSManagedObjectContext*)context;
- (FeedImageItem*) getNewFeedImageItemOnManagedObjectContext:(NSManagedObjectContext*)context;
- (NSArray*) getAllFeedImageItemsOnManagedObjectContext:(NSManagedObjectContext*)context;
@end
