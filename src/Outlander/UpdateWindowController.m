//
//  UpdateWindowController.m
//  Outlander
//
//  Created by Joseph McBride on 3/10/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

#import "UpdateWindowController.h"

@interface UpdateWindowController () {
    SQRLUpdater *_updater;
    SQRLUpdate *_updateInfo;
    __weak IBOutlet NSTextField *_about;
    __unsafe_unretained IBOutlet NSTextView *_notes;
}
@end

@implementation UpdateWindowController

- (id)init {
	self = [super initWithWindowNibName:NSStringFromClass([self class]) owner:self];
	if(self == nil) return nil;

    return self;
}

-(void)awakeFromNib {
    [_notes setTextContainerInset:NSMakeSize(12, 15)];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    NSDictionary *dict = [[NSBundle bundleForClass:self.class] infoDictionary];
    NSString *version = dict[@"CFBundleShortVersionString"];

    NSString *about = [NSString stringWithFormat:@"%@ is now available.  You are currently using version %@.  Relaunch the application to start using the new version.", _updateInfo.releaseName, version];
    [_about setStringValue:about];

    NSString *notes = @"";

    if(_updateInfo.releaseNotes != nil) {
        notes = _updateInfo.releaseNotes;
    }

    [_notes setString:notes];
}

- (void)setUpdater:(SQRLUpdater *)updater with:(SQRLUpdate *)updateInfo {
    _updater = updater;
    _updateInfo = updateInfo;
}

- (IBAction)relaunch:(id)sender {
    [_updater relaunchToInstallUpdate];
}

- (IBAction)later:(id)sender {
    [self close];
}

@end
