//
//  HQTextResult.m
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import "HQTextResult.h"

@implementation HQTextResult

-(instancetype) initWithRange:(NSRange)aRange string:(NSString *)aString
{
    self = [super init];
    if (self) {
        _range = aRange;
        _string = aString;
    }
    return self;
}

+(instancetype)textResultWithRange:(NSRange)aRange string:(NSString *)aString
{
    return [[self alloc] initWithRange:aRange string:aString];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Location------%lu\nLength-------%lu\nContent-----%@",(unsigned long)self.range.location,(unsigned long)self.range.length,self.string];
}

@end

@implementation HQTextResult (Match)

-(BOOL)isTypedef
{
    return [self.string containsString:@"typedef"];
}


@end
