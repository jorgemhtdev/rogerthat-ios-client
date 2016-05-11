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

#import "MCTFATableViewCell.h"
#import "MCTUIUtils.h"


@implementation MCTFATableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.faImageView = [[FAImageView alloc] init];
        self.faImageView.image = nil;
        [self.contentView addSubview:self.faImageView];

        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    CGFloat M = 5; // margin

    self.faImageView.left = M;
    self.faImageView.top = M;
    self.faImageView.height = self.contentView.height - 2 * self.faImageView.top;
    self.faImageView.width = self.faImageView.height;

    self.textLabel.left = self.faImageView.right + M;
    self.textLabel.width = self.contentView.right - self.textLabel.left - M;
    self.textLabel.height = self.faImageView.height;
    self.textLabel.top = self.faImageView.top;
}

@end