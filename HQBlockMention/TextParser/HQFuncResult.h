//
//  HQFuncResult.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/17.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HQBlockResult;

@interface HQFuncResult : NSObject

@property (nonatomic, assign) NSRange rangeInText;
@property (nonatomic, copy) NSString *funcBody;
@property (nonatomic, copy) NSString *blockIdentify;
@property (nonatomic, assign) NSTimeInterval timeStamp;

-(HQBlockResult *)hasBlockInsdie;

@end
