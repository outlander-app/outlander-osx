#import <MASShortcut/MASShortcut.h>
#import <MASShortcut/MASShortcutValidator.h>

extern NSString *const MASShortcutBinding;

typedef NS_ENUM(NSInteger, MASShortcutViewStyle2) {
    MASShortcutViewStyle2Default = 0,  // Height = 19 px
    MASShortcutViewStyle2TexturedRect, // Height = 25 px
    MASShortcutViewStyle2Rounded,      // Height = 43 px
    MASShortcutViewStyle2Flat
};

@interface OLShortcutView : NSView

@property (nonatomic, strong) MASShortcut *shortcutValue;
@property (nonatomic, strong) MASShortcutValidator *shortcutValidator;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^shortcutValueChange)(OLShortcutView *sender);
@property (nonatomic, assign) MASShortcutViewStyle2 style;

/// Returns custom class for drawing control.
+ (Class)shortcutCellClass;

- (void)setAcceptsFirstResponder:(BOOL)value;

@end
