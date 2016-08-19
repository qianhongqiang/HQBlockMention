//
//  HQBlockResult.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/19.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQBlockResult : NSObject

@property (nonatomic, assign) NSRange rangeInfunction;
@property (nonatomic, copy) NSString *blockBody;
@property (nonatomic, copy) NSString *blockIdentify;
@property (nonatomic, assign) NSTimeInterval timeStamp;

@end
