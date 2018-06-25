//
//  NSView+Yoga.h
//  YogaKit
//
//  Created by Joseph McBride on 6/17/18.
//  Copyright © 2018 Outlander. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YGLayout.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YGLayoutConfigurationBlock)(YGLayout *layout);

@interface NSView (Yoga)

/**
 The YGLayout that is attached to this view. It is lazily created.
 */
@property (nonatomic, readonly, strong) YGLayout *yoga;
/**
 Indicates whether or not Yoga is enabled
 */
@property (nonatomic, readonly, assign) BOOL isYogaEnabled;

/**
 In ObjC land, every time you access `view.yoga.*` you are adding another `objc_msgSend`
 to your code. If you plan on making multiple changes to YGLayout, it's more performant
 to use this method, which uses a single objc_msgSend call.
 */
- (void)configureLayoutWithBlock:(YGLayoutConfigurationBlock)block
NS_SWIFT_NAME(configureLayout(block:));

- (CGSize)sizeThatfits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
