//
//  ObjC.h
//  Outlander
//
//  Created by Joseph McBride on 4/7/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
