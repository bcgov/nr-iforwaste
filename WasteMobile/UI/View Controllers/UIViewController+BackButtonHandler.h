//
//  UIViewController+BackButtonHandler.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-20.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end