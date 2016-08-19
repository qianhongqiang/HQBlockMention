//
//  NSTextView+HQTextParser.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HQTextResult;
@class HQFuncResult;

@interface NSTextView (HQTextParser)

-(NSInteger) htp_currentCurseLocation;

-(HQTextResult *) htp_textResultOfCurrentLine;

-(HQTextResult *) htp_textResultOfPreviousLine;

-(HQTextResult *) htp_textResultOfNextLine;

-(HQTextResult *) htp_textResultUntilNextString:(NSString *)findString;

-(HQTextResult *) htp_textResultLastString:(NSString *)findString;

-(HQTextResult *) htp_textResultWithPairOpenString:(NSString *)open closeString:(NSString *)close;

-(HQTextResult *) htp_textResultToEndOfFile;

-(HQFuncResult *) htp_functionOfCurrentLie;

@end
