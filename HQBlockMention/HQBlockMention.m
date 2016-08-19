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
#import "HQBlockResult.h"
#import "HQConst.h"


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
        self.shouldRemind = NO;
        [self startCheck:textView];
    }
}

-(void)startCheck:(NSTextView *)textView
{
    HQFuncResult *currentFunction = [self checkIfCurrentLocationInMethod:textView];
    if (!currentFunction) {return;}
    
    NSNumber *value = [self.mentionedBlocks objectForKey:currentFunction.blockIdentify];
    
    if (value && (([NSDate date].timeIntervalSince1970 -[value doubleValue]) < sameBlockMentionInterval)) {
        return;
    }
    
    HQBlockResult *blockInfunc = [self checkIfBlockInFunction:currentFunction];
    if (!blockInfunc) {return;}
    
    [self checkBlockAttributeToken:currentFunction beforeBlock:blockInfunc textView:textView];
    [self checkBlockSelfTokenAndPropertToken:blockInfunc InFunc:currentFunction textView:textView];
    
}

#pragma mark -- new flag
-(HQFuncResult *)checkIfCurrentLocationInMethod:(NSTextView *)textView
{
   return [textView htp_functionOfCurrentLie];
}

-(HQBlockResult *)checkIfBlockInFunction:(HQFuncResult *)function
{
    return [function hasBlockInsdie];
}

-(void)checkBlockAttributeToken:(HQFuncResult *)function beforeBlock:(HQBlockResult *)block textView:(NSTextView *)textView
{
    NSString *middleCode = [function.funcBody substringToIndex:block.rangeInfunction.location];
    NSArray<NSTextCheckingResult *> *matches = [middleCode htp_allMatchesPatternRegex:@"__block[\\s\\w]+\\*[\\w\\s]+="];
    if (matches.count == 0) {return;}
    
    [self.mentionedBlocks setObject:@([NSDate date].timeIntervalSince1970) forKey:function.blockIdentify];
    
    for (NSTextCheckingResult *match in matches) {
        [self showTip:@"__block不能消除循环引用,请注意是否需要改成__weak" inTextView:textView InRange:NSMakeRange(match.range.location + function.rangeInText.location, match.range.length)];
    }
}

-(void)checkBlockSelfTokenAndPropertToken:(HQBlockResult *)block InFunc:(HQFuncResult *)function textView:(NSTextView *)textView;
{
    NSString *blockCode = block.blockBody;
    NSArray<NSTextCheckingResult *> *matches = [blockCode htp_allMatchesPatternRegex:@"(self\\.[\\w\\s]+=)|(\\[self[\\s\\w]+\\])|(\\[\\s*_[\\w\\s]+\\])|(_\\w+\\.*\\s*=)"];
    if (matches.count == 0) {return;}
    
    [self.mentionedBlocks setObject:@([NSDate date].timeIntervalSince1970) forKey:function.blockIdentify];
    
    NSRange reactiveCocoaMacroRange = [blockCode rangeOfString:@"@strongify"];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.range.location < reactiveCocoaMacroRange.location) {
            [self showTip:@"这里可能对self引用" inTextView:textView InRange:NSMakeRange(match.range.location + function.rangeInText.location + block.rangeInfunction.location, match.range.length)];
        }
    }
}

-(void)showTip:(NSString *)tip inTextView:(NSTextView *)textView InRange:(NSRange)range
{
    NSRect dubiousRect = [textView.layoutManager boundingRectForGlyphRange:range inTextContainer:textView.textContainer];
    
    NSRect tipRect = dubiousRect;
    tipRect.origin.y = tipRect.origin.y - tipRect.size.height - upPadding;
    tipRect.size.width = tip.length * 12;
    tipRect.size.height = 25;
    NSTextField *label = [[NSTextField alloc] initWithFrame:tipRect];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setPlaceholderString:tip];
    [textView addSubview:label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}

@end
