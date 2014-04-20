//
//  VitalsViewController.h
//  Outlander
//
//  Created by Joseph McBride on 2/3/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyView.h"

@interface VitalsViewController : NSViewController

@property (strong) IBOutlet MyView *backgroundView;

-(void)updateValue:(NSString *)key text:(NSString*)text value:(float)value;

@end
