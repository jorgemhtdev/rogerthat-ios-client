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

#import "NSData+Base64.h"

#import "MCTComponentFramework.h"
#import "MCTFlowLayout.h"
#import "MCTHumanMessageCell.h"
#import "MCTTransferObjects.h"
#import "MCTMessageHelper.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "TTButton.h"
#import "TTFlowLayout.h"

#define H_SPACING 5
#define V_SPACING 5
#define BTNVIEW_V_MARGIN 5
#define TXT_PADDING 8

#define AVA_W 40
#define BTN_W 142
#define BUBBLE_POINT_W 8
#define MS_SPACING 1
#define MS_W 40

#define SENDERLBL_FONT_SIZE [UIFont smallSystemFontSize]
#define MSGTXT_FONT_SIZE [UIFont systemFontSize]
#define BTN_FONT_SIZE [UIFont systemFontSize]


@interface MCTHumanMessageCell ()

- (void)createBtnView;

+ (BOOL)shouldShowDismissButtonForMessage:(MCTMessage *)msg;
+ (CGFloat)heightOfSenderLblWithMessage:(MCTMessage *)msg;
+ (CGSize)sizeOfBubbleWithMessage:(MCTMessage *)msg;
+ (CGSize)sizeOfMsgTxtWithMessage:(MCTMessage *)msg;
+ (CGSize)sizeOfMembersWithMessage:(MCTMessage *)msg andButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn;
+ (CGSize)sizeOfBtnViewWithMessage:(MCTMessage *)msg;

@end


@implementation MCTHumanMessageCell


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.bubble = [[TTView alloc] init];
        self.bubble.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bubble];

        self.msgTxt = [[UITextView alloc] init];
        self.msgTxt.backgroundColor = [UIColor clearColor];
        self.msgTxt.editable = NO;
        self.msgTxt.font = [UIFont systemFontOfSize:MSGTXT_FONT_SIZE];
        self.msgTxt.scrollEnabled = NO;
        self.msgTxt.textColor = [UIColor blackColor];
        [self.bubble addSubview:self.msgTxt];

        self.senderLbl = [[UILabel alloc] init];
        self.senderLbl.font = [UIFont systemFontOfSize:SENDERLBL_FONT_SIZE];
        self.senderLbl.lineBreakMode = NSLineBreakByTruncatingHead;
        self.senderLbl.textColor = [UIColor lightGrayColor];
        [self.bubble addSubview:self.senderLbl];

        self.lockView = [[UIImageView alloc] init];
        [self.bubble addSubview:self.lockView];

        TTFlowLayout *flowLayout = [[TTFlowLayout alloc] init];
        flowLayout.padding = 0;
        flowLayout.spacing = H_SPACING;

        self.attachmentsView = [[TTView alloc] init];
        self.attachmentsView.backgroundColor = [UIColor clearColor];
        self.attachmentsView.layout = flowLayout;
        [self.bubble addSubview:self.attachmentsView];

        self.btnView = [[TTView alloc] init];
        self.btnView.backgroundColor = [UIColor clearColor];
        self.btnView.layout = flowLayout;
        [self addSubview:self.btnView];

        UIControl *uiCtrl = [[UIControl alloc] init];
        uiCtrl.exclusiveTouch = YES;
        uiCtrl.tag = -1;
        [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:uiCtrl];

        self.avaView = [[UIImageView alloc] init];
        [uiCtrl addSubview:self.avaView];
        [MCTUIUtils addRoundedBorderToView:self.avaView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        tap.numberOfTapsRequired = 2;
        [self.msgTxt addGestureRecognizer:tap];
    }
    return self;
}

