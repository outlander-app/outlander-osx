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
#import "Commands.h"

@protocol ISubscriber;

@interface TestViewController : NSViewController <Commands, ISubscriber> {
    AuthenticationServer *_server;
    GameStream *_gameStream;
    TSMutableDictionary *_windows;
}

-(id)initWithContext:(GameContext *)context;

@property (strong) IBOutlet NSView *VitalsView;
@property (strong) IBOutlet MyNSTextField *_CommandTextField;
@property (weak) IBOutlet MyView *ViewContainer;
@property (strong) IBOutlet CharacterViewModel *viewModel;
@property (unsafe_unretained) IBOutlet NSTextView *MainTextView;
@property (weak) IBOutlet DirectionsView *directionsView;
@property (weak) IBOutlet MyView *scriptToolbarView;

- (NSArray *)getWindows;
- (IBAction)commandSubmit:(id)sender;
- (IBAction)connect:(id)sender;
- (void)append:(TextTag*)text to:(NSString *)key;
- (NSString *)textForWindow:(NSString *)key;
- (void)addWindow:(WindowData *)window;
@end
