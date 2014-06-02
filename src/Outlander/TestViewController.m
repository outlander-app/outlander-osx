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
#import "ScriptRunner.h"
#import "LocalFileSystem.h"
#import "CommandContext.h"
#import "RACEXTScope.h"

@interface TestViewController ()
@end

@implementation TestViewController {
    VitalsViewController *_vitalsViewController;
    ExpTracker *_expTracker;
    AppSettingsLoader *_appSettingsLoader;
    RoundtimeNotifier *_roundtimeNotifier;
    SpelltimeNotifier *_spelltimeNotifier;
    id<CommandProcessor> _commandProcessor;
    VariableReplacer *_variablesReplacer;
    ScriptRunner *_scriptRunner;
}

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self == nil) return nil;
    
    _vitalsViewController = [[VitalsViewController alloc] init];
    _windows = [[TSMutableDictionary alloc] initWithName:@"gamewindows"];
    _server = [[AuthenticationServer alloc]init];
    _expTracker = [[ExpTracker alloc] init];
    _gameContext = [[GameContext alloc] init];
    _appSettingsLoader = [[AppSettingsLoader alloc] initWithContext:_gameContext];
    _roundtimeNotifier = [[RoundtimeNotifier alloc] initWith:_gameContext];
    _spelltimeNotifier = [[SpelltimeNotifier alloc] initWith:_gameContext];
    _variablesReplacer = [[VariableReplacer alloc] init];
    _commandProcessor = [[GameCommandProcessor alloc] initWith:_gameContext and:_variablesReplacer];
    _scriptRunner = [[ScriptRunner alloc] initWith:_gameContext and:[[LocalFileSystem alloc] init]];
    
    [_commandProcessor.processed subscribeNext:^(CommandContext *x) {
        [_gameStream sendCommand:x.command];
        
        TextTag *tag = x.tag;
        if(!tag) {
            NSString *prompt = [_gameContext.globalVars cacheObjectForKey:@"prompt"];
            prompt = prompt ? prompt : @">";
            tag = [TextTag tagFor:[NSString stringWithFormat:@"%@ %@\n", prompt, x.command] mono:NO];
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
    
    [_appSettingsLoader load];
    
    [_gameContext.windows enumerateObjectsUsingBlock:^(WindowData *obj, NSUInteger idx, BOOL *stop) {
        [self addWindow:obj.name withRect:NSMakeRect(obj.x, obj.y, obj.width, obj.height)];
    }];
    
    [_roundtimeNotifier.notification subscribeNext:^(Roundtime *rt) {
        
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
    
    [[_gameContext.globalVars.changed throttle:1.5] subscribeNext:^(id x) {
        [_appSettingsLoader saveVariables];
    }];
    
    [[_gameContext.highlights.changed throttle:1.0] subscribeNext:^(id x) {
        [_appSettingsLoader saveHighlights];
    }];
    
    [[_gameContext.aliases.changed throttle:1.0] subscribeNext:^(id x) {
        [_appSettingsLoader saveAliases];
    }];
}

- (void)addWindow:(NSString *)key withRect:(NSRect)rect {
    
    TextViewController *controller = [_ViewContainer addView:[NSColor blackColor]
                                                       atLoc:rect
                                                     withKey:key];
    controller.gameContext = _gameContext;
    [controller.keyup subscribeNext:^(id x) {
        [__CommandTextField setStringValue:[NSString stringWithFormat:@"%@%@", [__CommandTextField stringValue], x]];
        [__CommandTextField selectText:self];
        [[__CommandTextField currentEditor] setSelectedRange:NSMakeRange([[__CommandTextField stringValue] length], 0)];
    }];
    [_windows setCacheObject:controller forKey:key];
}

- (void)writeWindowJson {
    NSArray *items = [_ViewContainer.subviews.rac_sequence map:^id(MyView *value) {
        return [WindowData windowWithName:value.key atLoc:value.frame];
    }].array;
    
    _gameContext.windows = items;
    
    [_appSettingsLoader saveProfile];
}

- (void)command:(NSString *)command {
    
    if([command isEqualToString:@"saveProfile"]) {
        [self writeWindowJson];
    } else if([command isEqualToString:@"connect"]) {
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
    ctx.command = command;
    
    [_commandProcessor process:ctx];
}

- (void)clear:(NSString*)key{
    TextViewController *controller = [_windows cacheObjectForKey:key];
    [controller clear];
}

- (NSString *)textForWindow:(NSString *)key {
    TextViewController *controller = [_windows cacheObjectForKey:key];
    return controller.text;
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
    
    [_scriptRunner setGameStream:_gameStream];
    
    [_gameStream.connected subscribeNext:^(NSString *message) {
        NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, message]
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
    
    [[_gameStream.room.signal throttle:0.15] subscribeNext:^(id x) {
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
        
        [self clear:@"exp"];
        [result enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
            [self append:item to:@"exp"];
        }];
        [self append:[[TextTag alloc] initWith:[NSString stringWithFormat:@"\nTDPs: %@\n", [_gameContext.globalVars cacheObjectForKey:@"tdp"]] mono:YES] to:@"exp"];
        [self append:[[TextTag alloc] initWith:[@"Last updated: %@\n" stringFromDateFormat:@"hh:mm:ss a"] mono:YES] to:@"exp"];
    }];
    
    RACSignal *authSignal = [_server connectTo:@"eaccess.play.net" onPort:7900];
    
    [authSignal
     subscribeNext:^(id x) {
         NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
        [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, x]
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
        [self append:[TextTag tagFor:[@"[%@ disconnected]\n" stringFromDateFormat:@"HH:mm"]
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
        [conn.signal deliverOn:[RACScheduler mainThreadScheduler]];
        return conn.signal;
    }]
    subscribeNext:^(NSArray *tags) {
        
        _viewModel.righthand = [NSString stringWithFormat:@"R: %@", [_gameContext.globalVars cacheObjectForKey:@"righthand"]];
        _viewModel.lefthand = [NSString stringWithFormat:@"L: %@", [_gameContext.globalVars cacheObjectForKey:@"lefthand"]];
        
        for (TextTag *tag in tags) {
            [self append:tag to:@"main"];
        }
        
    } completed:^{
        [self append:[TextTag tagFor:[@"[%@ disconnected]\n" stringFromDateFormat:@"HH:mm"]
                                mono:true]
                  to:@"main"];
        _gameStream = nil;
    }];
}

- (void)appendError:(NSString *)msg {
    NSString *dateFormat =[@"%@" stringFromDateFormat:@"HH:mm"];
    [self append:[TextTag tagFor:[NSString stringWithFormat:@"[%@ %@]\n", dateFormat, msg]
                            mono:true]
              to:@"main"];
}

-(void)updateRoom {
    NSString *name = [_gameContext.globalVars cacheObjectForKey:@"roomtitle"];
    NSString *desc = [_gameContext.globalVars cacheObjectForKey:@"roomdesc"];
    NSString *objects = [_gameContext.globalVars cacheObjectForKey:@"roomobjs"];
    NSString *exits = [_gameContext.globalVars cacheObjectForKey:@"roomexits"];
    NSString *players = [_gameContext.globalVars cacheObjectForKey:@"roomplayers"];
    
    [self clear:@"room"];
    
    NSMutableString *room = [[NSMutableString alloc] init];
    if(name != nil && name.length != 0) {
        TextTag *nameTag = [TextTag tagFor:name mono:false];
        nameTag.color = @"#0000FF";
        [self append:nameTag to:@"room"];
        [room appendString:@"\n"];
    }
    if(desc != nil && desc.length != 0)
        [room appendFormat:@"%@\n", desc];
    if(objects != nil && objects.length != 0)
        [room appendFormat:@"%@\n", objects];
    if(players != nil && players.length != 0)
        [room appendFormat:@"%@\n", players];
    if(exits != nil && exits.length != 0)
        [room appendFormat:@"%@\n", exits];


    TextTag *tag = [TextTag tagFor:room mono:false];
    [self append:tag to:@"room"];
}

@end
