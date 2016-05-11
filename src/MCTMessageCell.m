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

#import <QuartzCore/QuartzCore.h>

#import "MCTComponentFramework.h"
#import "MCTFriendsPlugin.h"
#import "MCTMemberStatusSummaryEncoding.h"
#import "MCTMessageCell.h"
#import "MCTMessageEnums.h"
#import "MCTMessagesPlugin.h"
#import "MCTMessage.h"
#import "MCTUIUtils.h"

#define MCT_ICON_MESSAGE_STATUS_ERROR           @"status-red.png"
#define MCT_ICON_MESSAGE_STATUS_DELIVERED       @"status-yellow.png"
#define MCT_ICON_MESSAGE_STATUS_RECEIVED        @"status-green.png"
#define MCT_ICON_MESSAGE_STATUS_ACKED           @"status-blue.png"
#define MCT_ICON_MESSAGE_STATUS_RINGING         @"status-ringing.png"
#define MCT_ICON_MESSAGE_STATUS_LOCKED          @"lock-closed.png"

#define MCT_INDENT_PMSG 5
#define MCT_INDENT_REPLY 22

#define MCT_SENDERLABEL_FORMAT @"%@ >> %@"


@implementation MCTMessageCell

- (id)initWithReuseIdentifier:(NSString *)ident andFilterType:(MCTMessageFilterType)filterType
{
    T_UI();
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.backgroundColor = [UIColor clearColor];

        self.type = filterType;

        self.avatarImageView = [[UIImageView alloc] init];
        [MCTUIUtils addRoundedBorderToView:self.avatarImageView];
        [self.contentView addSubview:self.avatarImageView];

        self.statusImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.statusImageView];

        self.msgLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.msgLabel];

        self.countLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.countLabel];

        self.senderLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.senderLabel];

        self.timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.timeLabel];

        self.msgLabel.backgroundColor = [UIColor clearColor];
        self.msgLabel.font = [UIFont systemFontOfSize:16];
        self.msgLabel.numberOfLines = 2;
        self.msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        self.senderLabel.backgroundColor = [UIColor clearColor];
        self.senderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.senderLabel.font = [UIFont systemFontOfSize:14];

        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = self.senderLabel.font;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;

        self.countLabel.font = [UIFont systemFontOfSize:self.timeLabel.font.pointSize];
        self.countLabel.numberOfLines = 1;
        self.countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        [MCTUIUtils addRoundedBorderToView:self.countLabel
                           withBorderColor:[UIColor clearColor]
                           andCornerRadius:5];

        [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                       forIntentActions:@[kINTENT_MESSAGE_MODIFIED,
                                                                          kINTENT_MESSAGE_REPLACED,
                                                                          kINTENT_FRIEND_MODIFIED,
                                                                          kINTENT_FRIEND_REMOVED,
                                                                          kINTENT_FRIEND_ADDED,
                                                                          kINTENT_IDENTITY_MODIFIED,
                                                                          kINTENT_THREAD_ACKED,
                                                                          kINTENT_THREAD_MODIFIED,
                                                                          ]
                                                                onQueue:[MCTComponentFramework mainQueue]];
    }
    return self;
}

- (void)showSenderLabelText
{
    BOOL isDynamicChat = IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat);
    NSDictionary *chatData = nil;
    if (isDynamicChat) {
        if (self.message.parent_key == nil) {
            chatData = [self.message.message MCT_JSONValue];
        } else {
            MCTMessage *parentMessage = [[MCTComponentFramework messagesPlugin].store messageInfoByKey:self.message.parent_key];
            chatData = [parentMessage.message MCT_JSONValue];
        }
    }

    [self showSenderLabelTextWithIsDynamicChat:isDynamicChat
                                      chatData:chatData];
}

- (void)showSenderLabelTextWithIsDynamicChat:(BOOL)isDynamicChat
                                    chatData:(NSDictionary *)chatData
{
    MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
    NSString *senderName = [friendsPlugin isMyEmail:self.message.sender] ? NSLocalizedString(@"__me_as_sender", nil)
                                                                         : [friendsPlugin friendDisplayNameByEmail:self.message.sender];

    if (isDynamicChat) {
        self.senderLabel.text = chatData[@"t"]; // chat topic
    } else {
        self.senderLabel.text = [NSString stringWithFormat:MCT_SENDERLABEL_FORMAT, senderName, self.message.recipients];
    }
}