- (void)createBtnView
{
    T_UI();
    for (UIView *subview in self.btnView.subviews)
        [subview removeFromSuperview];

    NSMutableArray *btns = [[NSMutableArray alloc] init];
    if (IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat) && !IS_FLAG_SET(self.message.flags, MCTMessageFlagAllowChatButtons)) {
    } else {
        btns = [NSMutableArray arrayWithArray:self.message.buttons];
    }

    if ([MCTHumanMessageCell shouldShowDismissButtonForMessage:self.message]) {
        MCT_com_mobicage_to_messaging_ButtonTO *rtBtn = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
        rtBtn.caption = NSLocalizedString(@"Roger that", nil);
        [btns addObject:rtBtn];
    }

    for (MCT_com_mobicage_to_messaging_ButtonTO *btn in btns) {
        TTButton *ttBtn = [TTButton buttonWithStyle:btn.idX ? MCT_STYLE_MAGIC_SMALL_BUTTON : MCT_STYLE_DISMISS_SMALL_BUTTON
                                              title:btn.caption];
        ttBtn.tag = [btns indexOfObject:btn];
        [ttBtn addTarget:self
                  action:btn.idX ? @selector(onMagicButtonClicked:) : @selector(onDismissButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
        if ([MCTMessageHelper shouldDisableButton:btn forMessage:self.message withSenderIsService:NO]) {
            ttBtn.enabled = NO;
        }

        MCTFlowLayout *msLayout = [[MCTFlowLayout alloc] init];
        msLayout.leftAlignment = self.iAmSender;
        msLayout.padding = 0;
        msLayout.spacing = MS_SPACING;
        TTView *msView = [[TTView alloc] init];
        msView.backgroundColor = [UIColor clearColor];
        msView.layout = msLayout;

        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in [self.message membersWithAnswer:btn.idX]) {
            if (!btn.idX && [member.member isEqualToString:self.message.sender]) {
                // Do not show sender avatar on Rogerthat button
                continue;
            }
            UIImage *img = [[MCTComponentFramework friendsPlugin] userAvatarImageByEmail:member.member downloadIfNotFound:YES];
            UIImageView *avaView = [[UIImageView alloc] initWithImage:img];
            [MCTUIUtils addRoundedBorderToView:avaView];
            avaView.frame = CGRectMake(0, 0, MS_W, MS_W);

            UIControl *uiCtrl = [[UIControl alloc] initWithFrame:avaView.frame];
            uiCtrl.tag = [self.message.members indexOfObject:member];
            [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];
            [uiCtrl addSubview:avaView];
            [msView addSubview:uiCtrl];
        }

        if (self.iAmSender) {
            [self.btnView addSubview:ttBtn];
            [self.btnView addSubview:msView];
        } else {
            [self.btnView addSubview:msView];
            [self.btnView addSubview:ttBtn];
        }
    }
}

- (void)createAttachmentsView
{
    T_UI();
    for (UIView *v in self.attachmentsView.subviews) {
        [v removeFromSuperview];
    }

    if ([self.message.attachments count]) {
        CGFloat w = [MCTHumanMessageCell widthOfAttachmentImageView];
        CGRect frame = CGRectMake(0, 0, w, w);
        for (int i = 0; i < [self.message.attachments count]; i++) {
            MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.message.attachments objectAtIndex:i];

            UIControl *attachmentControl = [[UIControl alloc] initWithFrame:frame];

            attachmentControl.tag = i;
            [attachmentControl addTarget:self
                                  action:@selector(onAttachmentClicked:)
                        forControlEvents:UIControlEventTouchUpInside];
            [self.attachmentsView addSubview:attachmentControl];

            MCTMessageAttachmentPreviewItem *previewItem = [self.message attachmentPreviewItemAtIndex:i];
            if ([[NSFileManager defaultManager] fileExistsAtPath:previewItem.itemPath]) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.image = [MCTHumanMessageCell imageForAttachment:attachment
                                                          withPreviewItem:previewItem];

                // Change the size of the imageView to be conform with the ratio of the image size
                [MCTUIUtils resizeImageView:imageView withAllowShrinking:YES];
                [attachmentControl addSubview:imageView];

                attachmentControl.width = imageView.width;
                attachmentControl.height = imageView.height;

                BOOL isImage = [attachment.content_type hasPrefix:@"image/"];
                BOOL isVideo = !isImage && [attachment.content_type hasPrefix:@"video/"];

                if (isImage || (isVideo && [[NSFileManager defaultManager]
                                            fileExistsAtPath:[previewItem.itemPath stringByAppendingString:@".thumb"]])) {

                    [MCTUIUtils addRoundedBorderToView:attachmentControl
                                       withBorderColor:[UIColor lightGrayColor]
                                       andCornerRadius:5];
                    if (isVideo) {
                        // Add video-overlay
                        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
                        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
                        overlayImageView.image = [UIImage imageNamed:@"video-overlay"];
                        [attachmentControl addSubview:overlayImageView];
                    }
                }
            } else {
                [MCTUIUtils addRoundedBorderToView:attachmentControl
                                   withBorderColor:[UIColor lightGrayColor]
                                   andCornerRadius:5];
                [[MCTComponentFramework brandingMgr] queueAttachment:attachment.download_url
                                                          forMessage:self.message.key
                                                       withThreadKey:self.message.threadKey
                                                         contentType:attachment.content_type];

                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                spinner.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
                [spinner startAnimating];
                [attachmentControl addSubview:spinner];
            }
        }
    }
}

