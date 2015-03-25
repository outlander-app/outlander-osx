//
//  NSTextView+Categories.m
//  Outlander
//
//  Created by Joseph McBride on 3/24/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

#import "NSTextView+Categories.h"

@implementation NSTextView (Categories)

- (unsigned int) numberOfLines
{
    unsigned int    result;
    NSLayoutManager *lm;
    unsigned long   glyphIndex;
    NSRange         allCharactersRange, allGlyphsRange;
    NSRange         lineFragmentGlyphRange;
    
    result = 0;
    
    //  Note our range of characters
    allCharactersRange = NSMakeRange (0, [[self string] length]);
    
    //  Find how many glyphs there are
    lm = [self layoutManager];
    allGlyphsRange = [lm glyphRangeForCharacterRange: allCharactersRange
                                actualCharacterRange: NULL];
    
    glyphIndex = 0;
    while (glyphIndex < NSMaxRange (allGlyphsRange))
    {
        (void) [lm lineFragmentRectForGlyphAtIndex: glyphIndex
                                    effectiveRange: &lineFragmentGlyphRange];
        
        //  Count the line we found
        ++result;
        
        //  Move to the start of the next line
        glyphIndex = NSMaxRange (lineFragmentGlyphRange);
    }
    
    return result;
}

//  lines -- Return the lines as an array of strings, reflecting both hard and soft line breaks.
//  This is a lot like code above. It would be better to create an enumerator to return line ranges,
//  then have both the method above and this method use that enumerator.
- (NSArray *) lines
{
    NSString        *s;
    NSMutableArray  *result;
    NSLayoutManager *lm;
    unsigned long   glyphIndex;
    NSRange         allCharactersRange, allGlyphsRange;
    NSRange         lineFragmentGlyphRange, lineFragmentCharacterRange;
    
    s = [self string];
    result = [NSMutableArray array];
    
    //  Find our range of characters
    allCharactersRange = NSMakeRange (0, [[self string] length]);
    
    //  Find how many glyphs there are
    lm = [self layoutManager];
    allGlyphsRange = [lm glyphRangeForCharacterRange: allCharactersRange
                                actualCharacterRange: NULL];
    
    glyphIndex = 0;
    while (glyphIndex < NSMaxRange (allGlyphsRange))
    {
        NSString    *oneLine;
        
        (void) [lm lineFragmentRectForGlyphAtIndex: glyphIndex
                                    effectiveRange: &lineFragmentGlyphRange];
        
        lineFragmentCharacterRange =
        [lm characterRangeForGlyphRange: lineFragmentGlyphRange  actualGlyphRange: NULL];
        
        oneLine = [s substringWithRange: lineFragmentCharacterRange];
        [result addObject: oneLine];
        
        glyphIndex = NSMaxRange (lineFragmentGlyphRange);
    }
    
    return result;
}

@end
