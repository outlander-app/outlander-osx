//
//  TestViewController.m
//  Outlander
//
//  Created by Joseph McBride on 1/22/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "TestViewController.h"
#import "VitalsViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "TextTag.h"
#import "NSString+Categories.h"
#import "NSColor+Categories.h"
#import "MyView.h"
#import "NSView+Categories.h"
#import "Vitals.h"
#import "ExpTracker.h"
#import "WindowDataService.h"
#import "AppSettingsLoader.h"
#import "Roundtime.h"
#import "RoundtimeNotifier.h"
#import "SpelltimeNotifier.h"
#import "CommandProcessor.h"
#import "GameCommandProcessor.h"
#import "VariableReplacer.h"
#import "LocalFileSystem.h"
#import "CommandContext.h"
#import <ReactiveCocoa/EXTScope.h>
#import "RoomObjsTags.h"
#import "Outlander-Swift.h"
#import <MASShortcut/MASShortcut.h>
#import <MASShortcut/MASShortcutMonitor.h>

@interface TestViewController ()
@end

@implementation TestViewController {
    GameContext *_gameContext;
    ScriptRunner *_scriptRunner;
    NotifyMessage *_notifier;
    VitalsViewController *_vitalsViewController;
    ExpTracker *_expTracker;
    RoundtimeNotifier *_roundtimeNotifier;
    SpelltimeNotifier *_spelltimeNotifier;
    id<CommandProcessor> _commandProcessor;
    VariableReplacer *_variablesReplacer;
    BOOL _isApplicationActive;
}

-(id)initWithContext:(GameContext *)gameContext {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _gameContext = gameContext;
    
    @weakify(self)
    
    _notifier = [NotifyMessage newInstance];
    _notifier.messageBlock = ^(TextTag *tag){
        @strongify(self)
        [self append:tag to:@"main"];
    };
    _notifier.commandBlock = ^(CommandContext *command){
        command.command = [command.command trimWhitespaceAndNewline];
        [_commandProcessor process:command];
    };
    _notifier.echoBlock = ^(NSString *echo){
        @strongify(self)
        TextTag *tag = [TextTag tagFor:echo mono:YES];
        tag.color = @"00ffff";
        [self append:tag to:@"main"];
    };
    
    _scriptRunner = [ScriptRunner newInstance: _gameContext notifier: _notifier];
    
    _vitalsViewController = [[VitalsViewController alloc] init];
    _windows = [[TSMutableDictionary alloc] initWithName:@"gamewindows"];
    _server = [[AuthenticationServer alloc]init];
    _expTracker = [[ExpTracker alloc] init];
    _roundtimeNotifier = [[RoundtimeNotifier alloc] initWith:_gameContext];
    _spelltimeNotifier = [[SpelltimeNotifier alloc] initWith:_gameContext];
    _variablesReplacer = [[VariableReplacer alloc] init];
    _commandProcessor = [[GameCommandProcessor alloc] initWith:_gameContext and:_variablesReplacer];
    
    [[_commandProcessor.processed subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CommandContext *x) {
        [_gameStream sendCommand:x.command];
        
        TextTag *tag = x.tag;
        if(!tag) {
            NSString *script = x.scriptName.length > 0 ? [NSString stringWithFormat:@"[%@](%d): ", x.scriptName, x.scriptLine+1] : @"";
            
            NSString *prompt = [gameContext.globalVars cacheObjectForKey:@"prompt"];
            prompt = prompt ? prompt : @">";
            tag = [TextTag tagFor:[NSString stringWithFormat:@"%@%@ %@\n",script, prompt, x.command]
                             mono: script.length > 0 ? YES : NO];
            
            if (x.scriptName.length > 0 && tag.color == nil) {
                tag.color = @"#acff2f";
            }
        }
        [self append:tag to:@"main"];
    }];
    
    [_commandProcessor.echoed subscribeNext:^(TextTag *tag) {
        [self append:tag to:@"main"];
    }];
    
    return self;
}

