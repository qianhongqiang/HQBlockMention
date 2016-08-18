//
//  HQBlockMention.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface HQBlockMention : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end