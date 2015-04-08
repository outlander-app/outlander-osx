//
//  LoginViewController.h
//  Outlander
//
//  Created by Joseph McBride on 5/14/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@class GameContext;

@interface LoginViewController : NSViewController <NSComboBoxDelegate>

@property (nonatomic, strong) GameContext *context;
@property (nonatomic, strong) RACCommand *cancelCommand;
@property (nonatomic, strong) RACCommand *connectCommand;

@end