- (void)awakeFromNib {
    _ViewContainer.backgroundColor = [NSColor blackColor];
    _ViewContainer.draggable = NO;
    _ViewContainer.autoresizesSubviews = YES;
    
    [_VitalsView addSubview:_vitalsViewController.view];
    [_vitalsViewController.view fixTopEdge:YES];
    [_vitalsViewController.view fixRightEdge:YES];
    [_vitalsViewController.view fixBottomEdge:NO];
    [_vitalsViewController.view fixLeftEdge:YES];
    [_vitalsViewController.view fixWidth:NO];
    [_vitalsViewController.view fixHeight:NO];
    
    [_gameContext.layout.windows enumerateObjectsUsingBlock:^(WindowData *obj, NSUInteger idx, BOOL *stop) {
        [self addWindow:obj];
    }];
    
    [[_roundtimeNotifier.notification subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(Roundtime *rt) {
        
        self._CommandTextField.progress = rt.percent;
        
        if(rt.value == 0){
            _viewModel.roundtime = @"";
        }
        else {
            _viewModel.roundtime = [NSString stringWithFormat:@"%ld", (long)rt.value];
        }
    }];
    
    [_spelltimeNotifier.notification subscribeNext:^(NSString *val) {
        _viewModel.spell = val;
    }];
   
//    NSMutableArray *tags = [[NSMutableArray alloc] init];
//    
//    TextTag *tag = [TextTag tagFor:@"test\r\n" mono:NO];
//    tag.color = @"#565656";
//    tag.href = @"http://google.com";
//    [self append:tag to:@"main"];
    //[tags addObject:tag];
//
//    tag = [TextTag tagFor:@"123" mono:NO];
//    tag.color = @"#565656";
//    tag.command = @"command:something";
//    [self append:tag to:@"main"];
//    [tags addObject:tag];
//
//    tag = [TextTag tagFor:@"456\n" mono:NO];
//    tag.color = @"#565656";
//    [self append:tag to:@"main"];
//    [tags addObject:tag];
//    
//    tag = [TextTag tagFor:@"789" mono:NO];
//    tag.color = @"#565656";
//    [self append:tag to:@"main"];
//    [tags addObject:tag];
//    
//    [self set:@"room" withTags:tags];
//    [self set:@"thoughts" withTags:tags];
}

- (void)addWindow:(WindowData *)window {
    
    NSRect rect = NSMakeRect(window.x, window.y, window.width, window.height);
    
    TextViewController *controller = [_ViewContainer addView:[NSColor blackColor]
                                                       atLoc:rect
                                                     withKey:window.name];

    controller.fontName = window.fontName;
    controller.fontSize = window.fontSize;
    controller.monoFontName = window.monoFontName;
    controller.monoFontSize = window.monoFontSize;

    [controller setDisplayTimestamp:window.timestamp];
    [controller setShowBorder:window.showBorder];
    controller.gameContext = _gameContext;
    [controller.keyup subscribeNext:^(NSEvent *theEvent) {
        
        if(![__CommandTextField hasFocus]) {
        
            NSString *val = [theEvent charactersIgnoringModifiers];
            
            [__CommandTextField setStringValue:[NSString stringWithFormat:@"%@%@", [__CommandTextField stringValue], val]];
            [__CommandTextField selectText:self];
            [[__CommandTextField currentEditor] setSelectedRange:NSMakeRange([[__CommandTextField stringValue] length], 0)];
        }
    }];
    [_windows setCacheObject:controller forKey:window.name];
}

- (NSArray *)getWindows {
    
    NSArray *windows = [_ViewContainer.subviews.rac_sequence map:^id(MyView *value) {
        TextViewController *controller = [_windows cacheObjectForKey:value.key];
        WindowData *data = [WindowData windowWithName:value.key atLoc:value.frame andTimestamp:[controller displayTimestamp]];
        data.showBorder = value.showBorder;
        data.fontName = controller.fontName;
        data.fontSize = controller.fontSize;
        data.monoFontName = controller.monoFontName;
        data.monoFontSize = controller.monoFontSize;
        return data;
    }].array;
    
    return windows;
}

- (void)command:(NSString *)command {
    if([command isEqualToString:@"connect"]) {
        [self connect:nil];
    }
}

- (IBAction)commandSubmit:(MyNSTextField*)sender {
    
    NSString *command = [sender stringValue];
    if([command length] == 0) return;
    
    if(command.length > 3)
        [sender commitHistory];
    
    [sender setStringValue:@""];
    
    CommandContext *ctx = [[CommandContext alloc] init];
    ctx.command = [command trimWhitespaceAndNewline];
    [_commandProcessor process:ctx];
}

- (void)beginEdit:(NSString*)key {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller beginEdit];
}

- (void)endEdit:(NSString*)key {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller endEdit];
}

