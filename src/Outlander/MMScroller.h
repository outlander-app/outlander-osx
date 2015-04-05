//
//  MMScroller.h
//  MiniMail
//
//  Created by DINH Viêt Hoà on 21/02/10.
//  Copyright 2011 Sparrow SAS. All rights reserved.
//
// http://dinhviethoa.tumblr.com/post/6138273608/ios-style-scrollbars-for-nsscrollview

IB_DESIGNABLE
@interface MMScroller : NSScroller {
	int _animationStep;
	float _oldValue;
	BOOL _scheduled;
	BOOL _disableFade;
    BOOL _shouldClearBackground;
}

@property (nonatomic, assign) BOOL shouldClearBackground;

@property (nonatomic, strong) IBInspectable NSColor *backgroundColor;

- (void) showScroller;

@end
