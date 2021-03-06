//
//  InterpreterView.m
//  EnglishReader
//
//  Created by QMTV on 17/1/8.
//  Copyright © 2017年 LFC. All rights reserved.
//

#define kLoadReferenceHTMLString @"loadReferenceHTMLString"

#import "InterpreterViewLocal.h"
#import "YYKit.h"
#import <objc/runtime.h>
#import <UIKit/UIReferenceLibraryViewController.h>

@interface UIWebView (reference)
- (void)loadReferenceHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
@end

@implementation UIWebView (reference)

- (void)loadReferenceHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:string, @"html", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadReferenceHTMLString object:nil userInfo:userInfo];
}

@end


@interface InterpreterViewLocal ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIReferenceLibraryViewController *reference;

@end

@implementation InterpreterViewLocal

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        Class class = [UIWebView class];
        Method originalMethod = class_getInstanceMethod(class, @selector(loadHTMLString:baseURL:));
        Method newMethod = class_getInstanceMethod(class, @selector(loadReferenceHTMLString:baseURL:));
        method_exchangeImplementations(originalMethod, newMethod);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReferenceHTMLString:) name:kLoadReferenceHTMLString object:nil];
        
        [self addSubview:self.webView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.webView.frame = self.bounds;
    self.webView.backgroundColor = [UIColor whiteColor];
}

- (void)interpretWithText:(NSString *)text {
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:text]) {
        if (self.reference) {
            [self.reference.view removeFromSuperview];
            self.reference = nil;
        }

        self.reference = [[UIReferenceLibraryViewController alloc] initWithTerm:text];
        [self addSubview:self.reference.view];
        [self bringSubviewToFront:self.webView];
    }
}

#pragma mark ---- Notification

- (void)loadReferenceHTMLString:(NSNotification *)notification
{
    NSString *html = [notification.userInfo objectForKey:@"html"];
    [self.webView loadReferenceHTMLString:html baseURL:nil];
}

#pragma mark ---- getter

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
    }
    
    return _webView;
}


@end
