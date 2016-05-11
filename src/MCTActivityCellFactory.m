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

#import "MCTActivityCellFactory.h"
#import "MCTActivity.h"
#import "MCTActivityEnums.h"
#import "MCTComponentFramework.h"
#import "MCTFriendsPlugin.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#define MCT_ACTIVITY_ICON_INFO  @"act_info.png"
#define MCT_ACTIVITY_ICON_ERROR @"act_error.png"

#define MCT_ACTIVITY_ICON_MSG_RECEIVED          @"act_msg_new_received.png"
#define MCT_ACTIVITY_ICON_MSG_SENT              @"act_msg_new_sent.png"
#define MCT_ACTIVITY_ICON_QUICKREPLY_RECEIVED   @"act_msg_quickreply_received.png"
#define MCT_ACTIVITY_ICON_QUICKREPLY_SENT       @"act_msg_quickreply_sent.png"
#define MCT_ACTIVITY_ICON_MSG_LOCKED_BY_ME      @"act_msg_locked_by_me.png"
#define MCT_ACTIVITY_ICON_MSG_LOCKED_BY_OTHER   @"act_msg_locked_by_other.png"
#define MCT_ACTIVITY_ICON_MSG_REPLY_RECEIVED    @"act_msg_reply_received.png"
#define MCT_ACTIVITY_ICON_MSG_REPLY_SENT        @"act_msg_reply_sent.png"
#define MCT_ACTIVITY_ICON_MSG_DISMISSED_BY_ME   @"act_msg_dismissed_by_me.png"
#define MCT_ACTIVITY_ICON_MSG_DISMISSED_BY_OTHER @"act_msg_dismissed_by_other.png"

#define MCT_ACTIVITY_ICON_FRIEND_ADDED          @"act_friend_plus.png"
#define MCT_ACTIVITY_ICON_FRIEND_REMOVED        @"act_friend_minus.png"
#define MCT_ACTIVITY_ICON_FRIEND_UPDATED        @"act_friend_updated.png"
#define MCT_ACTIVITY_ICON_FRIEND_BECAME_FRIEND  @"act_friend_added_friend.png"

#define MCT_ACTIVITY_ICON_LOCATION_SENT         @"act_location_sent.png"


@implementation MCTActivityCell


- (id)initWithReuseIdentifier:(NSString *)ident
{
    T_UI();
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.separatorView = [[UIView alloc] init];
        self.separatorView.backgroundColor = [UIColor MCTSeparatorColor];
        [self.contentView addSubview:self.separatorView];

        self.iconImageView = [[UIImageView alloc] init];
        [MCTUIUtils addRoundedBorderToView:self.iconImageView  withBorderColor:[UIColor clearColor] andCornerRadius:5];
        [self.contentView addSubview:self.iconImageView];

        self.timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.timeLabel];

        self.detailView = [[UIView alloc] init];
        [self.contentView addSubview:self.detailView];

        self.timeLabel.numberOfLines = 1;
        self.timeLabel.adjustsFontSizeToFitWidth = NO;
        self.timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.timeLabel.font = [UIFont systemFontOfSize:13];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setActivity:(MCTActivity *)newActivity
{
    T_UI();
    if ( _activity == newActivity) {
        return;
    }

    _activity = newActivity;

    if (self.activity != nil) {
        self.iconImageView.image = [MCTActivityCellFactory iconImageForActivity:self.activity];
        self.timeLabel.text = [MCTUtils timestampNotation:[MCTUtils serverTimeFromClientTime:self.activity.timestamp]];
        UIImage *overlayImage = [MCTActivityCellFactory iconOverlayForActivity:self.activity];
        if (overlayImage) {
            [self performSelectorOnMainThread:@selector(addOverlayImage:) withObject:overlayImage waitUntilDone:NO];
        }
    }
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect bounds = self.contentView.bounds;

    self.separatorView.frame = CGRectMake(0, self.bounds.size.height, self.contentView.bounds.size.width, 1);

    CGFloat m = 5;
    CGFloat w = fmin(50, bounds.size.height - (2 * m));
    CGRect iFrame = CGRectMake(m, m, w, w);
    self.iconImageView.frame = iFrame;

    CGFloat x2 = iFrame.origin.x + iFrame.size.width + 2 * m;
    CGRect tFrame = CGRectMake(x2, m, bounds.size.width - x2 - m, 15);
    self.timeLabel.frame = tFrame;

    CGFloat y2 = tFrame.origin.y + tFrame.size.height + 2;
    CGRect dFrame = CGRectMake(x2, y2, tFrame.size.width, bounds.size.height - y2 - m);
    self.detailView.frame = dFrame;
}

