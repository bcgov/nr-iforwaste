//
//  SignatureView.m
//  WasteMobile
//
//  Created by chrisnesmith on 2023-03-27.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import "SignatureView.h"

@implementation SignatureView


- (void)drawRect:(CGRect)rect {
    
    _path.lineCapStyle = kCGLineCapRound;
    [_path stroke];
}
- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        
        [self setMultipleTouchEnabled: NO];
        _path = [UIBezierPath bezierPath];
        [_path setLineWidth:2.0];
        
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_path moveToPoint:[mytouch locationInView:self]];
    [_path addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_path addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
    
    
}


- (void)erase {
    
    _path   = nil;  //Set current path nil
    
    _path   = [UIBezierPath bezierPath]; //Create new path
    [_path setLineWidth:2.0];
    [self setNeedsDisplay];
    
    
    
}
@end
