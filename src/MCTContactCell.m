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

#import "MCTContactCell.h"
#import "MCTUIUtils.h"


@implementation MCTContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        [MCTUIUtils addRoundedBorderToView:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat M = 5;  // margin

    self.imageView.left = M;
    self.imageView.top = M;
    self.imageView.height = self.imageView.superview.height - 2 * self.imageView.top;
    self.imageView.width = self.imageView.height;

    if ([self.accessoryView isKindOfClass:[TTButton class]]){
        self.accessoryView.width = 90;
        self.accessoryView.height = 40;
        self.accessoryView.right = self.accessoryView.superview.width - M;
        IF_PRE_IOS7({
            self.accessoryView.right -= 10;
        });
        self.accessoryView.top = (self.accessoryView.superview.height - self.accessoryView.height + 5) / 2;

        self.contentView.width = self.accessoryView.left - M - self.contentView.left;
    } else {
        self.accessoryView.centerX = self.width - 26;
    }

    self.textLabel.left = self.imageView.right + M;
    self.textLabel.width = self.textLabel.superview.width - self.textLabel.left;

    self.detailTextLabel.left = self.textLabel.left;
    self.detailTextLabel.width = self.textLabel.width;
}

@end