- (void)addOverlayImage:(UIImage *)img
{
    T_UI();
    CGRect iFrame = self.iconImageView.frame;

    CGFloat M = 4;

    CGFloat oW = 25;
    CGRect oFrame = CGRectMake(M / 2, M / 2, oW, oW);

    UIImageView *overlay = [[UIImageView alloc] initWithImage:img];
    overlay.frame = oFrame;

    CGRect vFrame;
    vFrame.origin.x = iFrame.origin.x + iFrame.size.width - oW + M / 2;
    vFrame.origin.y = iFrame.origin.y + iFrame.size.height - oW + M / 2;
    vFrame.size.width = oW + M;
    vFrame.size.height = oW + M;

    UIView *overlayView = [[UIView alloc] initWithFrame:vFrame];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.8;
    overlayView.tag = 22000;

    [MCTUIUtils addRoundedBorderToView:overlayView];
    [overlayView addSubview:overlay];

    UIView *oldView = [self.contentView viewWithTag:overlayView.tag];
    if (oldView)
        [oldView removeFromSuperview];

    [self.contentView addSubview:overlayView];
}

@end

#pragma mark -


@interface MCTSimpleActivityCell : MCTActivityCell

@property (nonatomic, retain) UILabel *descriptionLabel;

- (id)initWithReuseIdentifier:(NSString *)ident;

@end


@implementation MCTSimpleActivityCell


