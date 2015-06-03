//
//  MyView.m
//  Outlander
//
//  Created by Joseph McBride on 1/26/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "MyView.h"
#import "MyThumb.h"
#import "TextViewController.h"
#import "NSView+Categories.h"

typedef NS_ENUM(NSInteger, DragLocationState) {
    DragLocationTopLeft,
    DragLocationTopRight,
    DragLocationBottomLeft,
    DragLocationBottomRight,
    DragLocationRight,
    DragLocationLeft,
    DragLocationTop,
    DragLocationBottom
};

@implementation MyView {
    NSSize _maxViewSize;
    NSCursor *_nwseCursor;
    NSCursor *_neswCursor;
    id<KeyHandler> _keyHandler;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NSColor blackColor];
        self.draggable = NO;
        self.autoresizesSubviews = YES;
        self.postsFrameChangedNotifications = YES;
        _maxViewSize = NSMakeSize(50, 50);
        _nwseCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_nwse"] hotSpot:NSMakePoint(10, 10)];
        _neswCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_nesw"] hotSpot:NSMakePoint(10, 10)];
    }
    return self;
}

- (void)awakeFromNib {
    _keyup = [RACSubject subject];
}

- (void)setKeyHandler:(id<KeyHandler>)handler {
    _keyHandler = handler;
}

- (void)keyUp:(NSEvent *)theEvent {
    id<RACSubscriber> sub = (id<RACSubscriber>)_keyup;
    [sub sendNext:theEvent];
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)hasView:(NSString *)key {
    
    __block BOOL found = NO;
    
    [self.subviews enumerateObjectsUsingBlock:^(MyView *view, NSUInteger idx, BOOL *stop) {
        if ([view.key isEqualToString:key]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    return found;
}

- (void)addViewFromTextView:(TextViewController *)controller {
    __block MyView *view = [self createMyView:[NSColor blackColor]
                                        atLoc:controller.lastLocation
                                      withKey:controller.key
                                      andView:controller.view];
    
    [view setShowBorder:controller.showBorder];
}

- (MyView*)createMyView:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key andView:(NSView *)childView {
    __block MyView *view = [[MyView alloc] initWithFrame:rect];
    view.backgroundColor = color;
    view.draggable = YES;
    view.showBorder = YES;
    [self addSubview:view];
    
    view.key = key;
    
    [self wireBottomLeftResize:view];
    [self wireBottomRightResize:view];
    [self wireTopLeftResize:view];
    [self wireTopRightResize:view];
    
    [view addSubview:childView];
    
    NSCursor *cursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"move"]  hotSpot:NSMakePoint(0, 0)];
    
    MyThumb *bottomThumb = [self wireDragRect:view
                                    withFrame:NSMakeRect(15, 0, view.frame.size.width-30, 10)
                                   withCursor:cursor];
    [bottomThumb fixLeftEdge:YES];
    [bottomThumb fixWidth:NO];
    [bottomThumb fixHeight:YES];
    
    MyThumb *topThumb = [self wireDragRect:view
                                 withFrame:NSMakeRect(15, view.frame.size.height-10, view.frame.size.width-30, 10)
                                withCursor:cursor];
    [topThumb fixTopEdge:NO];
    [topThumb fixLeftEdge:YES];
    [topThumb fixWidth:NO];
    [topThumb fixHeight:YES];
    
    MyThumb *leftThumb = [self wireDragRect:view
                                  withFrame:NSMakeRect(0, 15, 10, view.frame.size.height - 30)
                          withCursor:cursor];
    [leftThumb fixTopEdge:YES];
    [leftThumb fixLeftEdge:YES];
    [leftThumb fixWidth:YES];
    [leftThumb fixHeight:NO];
    
    MyThumb *rightThumb = [self wireDragRect:view
                                   withFrame:NSMakeRect(view.frame.size.width - 10, 15, 10, view.frame.size.height - 30)
                           withCursor:cursor];
    [rightThumb fixTopEdge:YES];
    [rightThumb fixLeftEdge:NO];
    [rightThumb fixRightEdge:YES];
    [rightThumb fixWidth:YES];
    [rightThumb fixHeight:NO];
    
    return view;
}

- (TextViewController*)createTextController:(NSString *)key atLoc:(NSRect)rect {
    TextViewController *textcrl = [[TextViewController alloc] init];
    [textcrl.view setFrameSize:NSMakeSize(rect.size.width, rect.size.height)];
    [textcrl.view fixLeftEdge:YES];
    [textcrl.view fixTopEdge:YES];
    [textcrl.view fixWidth:NO];
    [textcrl.view fixHeight:NO];
    [textcrl.view fixRightEdge:YES];
    [textcrl.view fixBottomEdge:YES];
    
    textcrl.lastLocation = rect;
    
    textcrl.key = key;
    
    return textcrl;
}

- (TextViewController*)addView:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key {
    TextViewController *textcrl = [self createTextController:key atLoc:rect];
    
    [self createMyView:color atLoc:rect withKey:key andView:textcrl.view];
    
    return textcrl;
}

- (TextViewController*)addViewOld:(NSColor *)color atLoc:(NSRect)rect withKey:(NSString *)key {
    __block MyView *view = [[MyView alloc] initWithFrame:rect];
    view.backgroundColor = color;
    view.draggable = YES;
    view.showBorder = YES;
    [self addSubview:view];
    
    TextViewController *textcrl = [[TextViewController alloc] init];
    [textcrl.view setFrameSize:NSMakeSize(rect.size.width, rect.size.height)];
    [textcrl.view fixLeftEdge:YES];
    [textcrl.view fixTopEdge:YES];
    [textcrl.view fixWidth:NO];
    [textcrl.view fixHeight:NO];
    [textcrl.view fixRightEdge:YES];
    [textcrl.view fixBottomEdge:YES];
    
    view.key = textcrl.key = key;
    
    [view addSubview:textcrl.view];
    //[_viewsList addObject:view];
    
    [self wireBottomLeftResize:view];
    [self wireBottomRightResize:view];
    [self wireTopLeftResize:view];
    [self wireTopRightResize:view];
    
    NSCursor *cursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"move"]  hotSpot:NSMakePoint(0, 0)];
    
    MyThumb *bottomThumb = [self wireDragRect:view
                                    withFrame:NSMakeRect(15, 0, view.frame.size.width-30, 10)
                                   withCursor:cursor];
    [bottomThumb fixLeftEdge:YES];
    [bottomThumb fixWidth:NO];
    [bottomThumb fixHeight:YES];
    
    MyThumb *topThumb = [self wireDragRect:view
                                 withFrame:NSMakeRect(15, view.frame.size.height-10, view.frame.size.width-30, 10)
                                withCursor:cursor];
    [topThumb fixTopEdge:NO];
    [topThumb fixLeftEdge:YES];
    [topThumb fixWidth:NO];
    [topThumb fixHeight:YES];
    
    MyThumb *leftThumb = [self wireDragRect:view
                                  withFrame:NSMakeRect(0, 15, 10, view.frame.size.height - 30)
                                 withCursor:cursor];
    [leftThumb fixTopEdge:YES];
    [leftThumb fixLeftEdge:YES];
    [leftThumb fixWidth:YES];
    [leftThumb fixHeight:NO];
    
    MyThumb *rightThumb = [self wireDragRect:view
                                   withFrame:NSMakeRect(view.frame.size.width - 10, 15, 10, view.frame.size.height - 30)
                                  withCursor:cursor];
    [rightThumb fixTopEdge:YES];
    [rightThumb fixLeftEdge:NO];
    [rightThumb fixRightEdge:YES];
    [rightThumb fixWidth:YES];
    [rightThumb fixHeight:NO];
    
    return textcrl;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
    
   
    if(self.dragging || self.showBorder) {
        [[NSColor colorWithHexString:@"#cccccc"] setStroke];
        
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        [thePath appendBezierPathWithRect:dirtyRect];
        [thePath setLineWidth:2.0];
        [thePath setLineCapStyle:NSRoundLineCapStyle];
        [thePath stroke];
    }
    
    [super drawRect:dirtyRect];
}

