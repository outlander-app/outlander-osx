//
//  UpdateWindowController.h
//  Outlander
//
//  Created by Joseph McBride on 3/10/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Squirrel/Squirrel.h>

@interface UpdateWindowController : NSWindowController

- (void)setUpdater:(SQRLUpdater *)updater with:(SQRLUpdate *)updateInfo;
@end
