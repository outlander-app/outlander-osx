//
//  WindowDataService.m
//  Outlander
//
//  Created by Joseph McBride on 5/1/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "WindowDataService.h"
#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Outlander-Swift.h"

@implementation WindowDataService

- (NSDictionary *)jsonFor:(WindowData *)data {
    
    return [MTLJSONAdapter JSONDictionaryFromModel:data];
}

- (WindowData *)dataFor:(NSDictionary *)json {
    WindowData *data = [MTLJSONAdapter modelOfClass:[WindowData class]
                     fromJSONDictionary:json
                                  error:nil];
    
    if (!data.fontName) {
        data.fontName = @"Helvetica";
        data.fontSize = 14;
    }
    
    if (!data.monoFontName) {
        data.monoFontName = @"Menlo";
        data.monoFontSize = 13;
    }
    
    return data;
}

- (Layout *)readLayoutJson:(GameContext *)context {
    
    NSString *filePath = [self get:context FilePath:@"layout.cfg"];
    NSData *json = [NSData dataWithContentsOfFile:filePath];
    
    if(!json) {
        return [self defaultData];
    }
    
    NSError *error;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:json
                                                            options:kNilOptions
                                                              error:&error];
    if(error) {
        return [self defaultData];
    }
   
    @try {
        Layout *layout = [[Layout alloc] init];
    
        layout.primaryWindow = [self dataFor:[jsonResponse valueForKey:@"primary"]];
        
        NSArray *jsonWindows = [jsonResponse valueForKey:@"windows"];
        
        layout.windows = [jsonWindows.rac_sequence  map:^id(id value) {
            return [self dataFor:value];
        }].array;
        
        return layout;
    }
    @catch (NSException *exception) {
        return [self defaultData];
    }
}

- (void)write:(GameContext *)context LayoutJson:(Layout *)layout {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[self jsonFor:layout.primaryWindow] forKey:@"primary"];
    
    NSArray *windows = [layout.windows.rac_sequence map:^id(WindowData *value) {
        return [self jsonFor:value];
    }].array;
    [dict setValue:windows forKey:@"windows"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:kNilOptions
                                                         error:nil];
    NSString *filePath = [self get:context FilePath:@"layout.cfg"];
    [jsonData writeToFile:filePath atomically:YES];
}

- (NSDictionary *)jsonForLayout:(Layout *)layout {
    return [MTLJSONAdapter JSONDictionaryFromModel:layout];
}

- (Layout *)defaultData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:[WindowData windowWithName:@"main" atLoc:NSMakeRect(0, 100, 574, 377) andTimestamp:NO]];
    [items addObject:[WindowData windowWithName:@"thoughts" atLoc:NSMakeRect(0, 0, 361, 101) andTimestamp:YES]];
    [items addObject:[WindowData windowWithName:@"logons" atLoc:NSMakeRect(360, 0, 214, 101) andTimestamp:YES]];
    [items addObject:[WindowData windowWithName:@"death" atLoc:NSMakeRect(573, 0, 275, 101) andTimestamp:YES]];
    [items addObject:[WindowData windowWithName:@"room" atLoc:NSMakeRect(573, 100, 275, 177) andTimestamp:NO]];
    [items addObject:[WindowData windowWithName:@"experience" atLoc:NSMakeRect(573, 276, 275, 201) andTimestamp:NO]];
    
    WindowData *assess = [WindowData windowWithName:@"assess" atLoc:NSMakeRect(0, 0, 200, 200) andTimestamp:NO];
    assess.visible = NO;
    assess.closedTarget = @"main";
    [items addObject:assess];
    
    WindowData *chatter = [WindowData windowWithName:@"chatter" atLoc:NSMakeRect(0, 0, 200, 200) andTimestamp:YES];
    chatter.visible = NO;
    chatter.closedTarget = @"main";
    [items addObject:chatter];
    
    Layout *layout = [[Layout alloc] init];
    layout.primaryWindow = [WindowData windowWithName:@"primary" atLoc:NSMakeRect(0, 0, 900, 615) andTimestamp:NO];
    layout.windows = items;
    
    return layout;
}

-(NSString *)get:(GameContext *)context FilePath:(NSString *)fileName {
    
    return [context.pathProvider.profileFolder stringByAppendingPathComponent:fileName];
}

@end