- (void)setMessage:(MCTMessage *)msg
{
    T_UI();
    if (_message == msg)
        return;

    _message = msg;

    if (msg == nil)
        return;

    MCTFriendsPlugin *friendsPlugin = [MCTComponentFramework friendsPlugin];
    self.iAmSender = [friendsPlugin isMyEmail:msg.sender];

    self.avaView.image = [friendsPlugin userAvatarImageByEmail:msg.sender downloadIfNotFound:YES];

    if ([MCTMessageHelper canLockForMessage:msg]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(onLongPress:)];
        [self.avaView.superview addGestureRecognizer:longPress];
    }

    NSString *name = self.iAmSender ? NSLocalizedString(@"__me_as_sender", nil)
                                    : [friendsPlugin friendDisplayNameByEmail:msg.sender];
    self.senderLbl.text = [NSString stringWithFormat:@"%@ @ %@", name, [MCTUtils timestampShortNotation:msg.timestamp andShowMinutes:NO]];

    self.msgTxt.text = msg.message;
    self.msgTxt.textAlignment = self.senderLbl.textAlignment;

    if ([[MCTComponentFramework messagesPlugin] isTmpKey:msg.key]) {
        self.spinner = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.spinner startAnimating];
        [self.bubble addSubview:self.spinner];
    } else {
        [self.spinner stopAnimating];
        [self.spinner removeFromSuperview];
        MCT_RELEASE(self.spinner);
    }

    [self createBtnView];
    [self createAttachmentsView];
}

- (void)onAttachmentClicked:(UIControl *)sender
{
    T_UI();
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_ATTACHMENT_CLICKED];
    [intent setString:self.message.threadKey forKey:@"thread_key"];
    [intent setString:self.message.key forKey:@"message_key"];
    [intent setLong:sender.tag forKey:@"index"];
    [[MCTComponentFramework intentFramework] broadcastIntent:intent];
}

- (CGFloat)pointLocationForBubbleWithFrameHeight:(CGFloat)h andRadius:(CGFloat)r
{
    // Calculating pointLocation of speechBubble (reverse engineered from TTSpeechBubbleShape.m)
    T_UI();
    CGFloat pY = AVA_W / 2; // y position of the speech bubble point
    CGFloat x;              // the magic var, based on |pY|
    CGFloat a;              // angle

    if (self.iAmSender) {
        x = pY;
        a = 135;
    } else {
        x = h - pY;
        a = -45;
    }

    CGFloat pL = a + 90 * (x - r - BUBBLE_POINT_W/2) / (h - 2*r - BUBBLE_POINT_W);
    return pL;
}

