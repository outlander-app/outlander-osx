//
//  TestViewController.h
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "AuthenticationServer.h"
#import "GameStream.h"
#import "CharacterViewModel.h"
#import "MyView.h"
#import "TSMutableDictionary.h"
#import "MyNSTextField.h"
#import "GameContext.h"
#import "Commands.h"

@interface TestViewController : NSViewController <Commands> {
    AuthenticationServer *_server;
    GameStream *_gameStream;
    TSMutableDictionary *_windows;
}

-(id)initWithContext:(GameContext *)context;

@property (strong) IBOutlet MyView *VitalsView;
@property (strong) IBOutlet MyNSTextField *_CommandTextField;
@property (weak) IBOutlet MyView *ViewContainer;
@property (strong) IBOutlet CharacterViewModel *viewModel;
@property (unsafe_unretained) IBOutlet NSTextView *MainTextView;

- (NSArray *)getWindows;
- (IBAction)commandSubmit:(id)sender;
- (IBAction)connect:(id)sender;
- (void)append:(TextTag*)text to:(NSString *)key;
- (NSString *)textForWindow:(NSString *)key;
- (void)addWindow:(NSString *)key withRect:(NSRect)rect andTimestamp:(BOOL)timestamp;
@end
