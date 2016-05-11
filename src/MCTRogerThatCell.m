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

#import "MCTHumanMessageCell.h"
#import "MCTRogerThatCell.h"
#import "MCTTransferObjects.h"
#import "MCTUIUtils.h"


@implementation MCTRogerThatCell


+ (MCTRogerThatCell *)cellWithMessage:(MCTMessage *)message
{
    T_UI();
    MCTRogerThatCell *cell = [[MCTRogerThatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:MCT_RT_IDENTIFIER];
    cell.message = message;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.ttBtn = [TTButton buttonWithStyle:MCT_STYLE_DISMISS_SMALL_BUTTON
                                         title:NSLocalizedString(@"Roger that", nil)];
        [self.ttBtn addTarget:self action:@selector(onDismissButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.ttBtn];
    }
    return self;
}

- (void)onDismissButtonClicked:(id)sender
{
    T_UI();
    [MCTMessageHelper onDismissThreadClickedForMessage:self.message];
    self.ttBtn.enabled = NO;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    MCT_com_mobicage_to_messaging_ButtonTO *btnTO = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
    btnTO.caption = [self.ttBtn titleForState:UIControlStateNormal];
    self.ttBtn.height = [MCTHumanMessageCell sizeOfTTBtnWithButton:btnTO].height;
    self.ttBtn.width = self.width - 10;
    self.ttBtn.center = self.contentView.center;
}

@end