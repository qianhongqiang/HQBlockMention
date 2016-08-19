//
//  HQFuncResult.m
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/17.
//  Copyright © 2016年 qian. All rights reserved.
//

#import "HQFuncResult.h"
#import "HQBlockResult.h"
#import "HQTextResult.h"
#import "HQConst.h"
#import "NSString+HQTextParser.h"

@implementation HQFuncResult

-(HQBlockResult *)hasBlockInsdie
{
    NSRange idRange =  [self.funcBody rangeOfString:kBlockIdentify];
    if (idRange.location == NSNotFound) {return nil;}
    
    HQTextResult *blockContent = [self.funcBody htp_textResultMatchPartWithPairOpenString:@"{" closeString:@"}" currentLocation:idRange.location];
    if (nil == blockContent) {return nil;}
    
    //find the block startline,and define the first line as key for the block
    HQTextResult *blockStartLine = [self.funcBody htp_textResultOfCurrentTotalLineCurrentLocation:idRange.location];
    
    if (blockStartLine.range.location <blockContent.range.location && (blockStartLine.range.location + blockStartLine.range.length)>blockContent.range.location) {
        HQBlockResult *block = [[HQBlockResult alloc] init];
        block.rangeInfunction = blockContent.range;
        block.blockBody = blockContent.string;
        block.blockIdentify = blockStartLine.string;
        return block;
    }

    return nil;
}

@end