- (void)layoutSubviews
{
    T_UI();
    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width;
    CGFloat avX;
    CGFloat bubX;

    if (self.iAmSender) {
        bubX = H_SPACING;
        avX = w - H_SPACING - AVA_W;
    } else {
        avX = H_SPACING;
        bubX = avX + AVA_W + H_SPACING;
    }

    CGRect avFrame = CGRectMake(avX, V_SPACING, AVA_W, AVA_W);
    self.avaView.superview.frame = avFrame;
    CGRect imgFrame = avFrame;
    imgFrame.origin = CGPointZero;
    self.avaView.frame = imgFrame;

    CGSize bubSize = [MCTHumanMessageCell sizeOfBubbleWithMessage:self.message];
    CGRect bubFrame = CGRectMake(bubX, avFrame.origin.y, bubSize.width, bubSize.height);
    self.bubble.frame = bubFrame;

    CGFloat r = 5;
    CGFloat pL = [self pointLocationForBubbleWithFrameHeight:bubFrame.size.height andRadius:r];
    UIColor *bubbleBorderColor = RGBCOLOR(158, 163, 172);
    if (self.message.priority == MCTMessagePriorityHigh) {
        bubbleBorderColor = [UIColor MCPriorityHighBackgroundColor];
    } else if (self.message.priority == MCTMessagePriorityUrgent || self.message.priority == MCTMessagePriorityUrgentWithAlarm) {
        bubbleBorderColor = [UIColor MCPriorityUrgentBackgroundColor];
    }
    self.bubble.style = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:r
                                                                            pointLocation:pL
                                                                               pointAngle:self.iAmSender ? 180 : 0
                                                                                pointSize:CGSizeMake(BUBBLE_POINT_W,
                                                                                                     2*BUBBLE_POINT_W)]
                                                next:
                         [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
                          [TTSolidBorderStyle styleWithColor:bubbleBorderColor width:1 next:nil]]];

    BOOL isLocked = [self.message isLocked];
    BOOL isRinging = !isLocked && self.message.alert_flags >= MCTAlertFlagInterval5 && self.message.threadNeedsMyAnswer;

    if (isLocked) {
        self.lockView.image = [UIImage imageNamed:@"lock-closed.png"];
    } else if (isRinging) {
        self.lockView.image = [UIImage imageNamed:@"status-ringing.png"];
    } else {
        self.lockView.image = nil;
    }

    CGFloat lvH = self.lockView.image ? 21 : 0;
    CGFloat lvW = 12 * lvH / 19;
    CGFloat lvX = bubFrame.size.width - H_SPACING - lvW - (self.iAmSender ? BUBBLE_POINT_W : 0);
    CGRect lvFrame = CGRectMake(lvX, 0, lvW, lvH);
    self.lockView.frame = lvFrame;

    if (self.spinner) {
        CGFloat spX = bubFrame.size.width - 20 - (self.iAmSender ? BUBBLE_POINT_W : 0);
        CGRect spFrame = CGRectMake(spX, H_SPACING, 15, 15);
        self.spinner.frame = spFrame;
    }

    CGRect slFrame = CGRectZero;
    slFrame.origin.x = TXT_PADDING + (self.iAmSender ? 0 : BUBBLE_POINT_W);
    slFrame.origin.y = 3;
    slFrame.size.width = lvX - 2 * TXT_PADDING + H_SPACING - (self.iAmSender ? 0 : BUBBLE_POINT_W);
    slFrame.size.height = [MCTHumanMessageCell heightOfSenderLblWithMessage:self.message];
    self.senderLbl.frame = slFrame;

    CGRect mtFrame = CGRectZero;
    mtFrame.origin.x = 4 + (self.iAmSender ? 0 : BUBBLE_POINT_W);
    mtFrame.origin.y = CGRectGetMaxY(slFrame) - TXT_PADDING;
    mtFrame.size.width = bubFrame.size.width - BUBBLE_POINT_W - 8;
    mtFrame.size.height = [MCTHumanMessageCell sizeOfMsgTxtWithMessage:self.message].height + 2 * TXT_PADDING;
    self.msgTxt.frame = mtFrame;

    if ([self.message.attachments count]) {
        self.attachmentsView.frame = CGRectMake(self.msgTxt.left + 4,
                                                self.senderLbl.bottom + H_SPACING,
                                                self.msgTxt.width,
                                                [MCTHumanMessageCell heightOfAttachmentsWithMessage:self.message]);
        self.msgTxt.top += self.attachmentsView.height + H_SPACING;
    } else {
        self.attachmentsView.frame = CGRectZero;
    }

    CGSize bvSize = [MCTHumanMessageCell sizeOfBtnViewWithMessage:self.message];
    CGRect bvFrame = CGRectMake(H_SPACING, CGRectGetMaxY(bubFrame) + BTNVIEW_V_MARGIN, bvSize.width, bvSize.height);
    self.btnView.frame = bvFrame;

    for (UIView *subview in self.btnView.subviews) {
        int i = floor([self.btnView.subviews indexOfObject:subview] / 2);
        MCT_com_mobicage_to_messaging_ButtonTO *btn;
        if (i == [self.message.buttons count]) {
            btn = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
            btn.caption = NSLocalizedString(@"Roger that", nil);
        } else {
            btn = [self.message.buttons objectAtIndex:i];
        }

        CGSize subSize = CGSizeZero;
        if ([subview isKindOfClass:[TTButton class]]) {
            subSize = [MCTHumanMessageCell sizeOfTTBtnWithButton:btn];
        } else {
            subSize = [MCTHumanMessageCell sizeOfMembersWithMessage:self.message andButton:btn];
        }
        CGRect f = subview.frame;
        f.size = subSize;
        subview.frame = f;
    }
}

