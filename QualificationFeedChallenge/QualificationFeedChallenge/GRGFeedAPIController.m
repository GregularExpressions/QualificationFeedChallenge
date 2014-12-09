//
//  GRGFeedAPIController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGFeedAPIController.h"
#import "GRGCoreDataController.h"

static NSString* kFeedItemAPIEndPoint = @"http://challenge.superfling.com";
static NSString* kFeedPhotoAPIEndPoint = @"http://challenge.superfling.com/photos/";

@implementation GRGFeedAPIController
- (void) downloadAndStoreFeedItemsWithCompletion:(void (^)(NSError* error, NSArray* feedItems))completion
{
    // On cold launch the user will be waiting for this, so it's high priority.
    // Given the simplicity of the download we can avoid anything more complex
    // like a dedicated dispatch queue or NSOperationQueue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSManagedObjectContext* backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
        __block NSArray* managedObjects = [[GRGCoreDataController sharedController] getAllFeedItemsOnManagedObjectContext:backgroundContext];
        
        if (managedObjects && managedObjects.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSManagedObjectContext* mainThreadContext = [[GRGCoreDataController sharedController] managedObjectContext];
                managedObjects = [[GRGCoreDataController sharedController] moveManagedObjects:managedObjects toContext:mainThreadContext];
                completion(nil,managedObjects);
            });
        } else {
            // We don't have the data already, download:
            NSArray* results = [self downloadJSON];
            
            if (results) {
                
                NSManagedObjectContext* backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
                __block NSArray* managedObjects = [self createAndReturnFeedItemsFromParsedJSON:results onContext:backgroundContext];
                // TODO: Handle Core Data save errors:
                [[GRGCoreDataController sharedController] save:nil onContext:backgroundContext isBackgroundContext:YES];
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSManagedObjectContext* mainThreadContext = [[GRGCoreDataController sharedController] managedObjectContext];
                        managedObjects = [[GRGCoreDataController sharedController] moveManagedObjects:managedObjects toContext:mainThreadContext];
                        completion(nil,managedObjects);
                    });
                }
                
            } else {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,nil);
                    });
                }
            }
        }
    });
}

#pragma mark - NSManagedObjects
- (NSArray*) createAndReturnFeedItemsFromParsedJSON:(NSArray*)parsedJSON onContext:(NSManagedObjectContext*)context
{
    NSMutableArray* managedObjects = [NSMutableArray array];
    for (NSDictionary* dict in parsedJSON) {
        FeedItem* newFeedItem = [[GRGCoreDataController sharedController] getNewFeedItemOnManagedObjectContext:context];
        dict[@"ID"] ? newFeedItem.feedID = dict[@"ID"] : nil;
        dict[@"ImageID"] ? newFeedItem.imageID = dict[@"ImageID"] : nil;
        dict[@"ImageID"] ? newFeedItem.imageURL = [NSString stringWithFormat:@"%@%@",kFeedPhotoAPIEndPoint,dict[@"ImageID"]] : nil;
        dict[@"Title"] ? newFeedItem.title = dict[@"Title"] : nil;
        dict[@"UserID"] ? newFeedItem.userID = dict[@"UserID"] : nil;
        dict[@"UserName"] ? newFeedItem.userName = dict[@"UserName"] : nil;
        [managedObjects addObject:newFeedItem];
    }
    return managedObjects;
}

#pragma mark - JSON
- (NSArray*) downloadJSON
{
    // Hit the endpoint for data:
    NSHTTPURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:kFeedItemAPIEndPoint];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    NSError* connectionError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    NSMutableArray *result;
    if (!connectionError && responseData) {
        // Parse the response:
        result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        for (NSMutableDictionary *dic in result)
        {
            NSString *string = dic[@"array"];
            if (string)
            {
                NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
                dic[@"array"] = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
        }
    } else {
        NSLog(@"Error downloading content from %@: %@",kFeedItemAPIEndPoint,connectionError);
        // TODO: Handle obvious errors like timeouts, lack of connectivity and report to the user.
    }
    
    return result;
}

#pragma mark - Stats

+ (void) calculateAndOutputStats
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext* backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
        NSArray* feedImageItems = [[GRGCoreDataController sharedController] getAllFeedImageItemsOnManagedObjectContext:backgroundContext];
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        NSMutableDictionary* userToImageSizesDictionary = [NSMutableDictionary dictionary];
        for (FeedImageItem* imageItem in feedImageItems) {
            
            // Collect all the sizes per user in their own dictionary -> array structure:
            NSMutableArray* userToImageSlice = userToImageSizesDictionary[imageItem.username];
            if (!userToImageSlice) {
                userToImageSlice = [NSMutableArray array];
            }
            [userToImageSlice addObject:imageItem.imageFileSize];
            [userToImageSizesDictionary setObject:userToImageSlice forKey:imageItem.username];
            
            NSMutableDictionary* statsSlice = statsDictionary[imageItem.username];
            if (!statsSlice) {
                statsSlice = [NSMutableDictionary dictionary];
                //[statsSlice setObject:imageItem.username forKey:@"username"];
                [statsSlice setObject:@(0) forKey:@"greatestPhotoWidth"];
                [statsSlice setObject:@(0) forKey:@"totalPosts"];
            }
            
            NSInteger currentPostsCounts = [statsSlice[@"totalPosts"] integerValue];
            [statsSlice setObject:@(currentPostsCounts+1) forKey:@"totalPosts"];
            
            if ([statsSlice[@"greatestPhotoWidth"]floatValue] < imageItem.imageWidth.floatValue) {
                [statsSlice setObject:imageItem.imageWidth forKey:@"greatestPhotoWidth"];
            }
            
            [statsDictionary setObject:statsSlice forKey:imageItem.username];
        }
        
        [userToImageSizesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* username, NSArray* imageSizes, BOOL *stop) {
            
            float averageImageSize = 0;
            __block float combinedImageSizes = 0;
            for (NSNumber* imageSizeNumber in imageSizes) {
                combinedImageSizes += imageSizeNumber.floatValue;
            }
            averageImageSize = round(combinedImageSizes/imageSizes.count);
            
            NSMutableDictionary* statsDictionarySlice = statsDictionary[username];
            [statsDictionarySlice setObject:@(averageImageSize) forKey:@"averageImageSize"];
            
        }];
        
        
        NSLog(@"statsDictionary = %@",statsDictionary);
    });
    
}

@end
