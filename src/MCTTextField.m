//
//  MCTTextField.m
//  rogerthat
//
//  Created by jorge on 18/05/2016.
//
//

#import "MCTTextField.h"

@implementation MCTTextField

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.underlineLayer == nil) {
        self.underlineLayer = [CALayer layer];
        self.underlineLayer.backgroundColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:self.underlineLayer];

        self.borderStyle = UITextBorderStyleNone;
    }

    CGRect frame = self.bounds;
    frame.origin.y = self.bounds.size.height - 1;
    frame.size.height = 1;
    self.underlineLayer.frame = frame;
}

@end