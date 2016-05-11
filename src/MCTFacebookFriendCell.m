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

#import "MCTFacebookFriendCell.h"
#import "MCTUIUtils.h"


@implementation MCTFacebookFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.ttButton = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_SMALL_BUTTON
                                            title:NSLocalizedString(@"Add", nil)];
        [self.contentView addSubview:self.ttButton];
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    CGFloat M = 5; // margin

    self.ttButton.width = 90;
    self.ttButton.height = 40;
    self.ttButton.right = self.contentView.width - M;
    self.ttButton.top = (self.ttButton.superview.height - self.ttButton.height + 5) / 2;

    self.textLabel.width = self.ttButton.left - self.textLabel.left - M;
}

@end