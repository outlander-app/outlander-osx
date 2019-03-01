//
//  Regex.h
//  Outlander
//
//  Created by Joseph McBride on 2/25/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Regex : NSObject

+(NSArray<NSTextCheckingResult *> *) matchesForString:(NSString *)value with:(NSString *)pattern;

@end