- (id)initWithReuseIdentifier:(NSString *)ident
{
    T_UI();
    if (self = [super initWithReuseIdentifier:ident]) {
        self.descriptionLabel = [[UILabel alloc] init];
        [self.detailView addSubview:self.descriptionLabel];

        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.numberOfLines = 3;
        self.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect bounds = self.detailView.bounds;
    // Calculate text height for vertical alignment

    CGSize size = [self.descriptionLabel sizeThatFits:bounds.size];
    self.descriptionLabel.frame = CGRectMake(0, 0, bounds.size.width, size.height);
}

@end

#pragma mark -


@interface MCTTripleLabelActivityCell : MCTActivityCell {
    UILabel *headerLabel_;
    UILabel *upperLabel_;
    UILabel *lowerLabel_;
}
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UILabel *upperLabel;
@property (nonatomic, retain) UILabel *lowerLabel;
@end


@implementation MCTTripleLabelActivityCell


- (id)initWithReuseIdentifier:(NSString *)ident
{
    T_UI();
    if (self = [super initWithReuseIdentifier:ident]) {
        for (int i = 0; i < 3; i++) {
            UILabel *lbl = [[UILabel alloc] init];
            [self.detailView addSubview:lbl];

            lbl.font = [UIFont systemFontOfSize:14];
            lbl.numberOfLines = 1;
            lbl.lineBreakMode = NSLineBreakByTruncatingTail;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
        }

        self.headerLabel = [self.detailView.subviews objectAtIndex:0];
        self.upperLabel = [self.detailView.subviews objectAtIndex:1];
        self.lowerLabel = [self.detailView.subviews objectAtIndex:2];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGRect bounds = self.detailView.bounds;
    // Calculate text height for vertical alignment
    CGSize maxSize = CGSizeMake(bounds.size.width, bounds.size.height / 3);
    CGSize size = [self.headerLabel sizeThatFits:maxSize];

    self.headerLabel.frame = CGRectMake(0, 0, bounds.size.width, size.height);
    self.upperLabel.frame = CGRectMake(0, size.height, bounds.size.width, size.height);
    self.lowerLabel.frame = CGRectMake(0, 2 * size.height, bounds.size.width, size.height);
}

@end

#pragma mark -


@interface MCTFriendAddedCell : MCTSimpleActivityCell
@end


@implementation MCTFriendAddedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *friendName = [self.activity.parameters valueForKey:MCT_ACTIVITY_FRIEND_NAME];
    if (friendName == nil)
        friendName = [MCTActivityCellFactory friendDisplayNameForActivity:self.activity];
    NSString *format;
    if (IS_ENTERPRISE_APP) {
        format = NSLocalizedString(@"You are now connected to %@", nil);
    } else {
        format = NSLocalizedString(@"You are now friends with %@", nil);
    }
    self.descriptionLabel.text = [NSString stringWithFormat:format, friendName];
}

@end

#pragma mark -


@interface MCTFriendUpdatedCell : MCTSimpleActivityCell
@end


@implementation MCTFriendUpdatedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *friendName = [self.activity.parameters valueForKey:MCT_ACTIVITY_FRIEND_NAME];
    if (friendName == nil)
        friendName = [MCTActivityCellFactory friendDisplayNameForActivity:self.activity];
    NSNumber *friendType = [self.activity.parameters objectForKey:MCT_ACTIVITY_FRIEND_TYPE];
    NSString *format;
    if (friendType != nil && [friendType intValue] == MCTFriendTypeService) {
        format = NSLocalizedString(@"Service updated: %@", nil);
    } else {
        switch (MCT_FRIENDS_CAPTION) {
            case MCTFriendsCaptionColleagues: {
                format = NSLocalizedString(@"Colleague updated: %@", nil);
                break;
            }
            case MCTFriendsCaptionContacts: {
                format = NSLocalizedString(@"Contact updated: %@", nil);
                break;
            }
            case MCTFriendsCaptionFriends:
            default: {
                format = NSLocalizedString(@"Friend updated: %@", nil);
                break;
            }
        }
    }
    self.descriptionLabel.text = [NSString stringWithFormat:format, friendName];
}

@end

#pragma mark -


@interface MCTFriendRemovedCell : MCTSimpleActivityCell
@end


@implementation MCTFriendRemovedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *friendName = [self.activity.parameters valueForKey:MCT_ACTIVITY_FRIEND_NAME];
    if (friendName == nil)
        friendName = [MCTActivityCellFactory friendDisplayNameForActivity:self.activity];
    NSString *format;
    if (IS_ENTERPRISE_APP) {
        format = NSLocalizedString(@"You are no longer connected to %@", nil);
    } else {
        format = NSLocalizedString(@"You are no longer friends with %@", nil);
    }
    self.descriptionLabel.text = [NSString stringWithFormat:format, friendName];
}

@end

#pragma mark -


@interface MCTFriendBecameFriendCell : MCTSimpleActivityCell
@end


@implementation MCTFriendBecameFriendCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *friendName = [self.activity.parameters valueForKey:MCT_ACTIVITY_FRIEND_NAME];
    NSString *relationName = [self.activity.parameters valueForKey:MCT_ACTIVITY_RELATION_NAME];
    NSString *format;
    if (IS_ENTERPRISE_APP) {
        format = NSLocalizedString(@"%@ connected to %@", nil);
    } else {
        format = NSLocalizedString(@"%@ became friends with %@", nil);
    }
    self.descriptionLabel.text = [NSString stringWithFormat:format, friendName, relationName];
}

@end

#pragma mark -


@interface MCTServicePokedCell : MCTSimpleActivityCell
@end


@implementation MCTServicePokedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *serviceName = [self.activity.parameters valueForKey:MCT_ACTIVITY_FRIEND_NAME];
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Poked %@", nil), serviceName];
}

@end

#pragma mark -

@interface MCTMessageReceivedCell : MCTSimpleActivityCell
@end


@implementation MCTMessageReceivedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    NSString *from = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_FROM];
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Message received from %@: %@", nil),
                                  from, content];
}

