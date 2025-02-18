//
//  SignatureView.h
//  WasteMobile
//
//  Created by chrisnesmith on 2023-03-27.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIView
{
    UIBezierPath *_path;
}
- (void)erase;
@end
