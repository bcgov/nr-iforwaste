//
//  exportUserDataDAO.m
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "ExportUserDataDAO.h"

@implementation ExportUserDataDAO

+(NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

+(ExportUserData *) getExportUserData {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    [context save:&error];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExportUserData" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count > 0) {
        return result[0];
    } else {
        return nil;
    }
}

+(ExportUserData *) createEmptyExportUserData {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    ExportUserData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExportUserData" inManagedObjectContext:context];
    
    return data;
}

@end