//-(void)mouseDown:(NSEvent *) theEvent {
//    
//    self.mouseLoc = [theEvent locationInWindow];
//    self.movingTile = [self hitTest:self.mouseLoc]; //returns the object clicked on
//    
//    if(![self.movingTile isKindOfClass:[MyView class]]) return;
//    if(![(MyView *)self.movingTile draggable]) return;
//    
//    self.dragging = YES;
//    
////    if([self.viewsList count] > 2){
////        [self.viewsList exchangeObjectAtIndex:[self.viewsList indexOfObject:self.movingTile] withObjectAtIndex: [self.viewsList count] - 1];
////        [self setSubviews:self.viewsList]; //Reorder's the subviews so the picked up tile always appears on top
////    }
//    
//    self.hit = YES;
//    NSPoint cLoc = [self.movingTile convertPoint:self.mouseLoc fromView:nil];
////    NSPoint loc = NSMakePoint(self.mouseLoc.x - cLoc.x, self.mouseLoc.y - cLoc.y);
//    //[self.movingTile setFrameOrigin:loc];
//    self.kX = cLoc.x;  //this is the x offset between where the mouse was clicked and "movingTile's" x origin
//    self.kY = cLoc.y;  //this is the y offset between where the mouse was clicked and "movingTile's" y origin
//    
//    NSLog(@"%f,%f", cLoc.x, cLoc.y);
//    
//    self.needsDisplay = YES;
//}

