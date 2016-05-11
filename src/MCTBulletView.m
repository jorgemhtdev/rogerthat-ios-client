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

#import "MCTBulletView.h"
#import "MCTUIUtils.h"

@interface MCTBulletView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MCTBulletView

+ (id)bulletViewWithText:(NSString *)text positive:(BOOL)positive  width:(CGFloat)width
{
    T_UI();
    int MARGIN = 5;
    MCTBulletView *v = [[MCTBulletView alloc] init];

    v.textLabel = [[UILabel alloc] init];
    v.textLabel.text = text;
    v.textLabel.numberOfLines = 0;
    v.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

    [v addSubview:v.textLabel];

    v.imageView = [[UIImageView alloc] init];
    v.imageView.image = [UIImage imageNamed:positive ? @"status-green.png" : @"status-red.png"];
    v.imageView.frame = CGRectMake(MARGIN, 8.351, 12, 12);
    v.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [v addSubview:v.imageView];

    CGFloat w = width - 3 * MARGIN - v.imageView.width;

    CGFloat h = [MCTUIUtils sizeForLabel:v.textLabel withWidth:w].height;
    v.textLabel.frame = CGRectMake(v.imageView.right + MARGIN, MARGIN, w, h);

    v.frame = CGRectMake(0, 0, width, h + 2 * v.textLabel.top);
    return v;
}

@end