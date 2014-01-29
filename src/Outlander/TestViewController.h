//
//  TestViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SignalSocket.h"
#import "AuthenticationServer.h"
#import "GameStream.h"
#import "CharacterViewModel.h"
#import "MyView.h"
#import "TSMutableDictionary.h"

@interface TestViewController : NSViewController {
    SignalSocket *signalSocket;
    AuthenticationServer *_server;
    GameStream *_gameStream;
    TSMutableDictionary *_windows;
}
@property (weak) IBOutlet MyView *ViewContainer;
@property (strong) IBOutlet CharacterViewModel *viewModel;
@property (unsafe_unretained) IBOutlet NSTextView *MainTextView;
@property (weak) IBOutlet NSTextField *CommandTextField;
- (IBAction)commandSubmit:(id)sender;
- (IBAction)connect:(id)sender;
@end