//-(void)mouseDragged:(NSEvent *)theEvent {
//    if (self.hit) {
//        self.mouseLoc = [theEvent locationInWindow];
//        NSPoint newLoc = NSMakePoint(self.mouseLoc.x - self.kX, self.mouseLoc.y - self.kY);
//        if(newLoc.x < 0)
//            newLoc.x = 0;
//        if(newLoc.y < 0)
//            newLoc.y = 0;
//        
//        [self.movingTile setFrameOrigin:newLoc];
//        self.dragging = YES;
//        self.needsDisplay = YES;
//    }
//}
//

//-(void)mouseUp:(NSEvent *) theEvent {
//    if(self.dragging) {
//        self.dragging = NO;
//        self.needsDisplay = YES;
//    }
//}

-(void)wireBottomRightResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(view.frame.size.width - 10, view.frame.size.height - 10, 10, 10)
                                         withCursor:_nwseCursor];
    [thumb fixTopEdge:NO];
    [thumb fixBottomEdge:YES];
    [thumb fixLeftEdge:NO];
    [thumb fixRightEdge:YES];
    [thumb fixHeight:YES];
    [thumb fixWidth:YES];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float maxY = 0.0;
    __block float maxX = 0.0;
    
    thumb.down = ^(NSEvent *ev){
        [self reOrderView:view];
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        maxY = self.frame.size.height - view.frame.origin.y;
        maxX = self.frame.size.width - view.frame.origin.x;
    };
    
    thumb.up = ^(NSEvent *ev) {
        view.dragging = NO;
        view.needsDisplay = YES;
    };
    
    thumb.dragged = ^(NSEvent *ev){
        if(!view.draggable) return;
        
        NSPoint loc = [ev locationInWindow];
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSSize size = NSMakeSize(origSize.width + xDif, origSize.height - yDif);
        
        if(size.height < _maxViewSize.height)
            size.height = _maxViewSize.height;
        if(size.width < _maxViewSize.width)
            size.width = _maxViewSize.width;
        
        if(size.height > maxY)
            size.height = maxY;
        if(size.width > maxX)
            size.width = maxX;
        
        [view setFrameSize:size];
        
        view.dragging = YES;
        view.needsDisplay = YES;
    };
    [view addSubview:thumb];
}

-(void)wireTopRightResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(view.frame.size.width - 10, 0, 10, 10)
                                         withCursor:_neswCursor];
    [thumb fixRightEdge:YES];
    [thumb fixTopEdge:YES];
    [thumb fixLeftEdge:NO];
    [thumb fixBottomEdge:NO];
    [thumb fixHeight:YES];
    [thumb fixWidth:YES];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float maxXSize = 0.0;
    __block float maxY = 0.0;
    
    thumb.down = ^(NSEvent *ev){
        [self reOrderView:view];
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        maxXSize = self.frame.size.width - view.frame.origin.x;
        maxY = (view.frame.size.height + view.frame.origin.y) - _maxViewSize.height;
    };
    
    thumb.up = ^(NSEvent *ev) {
        view.dragging = NO;
        view.needsDisplay = YES;
    };
    
    thumb.dragged = ^(NSEvent *ev){
        if(!view.draggable) return;
        
        view.dragging = YES;
        view.needsDisplay = YES;
        
        NSPoint loc = [ev locationInWindow];
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x, origOrigin.y - yDif);
        if(newOrigin.y < 0)
            newOrigin.y = 0;
        if(newOrigin.y > maxY)
            newOrigin.y = maxY;
        
        float yDif1 = newOrigin.y - origOrigin.y;
        
        NSSize size = NSMakeSize(origSize.width + xDif, origSize.height - yDif1);
        
        if(size.height < _maxViewSize.height)
            size.height = _maxViewSize.height;
        if(size.width < _maxViewSize.width)
            size.width = _maxViewSize.width;
        if(size.width > maxXSize)
            size.width = maxXSize;
        
        [view setFrameSize:size];
        [view setFrameOrigin:newOrigin];
    };
    [view addSubview:thumb];
}

