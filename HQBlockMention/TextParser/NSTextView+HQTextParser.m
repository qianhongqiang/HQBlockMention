//
//  NSTextView+HQTextParser.m
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import "NSTextView+HQTextParser.h"
#import "NSString+HQTextParser.h"
#import "HQTextResult.h"
#import "HQFuncResult.h"

@implementation NSTextView (HQTextParser)

-(NSInteger) htp_currentCurseLocation
{
    return [[[self selectedRanges] objectAtIndex:0] rangeValue].location;
}

-(HQTextResult *) htp_textResultOfCurrentLine
{
    return [self.textStorage.string htp_textResultOfCurrentLineCurrentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultOfPreviousLine
{
    return [self.textStorage.string htp_textResultOfPreviousLineCurrentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultOfNextLine
{
    return [self.textStorage.string htp_textResultOfNextLineCurrentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultUntilNextString:(NSString *)findString
{
    return [self.textStorage.string htp_textResultUntilNextString:findString currentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultLastString:(NSString *)findString
{
    return [self.textStorage.string htp_textResultOfLastString:findString currentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultWithPairOpenString:(NSString *)open closeString:(NSString *)close
{
    return [self.textStorage.string htp_textResultWithPairOpenString:open closeString:close currentLocation:[self htp_currentCurseLocation]];
}

-(HQTextResult *) htp_textResultToEndOfFile
{
    return [self.textStorage.string htp_textResultToEndOfFileCurrentLocation:[self htp_currentCurseLocation]];
}

-(HQFuncResult *) htp_functionOfCurrentLie
{
    return [self.textStorage.string htp_funcResultOfCurrentLoaction:[self htp_currentCurseLocation]];
}

@end
