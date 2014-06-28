//
//  TextViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/27/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TextTag.h"
#import "NSColor+Categories.h"
#import "MyNSTextView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GameContext.h"

@interface TextViewController : NSViewController <NSTextStorageDelegate>

@property (nonatomic, strong) GameContext *gameContext;
@property (nonatomic, strong) RACSignal *keyup;
@property (nonatomic, copy) NSString *key;
@property (unsafe_unretained) IBOutlet MyNSTextView *TextView;

- (NSString *)text;
- (void)clear;
- (BOOL)endsWith:(NSString*)value;
- (void)append:(TextTag*)text;
@end
