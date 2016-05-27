//
//  MCTGradientButton.m
//  rogerthat
//
//  Created by jorge on 10/05/2016.
//
//

#import "MCTGradientButton.h"
#import "MCTUIUtils.h"

@implementation MCTGradientButton

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.gradientLayer == nil) {
        self.gradientLayer = [MCTUIUtils addGradientToView:self];
    } else {
        self.gradientLayer.frame = self.bounds;
    }
}

@end
