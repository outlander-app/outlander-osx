//
//  ProfileLoader.m
//  Outlander
//
//  Created by Joseph McBride on 5/8/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "ProfileLoader.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Outlander-Swift.h"

@interface ProfileLoader () {
    GameContext *_context;
}
@end

@implementation ProfileLoader

- (id)initWithContext:(GameContext *)context {
    self = [super init];
    if(!self) return nil;
    
    _context = context;
    
    return self;
}

- (void)load {
    
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"config.cfg"];
    
    NSError *error;
    NSString *data = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:&error];
    
    if(!data || error) return;
    
    NSString *gameMatch = [self matchFor:data pattern:@"Game: (.+)"];
    if(gameMatch && gameMatch.length > 0) {
        _context.settings.game = gameMatch;
    }
    NSString *character = [self matchFor:data pattern:@"Character: (.+)"];
    if(character && character.length > 0) {
        _context.settings.character = character;
    }
    
    NSString *account = [self matchFor:data pattern:@"Account: (.+)"];
    if(account && account.length > 0) {
        _context.settings.account = account;
    }
    
    NSString *pw = [self matchFor:data pattern:@"Password: (.+)"];
    if(pw && pw.length > 0) {
        _context.settings.password = pw;
    }
    
    NSString *logging = [self matchFor:data pattern:@"Logging: (.+)"];
    if(logging && logging.length > 0 && ([[logging lowercaseString] hasPrefix:@"yes"] || [[logging lowercaseString] hasPrefix:@"true"])) {
        _context.settings.loggingEnabled = YES;
    }

    NSString *rawLogging = [self matchFor:data pattern:@"RawLogging: (.+)"];
    if(rawLogging && rawLogging.length > 0 && ([[rawLogging lowercaseString] hasPrefix:@"yes"] || [[rawLogging lowercaseString] hasPrefix:@"true"])) {
        _context.settings.rawLoggingEnabled = YES;
    }
}

- (void)save {
    
    NSString *configFile = [_context.pathProvider.profileFolder stringByAppendingPathComponent:@"config.cfg"];
    
    NSMutableString *profile = [[NSMutableString alloc] init];
    [profile appendFormat:@"Account: %@\n", _context.settings.account];
//    [profile appendFormat:@"Password: %@\n", _context.settings.password];
    [profile appendFormat:@"Game: %@\n", _context.settings.game];
    [profile appendFormat:@"Character: %@\n", _context.settings.character];
    [profile appendFormat:@"Logging: %@\n", _context.settings.loggingEnabled ? @"yes" : @"no"];
    [profile appendFormat:@"RawLogging: %@\n", _context.settings.rawLoggingEnabled ? @"yes" : @"no"];
    
    NSData *data = [profile dataUsingEncoding:NSUTF8StringEncoding];
    
    [data writeToFile:configFile atomically:YES];
}

- (NSString *)matchFor:(NSString *)data pattern:(NSString *)pattern {
    
    NSTextCheckingResult *result = [self firstMatchFor:data pattern:pattern];
    
    if(result && result.numberOfRanges > 1) {
        return [data substringWithRange:[result rangeAtIndex:1]];
    }
    
    return @"";
}

- (NSTextCheckingResult *)firstMatchFor:(NSString *)data pattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if(error) {
        NSLog(@"firstMatchFor Error: %@", [error localizedDescription]);
        return nil;
    }
    
    return [regex firstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
}

@end
