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
 * On a background thread hit the API to confirm last modified, optionally
 * update Core Data and return Main Thread NSManagedObjects.
 */
- (void) getDataWithCompletion:(void (^)(NSError* error, NSArray* qualificationsArray))completion;
@end
