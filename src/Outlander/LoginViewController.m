//
//  LoginViewController.m
//  Outlander
//
//  Created by Joseph McBride on 5/14/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "Outlander-Swift.h"
#import "LoginViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LoginViewController () {
}

@property (weak) IBOutlet NSButton *cancel;
@property (weak) IBOutlet NSButton *connect;
@property (weak) IBOutlet NSTextField *account;
@property (weak) IBOutlet NSTextField *password;
@property (weak) IBOutlet NSTextField *character;
@property (weak) IBOutlet NSComboBox *game;

@end

@implementation LoginViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if(!self) return nil;
    
    return self;
}

-(void)awakeFromNib {
    
    self.cancel.rac_command = self.cancelCommand;
    self.connect.rac_command = self.connectCommand;
    
    [self.account setStringValue:_context.settings.account];
    [self.password setStringValue:_context.settings.password];
    [self.character setStringValue:_context.settings.character];
    [self.game setStringValue:_context.settings.game];
    
    [self.account.rac_textSignal subscribeNext:^(NSString *val) {
        _context.settings.account = val;
        NSLog(@"Account: %@", val);
    }];
    [self.password.rac_textSignal subscribeNext:^(NSString *val) {
        _context.settings.password = val;
        NSLog(@"Password: %@", val);
    }];
    [self.character.rac_textSignal subscribeNext:^(NSString *val) {
        _context.settings.character = val;
        NSLog(@"Character: %@", val);
    }];
    [self.game.rac_textSignal subscribeNext:^(NSString *val) {
        _context.settings.game = val;
        NSLog(@"Game: %@", val);
    }];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSLog(@"Control End: %@", _game.stringValue);
    _context.settings.game = _game.stringValue;
}

@end