- (IBAction)onDismissButtonClicked:(UIControl *)sender
{
    T_UI();
    [MCTMessageHelper onDismissButtonClickedForMessage:self.message];
}

- (IBAction)onMagicButtonClicked:(UIControl *)sender
{
    T_UI();
    [MCTMessageHelper onMagicButtonClicked:[self.message.buttons objectAtIndex:sender.tag] forMessage:self.message forVC:self.viewController];
    if (!IS_FLAG_SET(self.message.flags, MCTMessageFlagDynamicChat)) {
        [MCTMessageHelper onDismissThreadClickedForMessage:self.message];
    }
}

- (void)onParticipantTapped:(id)sender
{
    T_UI();
    UIControl *uiCtrl = sender;
    NSString *email = uiCtrl.tag == -1 ? self.message.sender : [[self.message.members objectAtIndex:uiCtrl.tag] member];
    [MCTMessageHelper onParticipantClicked:email inNavigationController:self.viewController.navigationController];
}

- (void)onDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    T_UI();
    [MCTMessageHelper onReplyClickedForMessage:self.message inNavigationController:self.viewController.navigationController];
}

- (void)onLongPress:(id)sender
{
    T_UI();
    if (!self.cancelLock) {
        [MCTMessageHelper onLockClickedForMessage:self.message];
        self.cancelLock = YES;
    }
}

#pragma mark -
#pragma mark Size Calculation

+ (UIImage *)imageForAttachment:(MCT_com_mobicage_to_messaging_AttachmentTO *)attachment
                withPreviewItem:(MCTMessageAttachmentPreviewItem *)previewItem
{
    T_DONTCARE();
    if ([MSG_ATTACHMENT_CONTENT_TYPE_PDF isEqualToString:attachment.content_type]) {
        return [UIImage imageNamed:@"attachment_pdf.png"];
    } else if ([attachment.content_type hasPrefix:@"image/"]) {
        NSString *thumbnailPath = [previewItem.itemPath stringByAppendingString:@".thumb"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]) {
            return [UIImage imageWithData:[NSData dataWithContentsOfFile:thumbnailPath]];
        } else {
            return [UIImage imageWithData:[NSData dataWithContentsOfFile:previewItem.itemPath]];
        }
    } else if ([attachment.content_type hasPrefix:@"video/"]) {
        NSString *thumbnailPath = [previewItem.itemPath stringByAppendingString:@".thumb"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]) {
            return [UIImage imageWithData:[NSData dataWithContentsOfFile:thumbnailPath]];
        } else {
            return [UIImage imageNamed:@"attachment_video.png"];
        }
    } else {
        return [UIImage imageNamed:@"attachment_unknown.png"];
    }
}

+ (BOOL)shouldShowDismissButtonForMessage:(MCTMessage *)msg
{
    T_UI();
    return NO;
}

+ (CGFloat)heightOfSenderLblWithMessage:(MCTMessage *)msg
{
    T_UI();
    return SENDERLBL_FONT_SIZE + 4;
}

+ (CGFloat)widthOfAttachmentImageView
{
    CGFloat bubW = [[UIScreen mainScreen] applicationFrame].size.width - 3 * H_SPACING - AVA_W;
    return  bubW * 2 / 3;
}

+ (CGFloat)heightOfAttachmentsWithMessage:(MCTMessage *)msg
{
    T_UI();
    if ([msg.attachments count]) {
        CGFloat w = [MCTHumanMessageCell widthOfAttachmentImageView];
        CGFloat h = 0;

        for (MCT_com_mobicage_to_messaging_AttachmentTO *attachment in msg.attachments) {
            MCTMessageAttachmentPreviewItem *previewItem = [msg attachmentPreviewItemWithAttachment:attachment];
            if ([[NSFileManager defaultManager] fileExistsAtPath:previewItem.itemPath]) {
                UIImage *image = [MCTHumanMessageCell imageForAttachment:attachment
                                                         withPreviewItem:previewItem];
                if (image.size.height >= image.size.width) {
                    h += fmin(w, image.size.height);
                } else if (image.size.width < w) {
                    h += image.size.height;
                } else {
                    h += w * image.size.height / image.size.width;
                }
            } else {
                h += w;
            }
        }

        return h + [msg.attachments count] * H_SPACING;
    } else {
        return 0;
    }
}

