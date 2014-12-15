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
static NSString* kAPILastUpdatedDefaultsKey = @"kAPILastUpdatedDefaultsKey";

@implementation GRGAPIController

- (void) getDataWithCompletion:(void (^)(NSError* error, NSArray* qualificationsArray))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Make the HTTP request to the API:
        NSHTTPURLResponse *response;
        NSURL *url = [NSURL URLWithString:kAPIEndPoint];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
        NSError* connectionError;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        NSMutableArray *result;
        __block NSDate* apiLastModifiedDate;
        if (!connectionError && responseData) {
            
            // Extract and Date Format the last modified header:
            NSString* lastModified = response.allHeaderFields[@"Last-Modified"];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss zzz"]; // Fri, 05 Dec 2014 12:28:27 GMT
            apiLastModifiedDate = [dateFormatter dateFromString:lastModified];
            
            // Get our latest modified date out for comparison:
            NSDate* coreDataLastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kAPILastUpdatedDefaultsKey];
            
            // Prep for our core data work:
            NSManagedObjectContext* backgroundContext = [[GRGCoreDataController sharedController] getNewBackgroundManagedObjectContext];
            __block NSArray* qualifications;
            
            // Parse the JSON:
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
            
            // Compare the API's last modified date against our last updated date:
            if ([apiLastModifiedDate timeIntervalSinceDate:coreDataLastUpdateDate] <= 0) {
                // We're up to date, return existing data:
                qualifications = [[GRGCoreDataController sharedController] getAllQualificationsOnManagedObjectContext:backgroundContext];
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSManagedObjectContext* mainThreadContext = [[GRGCoreDataController sharedController] managedObjectContext];
                        qualifications = [[GRGCoreDataController sharedController] moveManagedObjects:qualifications toContext:mainThreadContext];
                        qualifications = [qualifications sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                        completion(nil,qualifications);
                    });
                }
            } else {
                // API has newer data so parse the data:
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
                
                // Create / Update Qualifications and their Subjects:
                qualifications = [self createAndReturnQualificationsFromParsedJSON:result onContext:backgroundContext];
                [[GRGCoreDataController sharedController] save:nil onContext:backgroundContext isBackgroundContext:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSManagedObjectContext* mainThreadContext = [[GRGCoreDataController sharedController] managedObjectContext];
                    qualifications = [[GRGCoreDataController sharedController] moveManagedObjects:qualifications toContext:mainThreadContext];
                    qualifications = [qualifications sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                    completion(nil,qualifications);
                });
                
            }

        } else {
            NSLog(@"Error downloading content from %@: %@",kAPIEndPoint,connectionError);
            // TODO: Handle obvious errors like timeouts, lack of connectivity and report to the user.
        }
        
        // Update our last updated date for next time:
        if (apiLastModifiedDate) {
            [[NSUserDefaults standardUserDefaults] setObject:apiLastModifiedDate forKey:kAPILastUpdatedDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

#pragma mark - NSManagedObjects
- (NSArray*) createAndReturnQualificationsFromParsedJSON:(NSArray*)parsedJSON onContext:(NSManagedObjectContext*)context
{
    NSMutableArray* managedObjects = [NSMutableArray array];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"]; // 2014-04-12T10:06:33.000Z
    
    // Quick short loop to find all the qualificationIDs we'll need to query with:
    NSMutableSet* potentialExistingQualificationIDs = [NSMutableSet set];
    for (NSDictionary* dict in parsedJSON) {
        [potentialExistingQualificationIDs addObject:dict[@"id"]];
    }
    NSArray* existingQualifications = [[GRGCoreDataController sharedController] getAllQualificationsOnManagedObjectContext:context whereQualificationIDIn:potentialExistingQualificationIDs.allObjects];
    
    for (NSDictionary* dict in parsedJSON) {
        
        Qualification* newQualification;
        // Check for existing Qualifications to update:
        for (Qualification* qualification in existingQualifications) {
            if ([qualification.qualificationID isEqualToString:dict[@"id"]]) {
                newQualification = qualification;
                break;
            }
        }
        
        // No existing qualification matching, create a new one:
        if (!newQualification) {
            newQualification = [[GRGCoreDataController sharedController] getNewQualificationItemOnManagedObjectContext:context];
        }
        
        newQualification.qualificationID = dict[@"id"];
        newQualification.name = dict[@"name"];
        newQualification.link = dict[@"link"];
        newQualification.createdDate = [dateFormatter dateFromString:dict[@"created_at"]];
        newQualification.updatedDate = [dateFormatter dateFromString:dict[@"updated_at"]];

        if (dict[@"subjects"] && [dict[@"subjects"] isKindOfClass:[NSArray class]]) {
            
            // Quick short loop to find all the qualificationIDs we'll need to query with:
            NSMutableSet* potentialExistingSubjectIDs = [NSMutableSet set];
            for (NSDictionary* subjectDict in dict[@"subjects"]) {
                [potentialExistingSubjectIDs addObject:subjectDict[@"id"]];
            }
            NSArray* existingSubjects = [[GRGCoreDataController sharedController] getAllSubjectOnManagedObjectContext:context whereSubjectIDIn:potentialExistingSubjectIDs.allObjects];
            
            for (NSDictionary* subjectDict in dict[@"subjects"]) {
                
                Subject* newSubject;
                // Check for existing subject to update:
                for (Subject* subject in existingSubjects) {
                    if ([subject.subjectID isEqualToString:subjectDict[@"id"]]) {
                        newSubject = subject;
                        break;
                    }
                }
                
                // No existing subject matching, create a new one:
                if (!newSubject) {
                    newSubject = [[GRGCoreDataController sharedController] getNewSubjectOnManagedObjectContext:context];
                }
                
                newSubject.subjectID = subjectDict[@"id"];
                newSubject.title = subjectDict[@"title"];
                newSubject.link = subjectDict[@"link"];
                if ([subjectDict[@"colour"] isEqual:[NSNull null]] == NO) {
                    newSubject.colour = subjectDict[@"colour"];
                }
                
                if (!newSubject.qualificationForSubject) {
                    [newQualification addSubjectsForQualificationObject:newSubject];
                }
            }
        }
        
        [managedObjects addObject:newQualification];
    }
    return managedObjects;
}
@end
