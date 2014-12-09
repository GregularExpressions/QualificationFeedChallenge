//
//  GRGCoreDataController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGCoreDataController.h"

@implementation GRGCoreDataController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton
+ (GRGCoreDataController*) sharedController
{
    static GRGCoreDataController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

#pragma mark - FeedItem
- (FeedItem*) getNewFeedItemOnManagedObjectContext:(NSManagedObjectContext*)context
{
    FeedItem* newFeedItem = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem" inManagedObjectContext:context];
    return newFeedItem;
}

- (NSArray*) getAllFeedItemsOnManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedItem"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"feedID" ascending:YES]]];
    
    NSError* fetchError;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        NSLog(@"%s : %@",__PRETTY_FUNCTION__,fetchError);
    }
    
    return array;
}

#pragma mark - FeedImageItem
- (FeedImageItem*) getNewFeedImageItemOnManagedObjectContext:(NSManagedObjectContext*)context
{
    FeedImageItem* newFeedImageItem = [NSEntityDescription insertNewObjectForEntityForName:@"FeedImageItem" inManagedObjectContext:context];
    return newFeedImageItem;
}

- (NSArray*) getAllFeedImageItemsOnManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedImageItem"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"imageID" ascending:YES]]];
    
    NSError* fetchError;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        NSLog(@"%s : %@",__PRETTY_FUNCTION__,fetchError);
    }
    
    return array;
}

#pragma mark - Core Data
- (NSManagedObjectContext*) getNewBackgroundManagedObjectContext
{
    NSManagedObjectContext* newContext;
    newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setParentContext:self.managedObjectContext];
    [newContext setUndoManager:nil];
    return newContext;
}

- (NSArray*) moveManagedObjects:(NSArray*)managedObjects toContext:(NSManagedObjectContext*)newContext
{
    NSMutableArray* movedManagedObjects = [NSMutableArray array];
    for (NSManagedObject* managedObject in managedObjects) {
        NSManagedObject* newManagedObject = [newContext objectWithID:managedObject.objectID];
        [movedManagedObjects addObject:newManagedObject];
    }
    return movedManagedObjects;
}

- (NSManagedObjectContext*) managedObjectContext
{

    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        }
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [_managedObjectContext setUndoManager:nil];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoFeedChallenge" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[GRGCoreDataController applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"PhotoFeedChallenge.sqlite"]];
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES,
                              NSFileProtectionKey: NSFileProtectionComplete //UnlessOpen
                              };
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        // TODO: Handle errors properly
        NSLog(@"Error creating persistent store.. %@",error);
    }
    
    return _persistentStoreCoordinator;
}

+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Saving
- (BOOL) save:(NSError**)saveError onContext:(NSManagedObjectContext*)context isBackgroundContext:(BOOL)background
{
    __block NSError *localError;
    if (background) {
        [context performBlockAndWait:^{
            [context save:&localError];
            
            [context.parentContext performBlock:^{
                [context.parentContext save:&*saveError];
            }];
            
        }];
    } else {
        [context save:&localError];
    }
    
    if (localError) {
        NSLog(@"%s SAVE ERROR: %@\n\n",__PRETTY_FUNCTION__,*saveError);
        *saveError = localError;
        return NO;
    }
    
    return YES;
}

@end
