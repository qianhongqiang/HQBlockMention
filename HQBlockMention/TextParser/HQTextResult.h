//
//  HQTextResult.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQTextResult : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *string;

-(instancetype) initWithRange:(NSRange)aRange string:(NSString *)aString;
+(instancetype)textResultWithRange:(NSRange)aRange string:(NSString *)aString;

@end


@interface HQTextResult (Match)

-(BOOL)isTypedef;

@end