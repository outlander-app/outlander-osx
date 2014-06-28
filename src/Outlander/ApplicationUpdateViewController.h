//
//  ApplicationUpdateViewController.h
//  Outlander
//
//  Created by Joseph McBride on 6/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ApplicationUpdateViewController : NSViewController

@property (nonatomic, strong) RACCommand *okCommand;
@property (nonatomic, strong) RACCommand *relaunchCommand;

@end