- (void)set:(NSString*)key withTags:(NSArray *)tags {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller setWithTags:tags];
}

- (void)clear:(NSString*)key{
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller clear];
}

- (NSString *)textForWindow:(NSString *)key {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    return controller.text;
}

//- (void)appendAll:(NSArray *)tags to:(NSString *)key {
//    [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [self append:obj to:key];
//    }];
//}

- (BOOL)hasWindow:(NSString *)window {
    return [_windows cacheDoesContain:window];
}

- (void)append:(TextTag*)text to:(NSString *)key {
    NSString *prompt = [_gameContext.globalVars cacheObjectForKey:@"prompt"];
    
    TextViewController *controller = [_windows cacheObjectForKey:key];
    
    if([[text.text trimWhitespaceAndNewline] isEqualToString:prompt]) {
        if(![controller endsWith:prompt]){
            [controller append:text];
        }
    }
    else {
        [controller append:text];
    }
}

- (IBAction)connect:(id)sender {
    
    if(![_gameContext.settings isValid]) {
        [self appendError:@"Invalid credentials.  Please provide all required credentials."];
        return;
    }
    
    if(_gameStream) {
        [_gameStream complete];
    }
    
    _gameStream = [[GameStream alloc] initWithContext:_gameContext];
    
    [_gameStream.connected subscribeNext:^(NSString *message) {
        NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@] %@\n", dateFormat, message]
                                mono:true]
                  to:@"main"];
    }];
    
    [_gameStream.roundtime subscribeNext:^(Roundtime *rt) {
        NSString *time = [_gameContext.globalVars cacheObjectForKey:@"gametime"];
        NSString *updated = [_gameContext.globalVars cacheObjectForKey:@"gametimeupdate"];
        
        NSTimeInterval t = [rt.time timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[time doubleValue]]];
        NSTimeInterval offset = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[updated doubleValue]]];
        
        NSTimeInterval diff = t - offset;
        double rounded = ceil(diff);
        
        [_roundtimeNotifier set:rounded];
    }];
    
    [_gameStream.spell.signal subscribeNext:^(NSString *spell) {
        [_spelltimeNotifier set:spell];
    }];
    
    [_gameStream.thoughts subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]: %@\n", timeStamp, tag.text];
        [self append:tag to:@"thoughts"];
    }];
    
    [_gameStream.chatter subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]: %@\n", timeStamp, tag.text];
        [self append:tag to:@"thoughts"];
    }];
    
    [_gameStream.arrivals subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]:%@\n", timeStamp, tag.text];
        [self append:tag to:@"arrivals"];
    }];
    
    [_gameStream.deaths subscribeNext:^(TextTag *tag) {
        NSString *timeStamp = [@"%@" stringFromDateFormat:@"HH:mm"];
        tag.text = [NSString stringWithFormat:@"[%@]:%@\n", timeStamp, tag.text];
        [self append:tag to:@"deaths"];
    }];
    
    [_gameStream.room.signal subscribeNext:^(id x) {
        [self updateRoom];
    }];
    
    [_gameStream.vitals subscribeNext:^(Vitals *vitals) {
        NSLog(@"Vitals: %@", vitals);
        [_vitalsViewController updateValue:vitals.name
                                      text:[[NSString stringWithFormat:@"%@ %hu%%", vitals.name, vitals.value] capitalizedString]
                                     value:vitals.value];
    }];
    [_gameStream.exp subscribeNext:^(SkillExp *skillExp) {
        [_expTracker update:skillExp];
        NSArray *result = [_expTracker.skillsWithExp.rac_sequence map:^id(SkillExp *value) {
            TextTag *tag = [TextTag tagFor:[NSString stringWithFormat:@"%@\r\n", value.description]
                                      mono:true];
            if(value.isNew) {
                tag.color = @"#66FFFF";
            }
            return tag;
        }].array;
        
        NSMutableArray *tags = [[NSMutableArray alloc] initWithArray:result];
        
        if(_expTracker.startOfTracking == nil) {
            _expTracker.startOfTracking = [NSDate date];
        }
        
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:_expTracker.startOfTracking];
        
        unsigned int seconds = (unsigned int)round(secondsBetween);
        NSLog(@"seconds: %u", seconds);
        NSString *trackingFor = [NSString stringWithFormat:@"Tracking for: %02u:%02u:%02u\n",
                            seconds / 3600, (seconds / 60) % 60, seconds % 60];
        
        [tags addObject:[[TextTag alloc] initWith:[NSString stringWithFormat:@"\nTDPs: %@\n", [_gameContext.globalVars cacheObjectForKey:@"tdp"]] mono:YES]];
        [tags addObject:[[TextTag alloc] initWith:trackingFor mono:YES]];
        [tags addObject:[[TextTag alloc] initWith:[@"Last updated: %@\n" stringFromDateFormat:@"hh:mm:ss a"] mono:YES]];
        
        [self set:@"exp" withTags:tags];
    }];
    
    RACSignal *authSignal = [_server connectTo:@"eaccess.play.net" onPort:7900];
    
    [authSignal
     subscribeNext:^(id x) {
         NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@] %@\n", dateFormat, x]
                                mono:true]
                  to:@"main"];
     }
     error:^(NSError *error) {
         NSString *msg = [error.userInfo objectForKey:@"message"];
         [self appendError:msg];
         
         NSString *authMsg = [error.userInfo objectForKey:@"authMessage"];
         if(authMsg) {
             [self appendError:authMsg];
         }
     }
     completed:^{
        [self append:[TextTag tagFor:[@"[%@] disconnected\n" stringFromDateFormat:@"HH:mm"]
                                mono:true]
                  to:@"main"];
    }];
    
    [[[_server authenticate:_gameContext.settings.account
                   password:_gameContext.settings.password
                       game:_gameContext.settings.game
                  character:_gameContext.settings.character]
    flattenMap:^RACStream *(GameConnection *connection) {
        NSLog(@"Connection: %@", connection);
        RACMulticastConnection *conn = [_gameStream connect:connection];
        return [conn.signal deliverOn:[RACScheduler mainThreadScheduler]];
    }]
    subscribeNext:^(NSArray *tags) {
        
        _viewModel.righthand = [NSString stringWithFormat:@"R: %@", [_gameContext.globalVars cacheObjectForKey:@"righthand"]];
        _viewModel.lefthand = [NSString stringWithFormat:@"L: %@", [_gameContext.globalVars cacheObjectForKey:@"lefthand"]];
        
        for (TextTag *tag in tags) {
            if (tag.targetWindow != nil && [self hasWindow:tag.targetWindow]) {
                [self append:tag to:tag.targetWindow];
            } else {
                [self append:tag to:@"main"];
            }
        }
        
    } completed:^{
        [self append:[TextTag tagFor:[@"[%@] disconnected\n" stringFromDateFormat:@"HH:mm"]
                                mono:true]
                  to:@"main"];
        _gameStream = nil;
        
        [self command:@"saveSettings"];
    }];
}

