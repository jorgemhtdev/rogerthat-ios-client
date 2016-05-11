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

#import "MCTGroupCell.h"

@implementation MCTGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier infoViewEnabled:(BOOL)infoViewEnabled
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.infoViewEnabled = infoViewEnabled;
        if (infoViewEnabled) {
            self.infoView = [[UIView alloc] init];
            self.infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [self.infoView addSubview:self.infoButton];
            [self.contentView addSubview:self.infoView];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(5, 5, 50, 50);

    CGFloat x = self.textLabel.left;
    self.textLabel.left = self.imageView.right + 5;
    self.textLabel.width += x - self.textLabel.left;

    if (self.infoViewEnabled) {
        self.infoView.frame = CGRectMake(self.contentView.frame.size.width - 30,
                                         self.contentView.frame.size.height / 2 - 10,
                                         20,
                                         20);

        IF_PRE_IOS7({
            self.infoView.right -= 10;
            self.infoView.top -= 5;
        });

        self.textLabel.width = self.infoView.left - 5 - self.textLabel.left;
    }
}

@end