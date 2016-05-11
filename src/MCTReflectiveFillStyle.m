/*
 * Copyright 2016 Mobicage NV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @@license_version:1.1@@
 */

#import "MCTReflectiveFillStyle.h"

#import "TTShape.h"
#import "TTStyleContext.h"

#import "TTStyleInternal.h"


@implementation MCTReflectiveFillStyle


+ (MCTReflectiveFillStyle*)styleWithColor:(UIColor*)color 
                  topEndHighlightLocation:(CGFloat)topEndHighlightLocation
                                     next:(TTStyle*)next
{
    T_UI();
    MCTReflectiveFillStyle* style = [[self alloc] initWithNext:next];
    style.color = color;
    style.topEndHighlightLocation = topEndHighlightLocation;
    style.withBottomHighlight = NO;
    return style;
}

+ (MCTReflectiveFillStyle*)styleWithColor:(UIColor*)color
                  topEndHighlightLocation:(CGFloat)topEndHighlightLocation
                      withBottomHighlight:(BOOL)withBottomHighlight 
                                     next:(TTStyle*)next
{
    T_UI();
    MCTReflectiveFillStyle* style = [[self alloc] initWithNext:next];
    style.color = color;
    style.topEndHighlightLocation = topEndHighlightLocation;
    style.withBottomHighlight = withBottomHighlight;
    return style;
}

// Function content is copy/pasted from TTReflectiveFillStyle.m
// The only change is the locations[] array: 0.1 insted of 0.5
- (void)draw:(TTStyleContext*)context 
{
    T_UI();
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = context.frame;
    
    CGContextSaveGState(ctx);
    [context.shape addToPath:rect];
    CGContextClip(ctx);
    
    // Draw the background color
    [_color setFill];
    CGContextFillRect(ctx, rect);
    
    // The highlights are drawn using an overlayed, semi-transparent gradient.
    // The values here are absolutely arbitrary. They were nabbed by inspecting the colors of
    // the "Delete Contact" button in the Contacts app.
    UIColor* topStartHighlight = [UIColor colorWithWhite:1.0 alpha:0.685];
    UIColor* topEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.13];
    UIColor* clearColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    UIColor* botEndHighlight;
    if ( _withBottomHighlight ) {
        botEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.27];
        
    } else {
        botEndHighlight = clearColor;
    }
    
    UIColor* __autoreleasing colors[] = {
        topStartHighlight, topEndHighlight,
        clearColor,
        clearColor, botEndHighlight};
    CGFloat locations[] = {0, self.topEndHighlightLocation, 0.5, 0.6, 1.0};
    
    CGGradientRef gradient = [self newGradientWithColors:colors locations:locations count:5];
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                                CGPointMake(rect.origin.x, rect.origin.y+rect.size.height), 0);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}

@end