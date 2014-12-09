//
//  GRGFeedAPIController.h
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRGFeedAPIController : NSObject
/**
 *  Hit the web endpoint for the FeedItems, store them in Core Data and return
 *  on the Main Thread with the saved NSManagedObjects.
 *  @param completion
 *  The block that will be called on the Main Thread once the operations are complete
*/
- (void) downloadAndStoreFeedItemsWithCompletion:(void (^)(NSError* error, NSArray* feedItems))completion;
+ (void) calculateAndOutputStats;
@end
