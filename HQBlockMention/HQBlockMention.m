//
//  HQBlockMention.m
//  HQBlockMention
//
//  Created by qianhongqiang on 16/8/16.
//  Copyright © 2016年 qian. All rights reserved.
//

#import "HQBlockMention.h"
#import "HQTextResult.h"
#import "HQFuncResult.h"
#import "NSString+HQTextParser.h"
#import "NSTextView+HQTextParser.h"
#import "NSString+PDRegex.h"

static NSString *const kBlockIdentify = @"^";

static const float upPadding = 15;
static const float dismissInterval = 3;
static const float alertInterval = 30;

static HQBlockMention *sharedPlugin;

@interface HQBlockMention ()

@property (nonatomic, strong) NSTimer *mentionTimeIntervalTimer;

@property (nonatomic, assign) BOOL shouldRemind;

@property (nonatomic, strong) NSMutableDictionary *mentionedBlocks;

@end

@implementation HQBlockMention

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textStorageDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textStorageDidChange:)
                                                 name:NSTextDidBeginEditingNotification
                                               object:nil];
    [self setupTimer];
    self.shouldRemind = YES;
    self.mentionedBlocks = [NSMutableDictionary dictionary];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

-(void)setupTimer
{
    self.mentionTimeIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:alertInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

#pragma mark - Implementation

- (BOOL)initialize
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"HQBlockMention" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"https://github.com/qianhongqiang/HQBlockMention.git"];
    [alert runModal];
}

-(void)timerAction
{
    self.shouldRemind = YES;
}

- (void) textStorageDidChange:(NSNotification *)noti {
    
    if (!self.shouldRemind) {
        return;
    }
    
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)[noti object];
        //Parse the current line,check if a '^' syntax and do not contain 'typedef'
        [self startCheck:textView];
    }
}

-(void)startCheck:(NSTextView *)textView
{
    HQTextResult *blockStart = [textView htp_textResultLastString:kBlockIdentify];
    if (nil == blockStart) {
        return;
    }
    
    //find the block body
    HQTextResult *blockContent = [textView.textStorage.string htp_textResultMatchPartWithPairOpenString:@"{" closeString:@"}" currentLocation:blockStart.range.location];
    if (nil == blockContent) {
        return;
    }
    
    //find the block startline,and define the first line as key for the block
    HQTextResult *blockStartLine = [textView.textStorage.string htp_textResultOfCurrentTotalLineCurrentLocation:blockStart.range.location];
    
    if (blockStartLine.range.location <blockContent.range.location && (blockStartLine.range.location + blockStartLine.range.length)>blockContent.range.location) {
        HQFuncResult *block = [[HQFuncResult alloc] init];
        block.rangeInText = blockContent.range;
        block.funcBody = blockContent.string;
        block.blockIdentify = blockStartLine.string;
        
        HQFuncResult *blockInMap = [self.mentionedBlocks objectForKey:block.blockIdentify];
        
        if (blockInMap) {
            NSTimeInterval interval = [NSDate date].timeIntervalSince1970 -  blockInMap.timeStamp;
            if (interval > 300) {
                [self checkBlockScopeInside:block inTextView:textView];
            }
        }else{
            [self checkBlockScopeInside:block inTextView:textView];
        }
    }
    
    //find the function which the block in
    NSString *beforeString = [textView.textStorage.string substringToIndex:textView.selectedRange.location];
    NSTextCheckingResult *checkResult = [beforeString htp_LastStringMatchesPatternRegex:@"\n?\\s*[+-]\\s*[(]"];
    
    if (!checkResult) {
        return;
    }
    
    HQTextResult *containerFunction = [textView.textStorage.string htp_textResultMatchPartWithPairOpenString:@"{" closeString:@"}" currentLocation:checkResult.range.location];
    HQFuncResult *function = [[HQFuncResult alloc] init];
    function.rangeInText = containerFunction.range;
    function.funcBody = containerFunction.string;
    function.blockIdentify = [textView.textStorage.string htp_textResultOfCurrentTotalLineCurrentLocation:checkResult.range.location].string;
    
    HQFuncResult *blockInMapFunction = [self.mentionedBlocks objectForKey:function.blockIdentify];
    
    if (blockInMapFunction) {
        NSTimeInterval interval = [NSDate date].timeIntervalSince1970 -  blockInMapFunction.timeStamp;
        if (interval > 300) {
            [self checkBlockScopeOutsideIn:function inTextView:textView];
        }
    }else{
        [self checkBlockScopeOutsideIn:function inTextView:textView];
    }
}

