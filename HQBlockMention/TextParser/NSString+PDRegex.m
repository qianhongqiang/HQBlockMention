//
//  NSString+PDRegex.m
//  RegexOnNSString
//
//  Created by Carl Brown on 10/3/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import "NSString+PDRegex.h"

@implementation NSString (PDRegex)

-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL)ignoreCase {
    return [self htp_stringByReplacingRegexPattern:regex withString:replacement caseInsensitive:ignoreCase treatAsOneLine:NO];
}

-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine {
    
    NSUInteger options=0;
    if (ignoreCase) {
        options = options | NSRegularExpressionCaseInsensitive;
    }
    if (assumeMultiLine) {
        options = options | NSRegularExpressionDotMatchesLineSeparators;
    }

    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:&error];
    if (error) {
        NSLog(@"Error creating Regex: %@",[error description]);
        return nil;
    }
    
    NSString *retVal= [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
    return retVal;
}

-(NSString *) htp_stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement {
    return [self htp_stringByReplacingRegexPattern:regex withString:replacement caseInsensitive:NO treatAsOneLine:NO];
}

-(NSArray *) htp_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine {
    NSUInteger options=0;
    if (ignoreCase) {
        options = options | NSRegularExpressionCaseInsensitive;
    }
    if (assumeMultiLine) {
        options = options | NSRegularExpressionDotMatchesLineSeparators;
    }
    
    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:&error];
    if (error) {
        NSLog(@"Error creating Regex: %@",[error description]);
        return nil;
    }

    __block NSMutableArray *retVal = [NSMutableArray array];
    [pattern enumerateMatchesInString:self options:0 range:NSMakeRange(0, [self length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        //Note, we only want to return the things in parens, so we're skipping index 0 intentionally
        for (int i=1; i<[result numberOfRanges]; i++) {
            NSString *matchedString=[self substringWithRange:[result rangeAtIndex:i]];
            [retVal addObject:matchedString];
        }
    }];
    return retVal;
}

-(NSArray *) htp_stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex {
    return [self htp_stringsByExtractingGroupsUsingRegexPattern:regex caseInsensitive:NO treatAsOneLine:NO];
}

-(BOOL) htp_matchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine {
    NSUInteger options=0;
    if (ignoreCase) {
        options = options | NSRegularExpressionCaseInsensitive;
    }
    if (assumeMultiLine) {
        options = options | NSRegularExpressionDotMatchesLineSeparators;
    }
    
    NSError *error=nil;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:&error];
    if (error) {
        NSLog(@"Error creating Regex: %@",[error description]);
        return NO;  //Can't possibly match an invalid Regex
    }

    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0);
}

-(BOOL) htp_matchesPatternRegexPattern:(NSString *)regex {
    return [self htp_matchesPatternRegexPattern:regex caseInsensitive:NO treatAsOneLine:NO];
}

-(NSTextCheckingResult *)htp_LastStringMatchesPatternRegex:(NSString *)patternRegex
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:patternRegex
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    
    NSArray *resultSet = [exp matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (resultSet.count) {
        return resultSet.lastObject;
    }
    return nil;
}

-(NSTextCheckingResult *)htp_firstStringMatchesPatternRegex:(NSString *)patternRegex
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:patternRegex
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    
    NSArray *resultSet = [exp matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (resultSet.count) {
        return resultSet.firstObject;
    }
    return nil;
}

@end
