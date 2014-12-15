//
//  GRGFeedAPIController.h
//  QualificationFeedChallenge
//
//  Created by Greg on 09/12/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRGAPIController : NSObject
/**
 *  Hit the web endpoint for the FeedItems, store them in Core Data and return
 *  on the Main Thread with the saved NSManagedObjects.
 *  @param completion
 *  The block that will be called on the Main Thread once the operations are complete
*/
- (void) downloadAndStoreEntitiesWithCompletion:(void (^)(NSError* error, NSArray* qualificationsArray))completion;
- (NSDate*) apiLastModifiedDate;
@end