-(void)checkBlockScopeOutsideIn:(HQFuncResult *)block inTextView:(NSTextView *)textView
{
    NSRange dubiousRangeInBlock = [block.funcBody rangeOfString:@"__block"];

    if (dubiousRangeInBlock.location == NSNotFound) {
        return;
    }
    
    HQTextResult *__blockTotalLine = [block.funcBody htp_textResultOfCurrentTotalLineCurrentLocation:dubiousRangeInBlock.location];
    
    NSRange equalSymbolRange = [__blockTotalLine.string rangeOfString:@"="];
    
    if (equalSymbolRange.location != NSNotFound) {
        NSString *equalBefore = [__blockTotalLine.string substringToIndex:equalSymbolRange.location];
        if ([equalBefore rangeOfString:@"*"].location == NSNotFound) {
            return;
        }
    }else{
        if ([__blockTotalLine.string rangeOfString:@"*"].location == NSNotFound) {
            return;
        }
    }
    
    NSRange dubiousRange = NSMakeRange(block.rangeInText.location + dubiousRangeInBlock.location, dubiousRangeInBlock.length);
    if (dubiousRange.location != NSNotFound) {
        
        NSRect dubiousRect = [textView.layoutManager boundingRectForGlyphRange:dubiousRange inTextContainer:textView.textContainer];
        
        NSRect tipRect = dubiousRect;
        tipRect.origin.y = tipRect.origin.y - tipRect.size.height - upPadding;
        tipRect.size.width = 400;
        tipRect.size.height = 25;
        NSTextField *label = [[NSTextField alloc] initWithFrame:tipRect];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setPlaceholderString:@"__block不能接触循环引用,请注意是否需要改成__weak"];
        [textView addSubview:label];
        
        self.shouldRemind = NO;
        
        HQFuncResult *blockInMap = [self.mentionedBlocks objectForKey:block.blockIdentify];
        
        if (blockInMap) {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
        }else {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
            [self.mentionedBlocks setObject:block forKey:block.blockIdentify];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
    }

}

-(void)checkBlockScopeInside:(HQFuncResult *)block inTextView:(NSTextView *)textView
{
    [self checkBlockInsidePropertyRetainCircle:block inTextView:textView];
    
    //if content of block matches like '[self' ' self.',might caught retain circle
    NSRange dubiousRangeInBlock = [block.funcBody rangeOfString:@" self "];
    if (dubiousRangeInBlock.location == NSNotFound) {
        dubiousRangeInBlock = [block.funcBody rangeOfString:@" self."];
    }
    
    if (dubiousRangeInBlock.location == NSNotFound) {
        dubiousRangeInBlock = [block.funcBody rangeOfString:@"[self"];
    }
    
    //sepcial:ReactCocoa provide a Macro which make weak referrence,so check it
    
    NSRange ReactCocoaMacro = [block.funcBody rangeOfString:@"@strongify"];
    
    if (dubiousRangeInBlock.location == NSNotFound) {
        return;
    }
    
    
    if (ReactCocoaMacro.location != NSNotFound && dubiousRangeInBlock.location > ReactCocoaMacro.location) {
        return;
    }
    
    NSRange dubiousRange = NSMakeRange(block.rangeInText.location + dubiousRangeInBlock.location, dubiousRangeInBlock.length);
    if (dubiousRange.location != NSNotFound) {
        
        NSRect dubiousRect = [textView.layoutManager boundingRectForGlyphRange:dubiousRange inTextContainer:textView.textContainer];
        
        NSRect tipRect = dubiousRect;
        tipRect.origin.y = tipRect.origin.y - tipRect.size.height - upPadding;
        tipRect.size.width = 200;
        tipRect.size.height = 25;
        NSTextField *label = [[NSTextField alloc] initWithFrame:tipRect];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setPlaceholderString:@"下面可能存在循环引用"];
        [textView addSubview:label];
        
        self.shouldRemind = NO;
        
        HQFuncResult *blockInMap = [self.mentionedBlocks objectForKey:block.blockIdentify];
        
        if (blockInMap) {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
        }else {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
            [self.mentionedBlocks setObject:block forKey:block.blockIdentify];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
    }
}

-(void)checkBlockInsidePropertyRetainCircle:(HQFuncResult *)block inTextView:(NSTextView *)textView
{
    NSTextCheckingResult *propertyDubious = [block.funcBody htp_firstStringMatchesPatternRegex:@"\\s*[_].*="];
    if (!propertyDubious || propertyDubious.range.location == NSNotFound) {
        return;
    }
    
    NSString *propertyDubiousString = [block.funcBody substringWithRange:propertyDubious.range];
    
    NSRange _range = [propertyDubiousString rangeOfString:@"_"];
    
    if (_range.location == NSNotFound) {
        return;
    }
    
    NSRange dubiousRange = NSMakeRange(block.rangeInText.location + propertyDubious.range.location + _range.location, propertyDubious.range.length - _range.location);
    
    if (dubiousRange.location != NSNotFound) {
        
        NSRect dubiousRect = [textView.layoutManager boundingRectForGlyphRange:dubiousRange inTextContainer:textView.textContainer];
        
        NSRect tipRect = dubiousRect;
        tipRect.origin.y = tipRect.origin.y - tipRect.size.height - upPadding;
        tipRect.size.width = 200;
        tipRect.size.height = 30;
        NSTextField *label = [[NSTextField alloc] initWithFrame:tipRect];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setPlaceholderString:@"下面可能存在循环引用"];
        [textView addSubview:label];
        
        self.shouldRemind = NO;
        
        HQFuncResult *blockInMap = [self.mentionedBlocks objectForKey:block.blockIdentify];
        
        if (blockInMap) {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
        }else {
            block.timeStamp = [NSDate date].timeIntervalSince1970;
            [self.mentionedBlocks setObject:block forKey:block.blockIdentify];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
    }
    
}

@end
