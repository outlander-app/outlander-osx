//
//  KeyHandler.h
//  Outlander
//
//  Created by Joseph McBride on 6/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

@protocol KeyHandler <NSObject>

- (BOOL)handle:(NSEvent *)theEvent;

@end