- (void)appendError:(NSString *)msg {
    NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
    [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, msg]
                            mono:true]
              to:@"main"];
}

- (void)updateRoom {
    NSString *name = [_gameContext.globalVars cacheObjectForKey:@"roomtitle"];
    NSString *desc = [_gameContext.globalVars cacheObjectForKey:@"roomdesc"];
    NSString *objects = [_gameContext.globalVars cacheObjectForKey:@"roomobjsorig"];
    NSString *exits = [_gameContext.globalVars cacheObjectForKey:@"roomexits"];
    NSString *players = [_gameContext.globalVars cacheObjectForKey:@"roomplayers"];
    
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    
    NSMutableString *room = [[NSMutableString alloc] init];
    if(name != nil && name.length != 0) {
        TextTag *nameTag = [TextTag tagFor:name mono:false];
        nameTag.color = @"#0000FF";
        [tags addObject:nameTag];
        [room appendString:@"\n"];
    }
    if(desc != nil && desc.length != 0) {
        [room appendFormat:@"%@\n", desc];
        TextTag *tag = [TextTag tagFor:[room copy] mono:false];
        [tags addObject:tag];
        [room setString:@""];
    }
    if(objects != nil && objects.length != 0) {
        RoomObjsTags *builder = [[RoomObjsTags alloc] init];
        NSArray *roomObjs = [builder tagsForRoomObjs:objects];
        [tags addObjectsFromArray:roomObjs];
        [room appendString:@"\n"];
    }
    if(players != nil && players.length != 0) {
        [room appendFormat:@"%@\n", players];
    }
    if(exits != nil && exits.length != 0) {
        [room appendFormat:@"%@\n", exits];
    }
    
    TextTag *tag = [TextTag tagFor:room mono:false];
    [tags addObject:tag];
    
    [self set:@"room" withTags:tags];
}

@end
