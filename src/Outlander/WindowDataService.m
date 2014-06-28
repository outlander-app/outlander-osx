//
//  WindowDataService.m
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowDataService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation WindowDataService

- (NSDictionary *)jsonFor:(NSString *) windowName Window:(NSRect) location {
    WindowData *data = [WindowData windowWithName:windowName atLoc:location];
    return [self jsonFor:data];
}

- (NSDictionary *)jsonFor:(WindowData *)data {
   
    return [MTLJSONAdapter JSONDictionaryFromModel:data];
}

- (WindowData *)dataFor:(NSDictionary *)json {
    return [MTLJSONAdapter modelOfClass:[WindowData class]
                     fromJSONDictionary:json
                                  error:nil];
}

- (NSArray *)defaultData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:[WindowData windowWithName:@"main" atLoc:NSMakeRect(0, 100, 574, 377)]];
    [items addObject:[WindowData windowWithName:@"thoughts" atLoc:NSMakeRect(0, 0, 361, 101)]];
    [items addObject:[WindowData windowWithName:@"arrivals" atLoc:NSMakeRect(360, 0, 214, 101)]];
    [items addObject:[WindowData windowWithName:@"deaths" atLoc:NSMakeRect(573, 0, 275, 101)]];
    [items addObject:[WindowData windowWithName:@"room" atLoc:NSMakeRect(573, 100, 275, 177)]];
    [items addObject:[WindowData windowWithName:@"exp" atLoc:NSMakeRect(573, 276, 275, 201)]];
    
    return items;
}

- (NSArray *)readWindowJson:(GameContext *)context {
    
    NSString *filePath = [self get:context FilePath:@"layout.cfg"];
    NSData *json = [NSData dataWithContentsOfFile:filePath];
    
    if(!json) {
        return [self defaultData];
    }
    
    NSError *error;
    NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:json
                                                            options:kNilOptions
                                                              error:&error];
    
    if(error || jsonResponse.count == 0) {
        return [self defaultData];
    }
    
    NSArray *items = [jsonResponse.rac_sequence  map:^id(id value) {
        return [self dataFor:value];
    }].array;
    
    return items;
}

- (void)write:(GameContext *)context WindowJson:(NSArray *)windows {
    
    NSArray *items = [windows.rac_sequence map:^id(WindowData *value) {
        return [self jsonFor:value];
    }].array;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:items
                                                       options:kNilOptions
                                                         error:nil];
    NSString *filePath = [self get:context FilePath:@"layout.cfg"];
    [jsonData writeToFile:filePath atomically:YES];
}

-(NSString *)get:(GameContext *)context FilePath:(NSString *)fileName {
    
    return [context.pathProvider.profileFolder stringByAppendingPathComponent:fileName];
}

@end
