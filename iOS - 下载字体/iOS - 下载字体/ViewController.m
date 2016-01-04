//
//  ViewController.m
//  iOS - 下载字体
//
//  Created by MENGCHEN on 16/1/3.
//  Copyright © 2016年 MENGCHEN. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
@interface ViewController ()
/**  错误信息 */
@property(nonatomic, strong)NSString * errorMsg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark ------------------ 判断是否已经下载好了字体 ------------------
- (BOOL)isFontDownloaded:(NSString*)fontName{
    
    UIFont *afont = [UIFont fontWithName:fontName size:12];
    if (afont &&([afont.fontName compare:fontName]==NSOrderedSame||[afont.familyName compare:fontName]==NSOrderedSame)) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark ------------------ 下载字体 ------------------
- (void)downloadFont:(NSString*)fontName{
    //用字体的Postscript 创建一个字典
    NSMutableDictionary*attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName,kCTFontNameAttribute, nil];
    //创建一个字体描述对象 CTFontDescriptorRef
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    //将字体描述放到一个 NSMutableArray 中
    NSMutableArray*arr = [NSMutableArray array];
    [arr addObject:(__bridge id)desc];
    CFRelease(desc);
    
    
    __block BOOL errorDuringDownload  = NO;
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)arr, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            NSLog(@" 字体已经匹配 ");
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            if (!errorDuringDownload) {
                NSLog(@" 字体 %@ 下载完成 ", fontName);
            }
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            NSLog(@" 字体开始下载 ");
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            NSLog(@" 字体下载完成 ");
            dispatch_async( dispatch_get_main_queue(), ^ {
                // 可以在这里修改 UI 控件的字体
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            NSLog(@" 下载进度 %.0f%% ", progressValue);
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                _errorMsg = [error description];
            } else {
                _errorMsg = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
            // 设置标志
            errorDuringDownload = YES;
            NSLog(@" 下载错误: %@", _errorMsg);
        }
        return (BOOL)YES;
    });
}




@end