- (void)showStatusIcon
{
    T_UI();
    if ((self.isLocked = IS_FLAG_SET(self.message.flags, MCTMessageFlagLocked))) {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_LOCKED];

    } else if (self.message.recipientsStatus == kMemberStatusSummaryError) {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_ERROR];

    } else if (self.message.recipientsStatus == kMemberStatusSummaryNone) {
        self.statusImageView.image = nil;

    } else if ([[MCTComponentFramework messagesPlugin] isTmpKey:self.message.key]) {
        self.statusImageView.image = nil;

    } else if (self.message.alert_flags >= MCTAlertFlagRing5 && self.message.threadNeedsMyAnswer) {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_RINGING];

    } else if (IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat)) {
        self.statusImageView.image = nil;

    } else if ([self.message numAcked] != 0) {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_ACKED];

    } else if ([self.message numReceived] == [self.message numRecipients]) {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_RECEIVED];

    } else {
        self.statusImageView.image = [UIImage imageNamed:MCT_ICON_MESSAGE_STATUS_DELIVERED];
    }
}

- (void)showAvatarImage
{
    UIImage *image = nil;
    if (self.message.thread_avatar_hash) {
        image = [[MCTComponentFramework messagesPlugin] threadAvatarWithHash:self.message.thread_avatar_hash];
    } else if (IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat)) {
        image = [UIImage imageNamed:@"group.png"];
    }


    if (image) {
        self.avatarImageView.image = image;
    } else if ([MCT_SYSTEM_FRIEND_EMAIL isEqualToString:self.message.sender]
               || [[MCTComponentFramework friendsPlugin].store friendTypeByEmail:self.message.sender] == MCTFriendTypeService) {

        self.avatarImageView.image = [[MCTComponentFramework friendsPlugin] friendAvatarImageByEmail:self.message.sender];
    }
    else if ([self.message.members count] == 2) {
        NSString *otherOne = nil;
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *ms in self.message.members) {
            if (![[MCTComponentFramework friendsPlugin] isMyEmail:ms.member]) {
                otherOne = ms.member;
                break;
            }
        }

        if (!otherOne) {
            otherOne = self.message.sender;
        }

        self.avatarImageView.image = [[MCTComponentFramework friendsPlugin] friendAvatarImageByEmail:otherOne];
    }
    else {
        self.avatarImageView.image = [UIImage imageNamed:@"group.png"];
    }
}

