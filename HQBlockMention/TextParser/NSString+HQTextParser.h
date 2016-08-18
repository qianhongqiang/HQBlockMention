//
//  NSString+HQTextParser.h
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HQTextResult;

@interface NSString (HQTextParser)

-(HQTextResult *) htp_textResultOfCurrentLineCurrentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultOfCurrentTotalLineCurrentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultOfPreviousLineCurrentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultOfNextLineCurrentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultUntilNextString:(NSString *)findString currentLocation:(NSInteger)location;


-(HQTextResult *) htp_textResultOfLastString:(NSString *)findString currentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultWithPairOpenString:(NSString *)open
                                      closeString:(NSString *)close
                                  currentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultMatchPartWithPairOpenString:(NSString *)open
                                               closeString:(NSString *)close
                                           currentLocation:(NSInteger)location;

-(HQTextResult *) htp_textResultToEndOfFileCurrentLocation:(NSInteger)location;



@end
