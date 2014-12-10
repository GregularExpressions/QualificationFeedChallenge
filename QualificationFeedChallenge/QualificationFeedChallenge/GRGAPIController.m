//
//  GRGFeedAPIController.m
//  PhotoFeedChallenge
//
//  Created by Greg on 08/11/2014.
//  Copyright (c) 2014 Greg Gunner. All rights reserved.
//

#import "GRGAPIController.h"
#import "GRGCoreDataController.h"

static NSString* kAPIEndPoint = @"https://api.gojimo.net/api/v4/qualifications";

@implementation GRGAPIController
- (void) downloadAndStoreEntitiesWithCompletion:(void (^)(NSError* error, NSArray* qualificationsArray))completion
{
    // On cold launch the user will be waiting for this, so it's high priority.
    // Given the simplicity of the download we can avoid anything more complex
    // like a dedicated dispatch queue or NSOperationQueue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSManagedObjectContext* backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
        __block NSArray* managedObjects = [[GRGCoreDataController sharedController] getAllQualificationsOnManagedObjectContext:backgroundContext];
        
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
                __block NSArray* managedObjects = [self createAndReturnQualificationsFromParsedJSON:results onContext:backgroundContext];
                managedObjects = [managedObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
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
- (NSArray*) createAndReturnQualificationsFromParsedJSON:(NSArray*)parsedJSON onContext:(NSManagedObjectContext*)context
{
    NSMutableArray* managedObjects = [NSMutableArray array];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // 2014-04-12T10:06:33.000Z
    
    for (NSDictionary* dict in parsedJSON) {
        
        Qualification* newQualification = [[GRGCoreDataController sharedController] getNewQualificationItemOnManagedObjectContext:context];
        newQualification.qualificationID = dict[@"id"];
        newQualification.name = dict[@"name"];
        newQualification.link = dict[@"link"];
        newQualification.createdDate = [dateFormatter dateFromString:dict[@"created_at"]];
        newQualification.updatedDate = [dateFormatter dateFromString:dict[@"updated_at"]];

        if (dict[@"subjects"] && [dict[@"subjects"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* subjectDict in dict[@"subjects"]) {
                Subject* newSubject = [[GRGCoreDataController sharedController] getNewSubjectOnManagedObjectContext:context];
                newSubject.subjectID = subjectDict[@"id"];
                newSubject.title = subjectDict[@"title"];
                newSubject.link = subjectDict[@"link"];
                dict[@"colour"] ? newSubject.colour = dict[@"colour"] : nil;
                [newQualification addSubjectsForQualificationObject:newSubject];
            }
        }
        
        [managedObjects addObject:newQualification];
    }
    return managedObjects;
}

#pragma mark - JSON
- (NSArray*) downloadJSON
{
    // Hit the endpoint for data:
    NSHTTPURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:kAPIEndPoint];
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
        NSLog(@"Error downloading content from %@: %@",kAPIEndPoint,connectionError);
        // TODO: Handle obvious errors like timeouts, lack of connectivity and report to the user.
    }
    
    return result;
}

@end