+ (CGSize)sizeOfBubbleWithMessage:(MCTMessage *)msg
{
    T_UI();
    CGFloat slH = [MCTHumanMessageCell heightOfSenderLblWithMessage:msg];
    CGSize mtSize = [MCTHumanMessageCell sizeOfMsgTxtWithMessage:msg];
    CGFloat atH = [MCTHumanMessageCell heightOfAttachmentsWithMessage:msg];

    CGSize bubSize = CGSizeZero;
    bubSize.width = [[UIScreen mainScreen] applicationFrame].size.width - 3 * H_SPACING - AVA_W;
    bubSize.height = fmax(mtSize.height + 2*TXT_PADDING + slH + atH, AVA_W);
    return bubSize;
}

+ (CGSize)sizeOfMsgTxtWithMessage:(MCTMessage *)msg
{
    T_UI();
    CGFloat bubW = [[UIScreen mainScreen] applicationFrame].size.width - 3 * H_SPACING - AVA_W;
    CGFloat txtW = bubW - BUBBLE_POINT_W - 2 - 2*TXT_PADDING;

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont systemFontOfSize:MSGTXT_FONT_SIZE];
    gettingSizeLabel.text = msg.message;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    return [gettingSizeLabel sizeThatFits:CGSizeMake(txtW, 1000)];
}

+ (CGSize)sizeOfMembersWithMessage:(MCTMessage *)msg andButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
{
    T_UI();
    CGFloat w = [[UIScreen mainScreen] applicationFrame].size.width - 3 * H_SPACING - BTN_W;

    // Calculate amount of avatars fitting on 1 row
    int maxCols = 1;
    while (maxCols * MS_W + (maxCols - 1) * MS_SPACING <= w)
        maxCols++;
    maxCols--;

    NSInteger answers = [[msg membersWithAnswer:btn.idX] count];
    NSInteger rows = ceil((double)answers / MAX(1, maxCols));

    CGFloat h = rows * MS_W + (rows - 1) * MS_SPACING;

    return CGSizeMake(w, h);
}

+ (CGSize)sizeOfTTBtnWithButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
{
    T_UI();

    TTButton *ttBtn = [TTButton buttonWithStyle:MCT_STYLE_MAGIC_SMALL_BUTTON title:btn.caption];
    CGSize size = [MCTUIUtils sizeForTTButton:ttBtn constrainedToSize:CGSizeMake(BTN_W - 16, 126)];

    return CGSizeMake(BTN_W, MAX(MS_W, size.height));
}

+ (CGSize)sizeOfBtnViewWithMessage:(MCTMessage *)msg
{
    T_UI();
    NSMutableArray *btns = [[NSMutableArray alloc] init];
    if (IS_FLAG_SET(msg.flags, MCTMessageFlagDynamicChat) && !IS_FLAG_SET(msg.flags, MCTMessageFlagAllowChatButtons)) {
    } else {
        btns = [NSMutableArray arrayWithArray:msg.buttons];
    }
    if ([MCTHumanMessageCell shouldShowDismissButtonForMessage:msg]) {
        MCT_com_mobicage_to_messaging_ButtonTO *rtBtn = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
        rtBtn.caption = NSLocalizedString(@"Roger that", nil);
        [btns addObject:rtBtn];
    }

    CGFloat h = [btns count] ? (([btns count] - 1) * H_SPACING) : 0;
    for (MCT_com_mobicage_to_messaging_ButtonTO *btn in btns) {
        CGSize btnSize = [MCTHumanMessageCell sizeOfTTBtnWithButton:btn];
        CGSize membersSize = [MCTHumanMessageCell sizeOfMembersWithMessage:msg andButton:btn];
        h += MAX(btnSize.height, membersSize.height);
    }

    return CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width - 2 * H_SPACING, h);
}

+ (CGFloat)heightOfCellWithMessage:(MCTMessage *)msg
{
    T_UI();
    CGFloat bubbleHeight = [MCTHumanMessageCell sizeOfBubbleWithMessage:msg].height;
    CGFloat btnViewHeight = [MCTHumanMessageCell sizeOfBtnViewWithMessage:msg].height;

    CGFloat h = V_SPACING + bubbleHeight + V_SPACING;
    if (btnViewHeight)
        h += BTNVIEW_V_MARGIN + btnViewHeight;

    return h;
}

@end