- (void)onUpdateTimeLabelTimeout:(NSTimer *)timer
{
    T_UI();
    if (timer == self.timeLabelTimer) {
        [self.timeLabelTimer invalidate];
        MCT_RELEASE(self.timeLabelTimer);

        self.timeLabel.text = [MCTUtils timestampShortNotation:self.message.timestamp andShowMinutes:YES];
        [self layoutSubviews];

        MCTlong updateTimeLabelIn = [MCTUtils updateTimestampIn:self.message.timestamp];
        if (updateTimeLabelIn != 0) {
            self.timeLabelTimer = [NSTimer scheduledTimerWithTimeInterval:updateTimeLabelIn
                                                                   target:self
                                                                 selector:@selector(onUpdateTimeLabelTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        }
    }
}

- (void)setMessage:(MCTMessage *)msg
{
    T_UI();
    if (_message == msg) {
        return;
    }
    _message = msg;

    [self.timeLabelTimer invalidate];
    MCT_RELEASE(self.timeLabelTimer);

    if (msg == nil)
        return;

    self.indentationLevel = MCT_INDENT_PMSG;

    BOOL isDynamicChat = IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat);
    NSDictionary *chatData = nil;

    if (isDynamicChat) {
        if (self.message.parent_key == nil) {
            chatData = [self.message.message MCT_JSONValue];
        } else {
            MCTMessage *parentMessage = [[MCTComponentFramework messagesPlugin].store messageInfoByKey:self.message.parent_key];
            chatData = [parentMessage.message MCT_JSONValue];
        }
    }

    self.msgLabel.font = [UIFont systemFontOfSize:16];
    self.senderLabel.font = [UIFont systemFontOfSize:14];

    if (self.message.parent_key == nil && isDynamicChat) {
        self.msgLabel.text = chatData[@"d"]; // chat description
    } else {
        self.msgLabel.text = [self.message.message stringByReplacingOccurrencesOfString:@"\\s+"
                                                                             withString:@" "
                                                                                options:NSRegularExpressionSearch
                                                                                  range:NSMakeRange(0, [self.message.message length])];
    }

    if ([MCTUtils isEmptyOrWhitespaceString:self.msgLabel.text]) {
        if (self.message.buttons != nil && self.message.buttons.count > 0) {
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            for (MCT_com_mobicage_to_messaging_ButtonTO *button in self.message.buttons) {
                [buttons addObject:button.caption];
            }
            self.msgLabel.text = [buttons componentsJoinedByString:@" / "];
        } else if (self.message.attachments != nil && self.message.attachments.count > 0) {
            NSMutableSet *attachments = [[NSMutableSet alloc] init];
            for (MCT_com_mobicage_to_messaging_AttachmentTO *attachment in self.message.attachments) {
                if (![MCTUtils isEmptyOrWhitespaceString:attachment.name]) {
                    [attachments addObject:attachment.name];
                } else if ([attachment.content_type hasPrefix:@"video/"]) {
                    [attachments addObject:NSLocalizedString(@"<Video>", nil)];
                } else if ([attachment.content_type hasPrefix:@"image/"]) {
                    [attachments addObject:NSLocalizedString(@"<Picture>", nil)];
                } else {
                    LOG(@"Not added attachment with type '%@' because no translation found", attachment.content_type);
                }
            }
            if (attachments.count > 0) {
                self.msgLabel.text = [[attachments allObjects] componentsJoinedByString:@", "];
            }
        }
    }

    long replyCount = self.message.replyCount;
    if (isDynamicChat) {
        replyCount--; // 1st message defines the chat topic and
    }
    long messageCountText = 0;
    if (MCT_MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT) {
        if (replyCount > 1) {
            messageCountText = replyCount;
        } else {
            messageCountText = 0;
        }
    } else {
        messageCountText = self.message.unreadCount;
        if (isDynamicChat && replyCount < messageCountText) {
            messageCountText--;
        }
    }
    self.countLabel.text = messageCountText >= 1 ? [NSString stringWithFormat:@"%ld", messageCountText] : nil;

    [self showSenderLabelTextWithIsDynamicChat:isDynamicChat chatData:chatData];

    MCTlong updateTimeLabelIn = [MCTUtils updateTimestampIn:self.message.timestamp];
    if (updateTimeLabelIn != 0) {
        self.timeLabelTimer = [NSTimer scheduledTimerWithTimeInterval:updateTimeLabelIn
                                                               target:self
                                                             selector:@selector(onUpdateTimeLabelTimeout:)
                                                             userInfo:nil
                                                              repeats:NO];
    }

    self.timeLabel.text = [MCTUtils timestampShortNotation:self.message.timestamp andShowMinutes:YES];

    [self showAvatarImage];

    if (self.message.thread_background_color) {
        self.backgroundColor = [UIColor colorWithString:self.message.thread_background_color];
    } else {
        if (self.message.priority == MCTMessagePriorityHigh) {
            self.backgroundColor = [UIColor MCPriorityHighBackgroundColor];
        } else if (self.message.priority == MCTMessagePriorityUrgent || self.message.priority == MCTMessagePriorityUrgentWithAlarm) {
            self.backgroundColor = [UIColor MCPriorityUrgentBackgroundColor];
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
    }

    [self showStatusIcon];

    if (!self.message.threadDirty) {
        self.msgLabel.font = [UIFont systemFontOfSize:self.msgLabel.font.pointSize];
        self.timeLabel.font = [UIFont systemFontOfSize:self.timeLabel.font.pointSize];
        self.senderLabel.font = [UIFont systemFontOfSize:self.senderLabel.font.pointSize];
    } else {
        if (self.message.threadNeedsMyAnswer) {
            self.msgLabel.font = [UIFont boldSystemFontOfSize:self.msgLabel.font.pointSize];
            self.timeLabel.font = [UIFont boldSystemFontOfSize:self.timeLabel.font.pointSize];
            self.senderLabel.font = [UIFont boldSystemFontOfSize:self.senderLabel.font.pointSize];
        } else {
            self.msgLabel.font = [UIFont italicSystemFontOfSize:self.msgLabel.font.pointSize];
            self.timeLabel.font = [UIFont italicSystemFontOfSize:self.timeLabel.font.pointSize];
            self.senderLabel.font = [UIFont italicSystemFontOfSize:self.senderLabel.font.pointSize];
        }
    }
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat m = 5;

    CGRect bounds = self.contentView.bounds;

    // Avatar
    CGFloat aW = 50;
    CGRect aFrame = CGRectMake(self.indentationLevel, m, aW, aW);
    self.avatarImageView.frame = aFrame;

    // Time Label - calculate width of time label text
    CGSize tMax = CGSizeMake(100, 18);
    CGSize tSize = [self.timeLabel sizeThatFits:tMax];

    CGRect tFrame = CGRectMake(bounds.size.width - m - tSize.width, m, tSize.width, tMax.height);
    self.timeLabel.frame = tFrame;

    // Sender Label
    CGFloat rX = CGRectGetMaxX(aFrame) + m;
    CGRect rFrame = CGRectMake(rX, m, tFrame.origin.x - rX - m, 18);
    self.senderLabel.frame = rFrame;

    // Status
    CGFloat sW = 12;
    CGFloat sH = sW * 19/12;
    CGFloat sX = bounds.size.width - m - sW;
    CGFloat sY = CGRectGetMaxY(tFrame);

    if (self.statusImageView.image == nil) {
        sX += m + sW;
        sW = 0;
    }

    CGRect sFrame = CGRectMake(sX, sY, sW, sH);
    self.statusImageView.frame = sFrame;

    // Number of replies
    if ([MCTUtils isEmptyOrWhitespaceString:self.countLabel.text]) {
        self.countLabel.frame = CGRectZero;
        self.countLabel.right = self.statusImageView.left;
    } else {
        CGSize cSize = [MCTUIUtils sizeForLabel:self.countLabel withWidth:40];
        self.countLabel.width = cSize.width + 8;
        self.countLabel.height = cSize.height;
        self.countLabel.center = self.statusImageView.center;
        self.countLabel.right = self.statusImageView.left - m;
    }

    // Message Label - calculate height for vertical alignment
    CGSize mMax = CGSizeMake(self.countLabel.left - rX - m, bounds.size.height - m - CGRectGetMaxY(rFrame));
    CGRect mFrame = CGRectMake(rX, CGRectGetMaxY(rFrame), mMax.width, mMax.height);
    self.msgLabel.frame = mFrame;
    self.countLabel.centerY = self.statusImageView.centerY = self.msgLabel.centerY;

    if (self.selected && !self.editing) {
        // Selected, has blue blackground
        self.msgLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textColor = self.senderLabel.textColor = [UIColor whiteColor];
        self.countLabel.backgroundColor = [UIColor whiteColor];
        self.countLabel.textColor = [UIColor blueColor];

    } else if (self.message.thread_background_color != nil) {
        UIColor *bgColor = [UIColor colorWithString:self.message.thread_background_color];

        CGFloat white;
        CGFloat alpha;
        BOOL success = [bgColor getWhite:&white alpha:&alpha];

        BOOL lightBg = (!success || white > 0.5);

        UIColor *textColor;

        if (self.message.thread_text_color == nil) {
            if (self.message.priority == MCTMessagePriorityHigh) {
                textColor = [UIColor MCPriorityHighTextColor];
            } else if (self.message.priority == MCTMessagePriorityUrgent || self.message.priority == MCTMessagePriorityUrgentWithAlarm) {
                textColor = [UIColor MCPriorityUrgentTextColor];
            } else {
                // Detect color scheme
                textColor = lightBg ? [UIColor blackColor] : [UIColor whiteColor];
            }
        } else {
            textColor = [UIColor colorWithString:self.message.thread_text_color];
        }

        self.msgLabel.textColor = textColor;
        // time and sender lbl a little bit lighter
        self.timeLabel.textColor = self.senderLabel.textColor = [textColor colorWithAlphaComponent:0.8];

        self.countLabel.backgroundColor = [UIColor colorWithWhite:lightBg ? 0 : 1
                                                            alpha:lightBg ? 0.25 : 0.75];
        self.countLabel.textColor = [UIColor colorWithWhite:lightBg ? 1 : 0
                                                      alpha:1];

    } else {
        // Default
        if (self.message.thread_text_color == nil) {
            if (self.message.priority == MCTMessagePriorityHigh) {
                self.msgLabel.textColor = [UIColor MCPriorityHighTextColor];
                self.timeLabel.textColor = self.senderLabel.textColor = [self.msgLabel.textColor colorWithAlphaComponent:0.8];
            } else if (self.message.priority == MCTMessagePriorityUrgent || self.message.priority == MCTMessagePriorityUrgentWithAlarm) {
                self.msgLabel.textColor = [UIColor MCPriorityUrgentTextColor];
                self.timeLabel.textColor = self.senderLabel.textColor = [self.msgLabel.textColor colorWithAlphaComponent:0.8];
            } else {
                self.msgLabel.textColor = [UIColor blackColor];
                self.timeLabel.textColor = self.senderLabel.textColor = [UIColor grayColor];
            }
        } else {
            UIColor *textColor = [UIColor colorWithString:self.message.thread_text_color];
            self.msgLabel.textColor = textColor;
            // time and sender lbl a little bit lighter
            self.timeLabel.textColor = self.senderLabel.textColor = [textColor colorWithAlphaComponent:0.8];
        }

        self.countLabel.backgroundColor = [UIColor lightGrayColor];
        self.countLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark -
#pragma mark IMCTIntentReceiver

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MESSAGE_REPLACED) {
        if ([self.message.key isEqualToString:[intent stringForKey:@"tmp_key"]]) {
            self.message.key = [intent stringForKey:@"key"];
            // Force status delivered
            self.message.recipientsStatus = [MCTMemberStatusSummaryEncoding encodeMessageMemberSummaryWithRecipients:1
                                                                                                         andReceived:0
                                                                                                     andQuickReplied:0
                                                                                                        andDismissed:0];
            [self showStatusIcon];
            [self setNeedsLayout];
        }
    } else if (intent.action == kINTENT_MESSAGE_MODIFIED) {
        if ([self.message.key isEqualToString:[intent stringForKey:@"message_key"]]
            || (IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat)
                && [self.message.threadKey isEqualToString:[intent stringForKey:@"message_key"]])) {

            self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.message.key];
        }
    } else if (intent.action == kINTENT_FRIEND_MODIFIED || intent.action == kINTENT_FRIEND_ADDED
               || intent.action == kINTENT_FRIEND_REMOVED || intent.action == kINTENT_IDENTITY_MODIFIED) {
        if ([self.message.sender isEqualToString:[intent stringForKey:@"email"]]) {
            [self showAvatarImage];
            [self showSenderLabelText];
        }
    } else if (intent.action == kINTENT_THREAD_ACKED) {
        if (![self.message.threadKey isEqualToString:[intent stringForKey:@"thread_key"]])
            return;

        NSArray *messageKeys = [[intent stringForKey:@"message_keys"] MCT_JSONValue];
        if ([messageKeys containsObject:self.message.key]) {
            self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.message.key];
        }
    } else if (intent.action == kINTENT_THREAD_MODIFIED) {
        if ([self.message.threadKey isEqualToString:[intent stringForKey:@"thread_key"]]) {
            self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.message.key];
        }
    } else if (intent.action == kINTENT_THREAD_AVATAR_RETREIVED) {
        if ([[intent stringForKey:@"thread_avatar_hash"] isEqualToString:self.message.thread_avatar_hash]) {
            self.message = [[[MCTComponentFramework messagesPlugin] store] messageDetailsByKey:self.message.key];
        }
    }
}

#pragma mark -

@end