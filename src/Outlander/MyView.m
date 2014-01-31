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

@implementation MyView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NSColor blackColor];
        self.draggable = NO;
        self.viewsList = [[NSMutableArray alloc] init];
        self.autoresizesSubviews = YES;
    }
    return self;
}

-(void) listenBoundsChanges {
    [self setPostsBoundsChangedNotifications:YES];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:NSViewFrameDidChangeNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *note) {
                        if(NSStringFromClass([note.object class])) {
//                            NSLog(@"%@ %@", note.name, note.object);
//                            NSLog(@"size: %f, %f", self.frame.size.height, self.frame.size.width);
                        }
                    }];
}

- (BOOL)isFlipped {
    return YES;
}

- (TextViewController*)addView:(NSColor *)color atLoc:(NSRect)rect {
    __block MyView *view = [[MyView alloc] initWithFrame:rect];
    view.backgroundColor = color;
    view.draggable = YES;
    [self addSubview:view];
    
    TextViewController *textcrl = [[TextViewController alloc] init];
    [textcrl.view setFrameSize:NSMakeSize(rect.size.width, rect.size.height)];
    [textcrl.view fixLeftEdge:YES];
    [textcrl.view fixTopEdge:YES];
    [textcrl.view fixWidth:NO];
    [textcrl.view fixHeight:NO];
    [textcrl.view fixRightEdge:YES];
    [textcrl.view fixBottomEdge:YES];
    [view addSubview:textcrl.view];
    
    [self wireTopLeftResize:view];
    [self wireBottomLeftResize:view];
    
    MyThumb *bottomThumb = [self wireDragRect:view withFrame:NSMakeRect(10, 0, view.frame.size.width-20, 10)];
    [bottomThumb fixLeftEdge:YES];
    [bottomThumb fixWidth:NO];
    [bottomThumb fixHeight:YES];
    
    MyThumb *topThumb = [self wireDragRect:view withFrame:NSMakeRect(10, view.frame.size.height-10, view.frame.size.width-20, 10)];
    [topThumb fixTopEdge:NO];
    [topThumb fixLeftEdge:YES];
    [topThumb fixWidth:NO];
    [topThumb fixHeight:YES];
    
    MyThumb *leftThumb = [self wireDragRect:view withFrame:NSMakeRect(0, 10, 10, view.frame.size.height - 20)];
    [leftThumb fixTopEdge:YES];
    [leftThumb fixLeftEdge:YES];
    [leftThumb fixWidth:YES];
    [leftThumb fixHeight:NO];
    
    MyThumb *rightThumb = [self wireDragRect:view withFrame:NSMakeRect(view.frame.size.width - 10, 10, 10, view.frame.size.height - 20)];
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
   
    if(self.dragging) {
        [[NSColor whiteColor] setStroke];
        
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        [thePath appendBezierPathWithRect:dirtyRect];
        [thePath setLineWidth:4.0];
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

-(void)wireBottomLeftResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(0, view.frame.size.height - 10, 10, 10)];
    [thumb fixTopEdge:NO];
    [thumb fixBottomEdge:YES];
    [thumb fixLeftEdge:YES];
    [thumb fixHeight:YES];
    [thumb fixWidth:YES];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float minX = 0.0;
    __block float minY = 0.0;
    
    thumb.down = ^(NSEvent *ev){
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        minX = origOrigin.x + origSize.width - 100;
        minY = origOrigin.y + origSize.height - 100;
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
        
        NSLog(@"%f,%f", loc.x, loc.y);
        
        NSPoint loc2 = NSMakePoint(loc.x < 0 ? 0 : loc.x, loc.y < 0 ? 0 : loc.y);
        NSLog(@"loc2: %f,%f", loc2.x, loc2.y);
        
        float xDif = loc2.x - nonTrans.x;
        float yDif = loc2.y - nonTrans.y;
        
        NSLog(@"dif: %f,%f", xDif, yDif);
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x + xDif, origOrigin.y);
        NSLog(@"newOrigin: %f,%f", newOrigin.x, newOrigin.y);
        if(newOrigin.x < 0){
            newOrigin.x = 0;
            xDif = 0;
        }
        if(newOrigin.y < 0){
            newOrigin.y = 0;
            yDif = 0;
        }
        if(newOrigin.x > minX){
            newOrigin.x = minX;
        }
        if(newOrigin.y > minY)
            newOrigin.y = minY;
        
        NSSize size = NSMakeSize(origSize.width - xDif, origSize.height - yDif);
        
        if(size.height < 100)
            size.height = 100;
        if(size.width < 100)
            size.width = 100;
        
        if(size.height > self.frame.size.height)
            size.height = self.frame.size.height;
        
        NSLog(@"newOrigin: %f,%f", newOrigin.x, newOrigin.y);
        NSLog(@"size: %f,%f", size.width, size.height);
        [view setFrameSize:size];
        [view setFrameOrigin:newOrigin];
    };
    [view addSubview:thumb];
}

-(void)wireTopLeftResize:(MyView*)view {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    __block NSSize origSize;
    
    __block float maxX = 0.0;
    __block float maxY = 0.0;
    
    thumb.down = ^(NSEvent *ev){
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        origSize = view.frame.size;
        
        maxX = self.frame.size.width - 100;
        maxY = self.frame.size.height - 100;
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
        
        float xDif1 = newOrigin.x - origOrigin.x;
        float yDif1 = newOrigin.y - origOrigin.y;
        
        NSSize size = NSMakeSize(origSize.width - xDif1, origSize.height - yDif1);
        
        if(size.height < 100)
            size.height = 100;
        if(size.width < 100)
            size.width = 100;
        
        [view setFrameSize:size];
        [view setFrameOrigin:newOrigin];
    };
    [view addSubview:thumb];
}

-(MyThumb *)wireDragRect:(MyView *)view withFrame:(NSRect) frame {
    MyThumb *thumb = [[MyThumb alloc] initWithFrame:frame];
    
    __block NSPoint nonTrans;
    __block NSPoint downPoint;
    __block NSPoint origOrigin;
    
    __block float maxX = 0.0;
    __block float maxY = 0.0;
    
    thumb.down = ^(NSEvent *ev) {
        nonTrans = [ev locationInWindow];
        downPoint = [view convertPoint:nonTrans fromView:nil];
        origOrigin = view.frame.origin;
        NSLog(@"nonTrans: %f,%f", nonTrans.x, nonTrans.y);
        NSLog(@"Down: %f,%f", downPoint.x, downPoint.y);
        
        maxX = self.frame.size.width - view.frame.size.width;
        maxY = self.frame.size.height - view.frame.size.height;
        NSLog(@"MaxX: %f", maxX);
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
        NSLog(@"loc: %f, %f", loc.x, loc.y);
        
        float xDif = loc.x - nonTrans.x;
        float yDif = loc.y - nonTrans.y;
        
        NSPoint newOrigin = NSMakePoint(origOrigin.x + xDif, origOrigin.y - yDif);
        NSLog(@"new: %f, %f", newOrigin.x, newOrigin.y);
        if(newOrigin.x < 0)
            newOrigin.x = 0;
        if(newOrigin.y < 0)
            newOrigin.y = 0;
        if(newOrigin.x > maxX)
            newOrigin.x = maxX;
        if(newOrigin.y > maxY)
            newOrigin.y = maxY;
        
        NSLog(@"new: %f, %f", newOrigin.x, newOrigin.y);
        NSLog(@"old: %f, %f", view.frame.origin.x, view.frame.origin.y);
        
        [view setFrameOrigin:newOrigin];
    };
    
    [view addSubview:thumb];
    
    return thumb;
}

@end
