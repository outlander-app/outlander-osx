//
//  CharacterViewModel.h
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharacterViewModel : NSObject

@property (nonatomic, copy) NSString *lefthand;
@property (nonatomic, copy) NSString *righthand;
@property (nonatomic, copy) NSString *spell;
@property (nonatomic, assign) NSUInteger *roundtime;
-(id)init;

@end