@end

#pragma mark -

@interface MCTMessageSentCell : MCTSimpleActivityCell
@end


@implementation MCTMessageSentCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    NSString *to = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_TO];
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Message sent to %@: %@", nil),
                                  to, content];
}

@end

#pragma mark -

@interface MCTReplyReceivedCell : MCTTripleLabelActivityCell
@end


@implementation MCTReplyReceivedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *from = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_FROM];
    self.headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Reply received from %@:", nil), from];

    NSString *pContent = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_PARENT_CONTENT];
    self.upperLabel.text = [NSString stringWithFormat:@"> %@", pContent];

    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    self.lowerLabel.text = [NSString stringWithFormat:@">> %@", content];
}

@end


#pragma mark -

@interface MCTReplySentCell : MCTTripleLabelActivityCell
@end


@implementation MCTReplySentCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *to = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_TO];
    self.headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Reply sent to %@:", nil), to];

    NSString *pContent = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_PARENT_CONTENT];
    self.upperLabel.text = [NSString stringWithFormat:@"> %@", pContent];

    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    self.lowerLabel.text = [NSString stringWithFormat:@">> %@", content];
}

@end

#pragma mark -

@interface MCTMessageDismissedCell : MCTSimpleActivityCell
@end


@implementation MCTMessageDismissedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];
    NSString *from = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_FROM];
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Message acknowledged by %@: %@", nil),
                                  from, content];
}

@end

#pragma mark -

@interface MCTMessageLockedCell : MCTSimpleActivityCell
@end


@implementation MCTMessageLockedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *from = [NSString stringWithFormat:NSLocalizedString(@"Message locked by %@", nil),
                      [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_FROM]];
    NSString *choice = @"";
    if ([self.activity.parameters containsKey:MCT_ACTIVITY_MESSAGE_QRBUTTON]) {
        choice = [NSString stringWithFormat:[NSString stringWithFormat:@" %@", NSLocalizedString(@"with choice '%@'", nil)],
                  [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_QRBUTTON]];
    }
    NSString *content = [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT];

    self.descriptionLabel.text = [NSString stringWithFormat:@"%@%@: %@", from, choice, content];
}

@end

#pragma mark -

@interface MCTQuickReplySentCell : MCTTripleLabelActivityCell
@end


@implementation MCTQuickReplySentCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    self.headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Quick reply sent to %@", nil),
                             [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_TO]];
    self.upperLabel.text = [NSString stringWithFormat:@"> %@",
                            [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT]];
    self.lowerLabel.text = [NSString stringWithFormat:@">> %@",
                            [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_QRBUTTON]];
}

@end

#pragma mark -

@interface MCTQuickReplyReceivedCell : MCTTripleLabelActivityCell
@end


@implementation MCTQuickReplyReceivedCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    self.headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Quick reply received from %@", nil),
                             [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_FROM]];
    self.upperLabel.text = [NSString stringWithFormat:@"> %@",
                            [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_CONTENT]];
    self.lowerLabel.text = [NSString stringWithFormat:@">> %@",
                            [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_QRBUTTON]];
}

@end

#pragma mark -

@interface MCTQuickReplyUndoneCell : MCTSimpleActivityCell
@end


@implementation MCTQuickReplyUndoneCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Message locked before quick reply reached the server\n>> Final choice: %@", nil),
                                  [self.activity.parameters stringForKey:MCT_ACTIVITY_MESSAGE_QRBUTTON]];
}

@end

#pragma mark -

@interface MCTActivityLogCell : MCTSimpleActivityCell
@end


@implementation MCTActivityLogCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    self.descriptionLabel.text = [self.activity.parameters stringForKey:MCT_ACTIVITY_LOG_LINE];
}

@end

#pragma mark -

@interface MCTLocationCell : MCTSimpleActivityCell
@end


@implementation MCTLocationCell

- (void)setActivity:(MCTActivity *)newActivity
{
    [super setActivity:newActivity];
    if (newActivity == nil)
        return;

    NSString *friend = [self.activity.parameters objectForKey:MCT_ACTIVITY_FRIEND_NAME];
    self.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"I posted my location to %@", nil), friend];
}

