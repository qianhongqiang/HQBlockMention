//
//  NSString+PDRegex.h
//  RegexOnNSString
//
//  Created by Carl Brown on 10/3/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import <Foundation/Foundation.h>

@interface NSString (PDRegex)

-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement;
-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase;
-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(NSArray *) htp_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex;
-(NSArray *) htp_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(BOOL) htp_matchesPatternRegexPattern:(NSString *)regex;
-(BOOL) htp_matchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;

-(NSTextCheckingResult *)htp_LastStringMatchesPatternRegex:(NSString *)patternRegex;

-(NSTextCheckingResult *)htp_firstStringMatchesPatternRegex:(NSString *)patternRegex;

@end
