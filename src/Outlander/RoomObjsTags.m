//
//  RoomObjsTags.m
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import "RoomObjsTags.h"
#import "NSString+Categories.h"

@implementation RoomObjsTags

- (NSArray *)tagsForRoomObjs:(NSString *)data {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    __block NSUInteger loc = 0;
    
    NSArray *matches = [data matchesForPattern:@"<pushbold><\\/pushbold>(.*?)<popbold><\\/popbold>"];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *res, NSUInteger idx, BOOL *stop) {
        if(res.numberOfRanges > 1) {
            NSRange rng = [res rangeAtIndex:0];
            NSRange newRng = NSMakeRange(loc, rng.location - loc);
            loc = rng.location + rng.length;
            TextTag *tag = [TextTag tagFor:[data substringWithRange:newRng] mono:false];
            [arr addObject:tag];
            
            NSString * name = [data substringWithRange:[res rangeAtIndex:1]];
            tag = [TextTag tagFor:name mono:false];
            tag.color = @"#FFFF00";
            tag.bold = YES;
            [arr addObject:tag];
        }
    }];
    
    if(loc < data.length) {
        NSRange rng = NSMakeRange(loc, data.length - loc);
        TextTag *tag = [TextTag tagFor:[data substringWithRange:rng] mono:false];
        [arr addObject:tag];
    }
    
    return arr;
}

@end