@end

#pragma mark -


@implementation MCTActivityCellFactory

+ (MCTActivityCell *)tableView:(UITableView *)tableView cellForActivity:(MCTActivity *)activity
{
    T_UI();
    NSString *ident = [NSString stringWithFormat:@"act-%lld", activity.type];

    MCTActivityCell *cell = (MCTActivityCell *) [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        switch (activity.type) {
            case MCTActivityFriendAdded:
                cell = [[MCTFriendAddedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityFriendRemoved:
                cell = [[MCTFriendRemovedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityFriendUpdated:
                cell = [[MCTFriendUpdatedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityFriendBecameFriend:
                cell = [[MCTFriendBecameFriendCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityServicePoked:
                cell = [[MCTServicePokedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageReceived:
                cell = [[MCTMessageReceivedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageSent:
                cell = [[MCTMessageSentCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageReplyReceived:
                cell = [[MCTReplyReceivedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageReplySent:
                cell = [[MCTReplySentCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageDismissedByMe:
            case MCTActivityMessageDismissedByOther:
                cell = [[MCTMessageDismissedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityMessageLockedByMe:
            case MCTActivityMessageLockedByOther:
                cell = [[MCTMessageLockedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityQuickReplyReceivedForMe:
            case MCTActivityQuickReplyReceivedForOther:
                cell = [[MCTQuickReplyReceivedCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityQuickReplySentForMe:
            case MCTActivityQuickReplySentForOther:
                cell = [[MCTQuickReplySentCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityQuickReplyUndone:
                cell = [[MCTQuickReplyUndoneCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityLogDebug:
            case MCTActivityLogError:
            case MCTActivityLogFatal:
            case MCTActivityLogInfo:
            case MCTActivityLogWarning:
                cell = [[MCTActivityLogCell alloc] initWithReuseIdentifier:ident];
                break;
            case MCTActivityLocationSent:
                cell = [[MCTLocationCell alloc] initWithReuseIdentifier:ident];
                break;
            default:
                cell = [[MCTActivityCell alloc] initWithReuseIdentifier:ident];
                break;
        }
    }
    cell.activity = activity;

    return cell;
}

+ (UIImage *)iconImageForActivity:(MCTActivity *)activity
{
    T_UI();
    UIImage *icon;
    switch (activity.type) {
        case MCTActivityLocationSent:
        case MCTActivityMessageReceived:
        case MCTActivityMessageSent:
        case MCTActivityMessageReplyReceived:
        case MCTActivityMessageReplySent:
        case MCTActivityQuickReplyReceivedForMe:
        case MCTActivityQuickReplyReceivedForOther:
        case MCTActivityQuickReplySentForMe:
        case MCTActivityQuickReplySentForOther:
        case MCTActivityQuickReplyUndone:
        case MCTActivityMessageDismissedByMe:
        case MCTActivityMessageDismissedByOther:
        case MCTActivityMessageLockedByMe:
        case MCTActivityMessageLockedByOther: {
            MCTFriendsPlugin *plugin = (MCTFriendsPlugin *)[MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];
            icon = [plugin friendAvatarImageByEmail:activity.friendReference];
            break;
        }
        case MCTActivityServicePoked:
        case MCTActivityFriendAdded:
        case MCTActivityFriendUpdated:
        case MCTActivityFriendBecameFriend:
        case MCTActivityFriendRemoved: {
            MCTFriendsPlugin *plugin = (MCTFriendsPlugin *)[MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];
            icon = [plugin friendAvatarImageByEmail:activity.reference];
            break;
        }
        case MCTActivityLogWarning:
        case MCTActivityLogError:
        case MCTActivityLogFatal:
            icon = [UIImage imageNamed:MCT_ACTIVITY_ICON_ERROR];
            break;
        case MCTActivityLogDebug:
        case MCTActivityLogInfo:
            icon = [UIImage imageNamed:MCT_ACTIVITY_ICON_INFO];
            break;
        default:
            ERROR(@"Unknown ActivityType %d", activity.type);
            icon = [UIImage imageNamed:MCT_UNKNOWN_AVATAR];
            break;
    }
    return icon;
}

+ (UIImage *)iconOverlayForActivity:(MCTActivity *)activity
{
    T_UI();
    NSString *iconName = nil;
    switch (activity.type) {
        case MCTActivityLocationSent:
            iconName = MCT_ACTIVITY_ICON_LOCATION_SENT;
            break;
        case MCTActivityMessageReceived:
            iconName = MCT_ACTIVITY_ICON_MSG_RECEIVED;
            break;
        case MCTActivityMessageSent:
            iconName = MCT_ACTIVITY_ICON_MSG_SENT;
            break;
        case MCTActivityMessageReplyReceived:
            iconName = MCT_ACTIVITY_ICON_MSG_REPLY_RECEIVED;
            break;
        case MCTActivityMessageReplySent:
            iconName = MCT_ACTIVITY_ICON_MSG_REPLY_SENT;
            break;
        case MCTActivityQuickReplyReceivedForMe:
        case MCTActivityQuickReplyReceivedForOther:
            iconName = MCT_ACTIVITY_ICON_QUICKREPLY_RECEIVED;
            break;
        case MCTActivityQuickReplySentForMe:
        case MCTActivityQuickReplySentForOther:
            iconName = MCT_ACTIVITY_ICON_QUICKREPLY_SENT;
            break;
        case MCTActivityQuickReplyUndone:
            iconName = MCT_ACTIVITY_ICON_ERROR;
            break;
        case MCTActivityMessageDismissedByMe:
            iconName = MCT_ACTIVITY_ICON_MSG_DISMISSED_BY_ME;
            break;
        case MCTActivityMessageDismissedByOther:
            iconName = MCT_ACTIVITY_ICON_MSG_DISMISSED_BY_OTHER;
            break;
        case MCTActivityMessageLockedByMe:
            iconName = MCT_ACTIVITY_ICON_MSG_LOCKED_BY_ME;
            break;
        case MCTActivityMessageLockedByOther:
            iconName = MCT_ACTIVITY_ICON_MSG_LOCKED_BY_OTHER;
            break;
        case MCTActivityFriendAdded:
            iconName = MCT_ACTIVITY_ICON_FRIEND_ADDED;
            break;
        case MCTActivityFriendUpdated:
            iconName = MCT_ACTIVITY_ICON_FRIEND_UPDATED;
            break;
        case MCTActivityFriendBecameFriend:
            iconName = MCT_ACTIVITY_ICON_FRIEND_BECAME_FRIEND;
            break;
        case MCTActivityFriendRemoved:
            iconName = MCT_ACTIVITY_ICON_FRIEND_REMOVED;
            break;
        case MCTActivityServicePoked:
            iconName = MCT_ACTIVITY_ICON_INFO;
            break;
        case MCTActivityLogDebug:
        case MCTActivityLogInfo:
        case MCTActivityLogError:
        case MCTActivityLogFatal:
        case MCTActivityLogWarning:
            break;
        default:
            break;
    }
    return (iconName == nil) ? nil : [UIImage imageNamed:iconName];
}


+ (NSString *)friendDisplayNameForActivity:(MCTActivity *)activity
{
    T_UI();
    NSString *displayName;
    switch (activity.type) {
        case MCTActivityFriendAdded:
        case MCTActivityFriendUpdated:
        case MCTActivityFriendRemoved: {
            NSString *friendName = [activity.parameters valueForKey:@"name"];
            if (friendName == nil) {
                MCTFriendsPlugin *plugin = (MCTFriendsPlugin *)[MCTComponentFramework pluginForClass:[MCTFriendsPlugin class]];
                displayName = [plugin friendDisplayNameByEmail:activity.reference];
            } else {
                displayName = friendName;
            }
            break;
        }
        default:
            ERROR(@"Unknown ActivityType %d", activity.type);
            displayName = nil;
            break;
    }
    return displayName;
}

@end