-(void)wireBottomLeftResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(0, view.frame.size.height - 10, 10, 10)
                                         withCursor:_neswCursor];
    [thumb fixTopEdge:NO];
    [thumb fixBottomEdge:YES];
    [thumb fixLeftEdge:YES];
    [thumb fixRightEdge:NO];
    [thumb fixHeight:YES];
    [thumb fixWidth:YES];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float maxY = 0.0;
    __block float maxX = 0.0;
    __block float minXOrigin = 0.0;
    
    thumb.down = ^(NSEvent *ev){
        [self reOrderView:view];
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        maxY = self.frame.size.height - view.frame.origin.y;
        maxX = view.frame.origin.x + view.frame.size.width;
        minXOrigin = view.frame.origin.x + view.frame.size.width - _maxViewSize.width;
    };
    
    thumb.up = ^(NSEvent *ev) {
        view.dragging = NO;
        view.needsDisplay = YES;
    };
    
    thumb.dragged = ^(NSEvent *ev){
        if(!view.draggable) return;
        
        view.dragging = YES;
        view.needsDisplay = YES;
        
        NSPoint loc = [ev locationInWindow];
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x + xDif, origOrigin.y);
        if(newOrigin.x < 0)
            newOrigin.x = 0;
        if(newOrigin.y < 0)
            newOrigin.y = 0;
        if(newOrigin.x > minXOrigin)
            newOrigin.x = minXOrigin;
        
        NSSize size = NSMakeSize(origSize.width - xDif, origSize.height - yDif);
        
        if(size.height < _maxViewSize.height)
            size.height = _maxViewSize.height;
        if(size.width < _maxViewSize.width)
            size.width = _maxViewSize.width;
        
        if(size.height > maxY)
            size.height = maxY;
        if(size.width > maxX)
            size.width = maxX;
        
        [view setFrameSize:size];
        [view setFrameOrigin:newOrigin];
    };
    [view addSubview:thumb];
}

-(void)wireTopLeftResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)
                                         withCursor:_nwseCursor];
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float minY = 0.0;
    __block float minX = 0.0;
    
    thumb.down = ^(NSEvent *ev){
//        NSLog(@"****DOWN****");
        [self reOrderView:view];
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        minY = view.frame.origin.y + view.frame.size.height - _maxViewSize.height;
        minX = view.frame.origin.x + view.frame.size.width - _maxViewSize.width;
    };
    
    thumb.up = ^(NSEvent *ev) {
//        NSLog(@"****UP****");
        view.dragging = NO;
        view.needsDisplay = YES;
    };
    
    thumb.dragged = ^(NSEvent *ev){
//        NSLog(@"****DRAGGED****");
        if(!view.draggable) return;
        
        view.dragging = YES;
        
        NSPoint loc = [ev locationInWindow];
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x + xDif, origOrigin.y - yDif);
        if(newOrigin.x < 0)
            newOrigin.x = 0;
        if(newOrigin.y < 0)
            newOrigin.y = 0;
        if(newOrigin.y > minY)
            newOrigin.y = minY;
        if(newOrigin.x > minX)
            newOrigin.x = minX;
        
        float xDif1 = newOrigin.x - origOrigin.x;
        float yDif1 = newOrigin.y - origOrigin.y;
        
        NSSize size = NSMakeSize(origSize.width - xDif1, origSize.height - yDif1);
        
        if(size.height < _maxViewSize.height)
            size.height = _maxViewSize.height;
        if(size.width < _maxViewSize.width)
            size.width = _maxViewSize.width;
        
//        NSLog(@"newOrigin: %f, %f", newOrigin.x, newOrigin.y);
        
        [view setFrameOrigin:newOrigin];
        [view setFrameSize:size];

        view.needsDisplay = YES;
    };
    [view addSubview:thumb];
}

-(MyThumb *)wireDragRect:(MyView *)view withFrame:(NSRect) frame withCursor:(NSCursor *)cursor {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:frame withCursor:cursor];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    
    __block float maxX = 0.0;
    __block float maxY = 0.0;
    
    thumb.down = ^(NSEvent *ev) {
        [self reOrderView:view];
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        
        maxX = self.frame.size.width - view.frame.size.width;
        maxY = self.frame.size.height - view.frame.size.height;
    };
    thumb.up = ^(NSEvent *ev) {
        view.dragging = NO;
        view.needsDisplay = YES;
    };
    thumb.dragged = ^(NSEvent *ev){
        if(!view.draggable) return;
        
        view.dragging = YES;
        view.needsDisplay = YES;
        
        NSPoint loc = [ev locationInWindow];
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x + xDif, origOrigin.y - yDif);
        if(newOrigin.x < 0)
            newOrigin.x = 0;
        if(newOrigin.y < 0)
            newOrigin.y = 0;
        if(newOrigin.x > maxX)
            newOrigin.x = maxX;
        if(newOrigin.y > maxY)
            newOrigin.y = maxY;
        
//        NSLog(@"newOrigin: %f, %f", newOrigin.x, newOrigin.y);
        
        [view setFrameOrigin:newOrigin];
    };
    
    [view addSubview:thumb];
    
    return thumb;
}

//Reorder's the subviews so the picked up view always appears on top
- (void)reOrderView:(NSView *)view {
    NSMutableArray *subViews = [self.subviews mutableCopy];
    [subViews exchangeObjectAtIndex:[subViews indexOfObject:view]
                        withObjectAtIndex:[subViews count] - 1];
    [self setSubviews:subViews];
}

@end
