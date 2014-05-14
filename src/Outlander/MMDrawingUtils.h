//
//  MMDrawingUtils.h
//  MiniMail
//
//  Created by DINH Viêt Hoà on 21/02/10.
//  Copyright 2011 Sparrow SAS. All rights reserved.
//
// http://dinhviethoa.tumblr.com/post/6138273608/ios-style-scrollbars-for-nsscrollview

void MMFillRoundedRect(NSRect rect, CGFloat x, CGFloat y);
void MMStrokeRoundedRect(NSRect rect, CGFloat x, CGFloat y);

void MMCGContextFillRoundRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
void MMCGContextStrokeRoundRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
