//
//  ApplicationUpdateViewController.m
//  Outlander
//
//  Created by Joseph McBride on 6/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ApplicationUpdateViewController.h"

@interface ApplicationUpdateViewController ()

@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet NSButton *relaunchButton;

@end

@implementation ApplicationUpdateViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if(!self) return nil;
    
    return self;
}

- (void)awakeFromNib {
    _okButton.rac_command = _okCommand;
    _relaunchButton.rac_command = _relaunchCommand;
}

@end
