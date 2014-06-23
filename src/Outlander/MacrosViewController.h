//
//  MacrosViewController.h
//  Outlander
//
//  Created by Joseph McBride on 6/21/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "GameContext.h"
#import "SettingsView.h"
#import "Macro.h"

@interface MacrosViewController : NSViewController <NSTableViewDataSource, SettingsView>

@property (nonatomic, strong) Macro *selectedMacro;

@end
