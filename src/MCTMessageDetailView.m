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
#import "MCTFormView.h"
#import "MCTFriend.h"
#import "MCTFriendDetailOrInviteVC.h"
#import "MCTFriendsPlugin.h"
#import "MCTIntent.h"
#import "MCTMessage.h"
#import "MCTMessageDetailVC.h"
#import "MCTMessageDetailView.h"
#import "MCTMessageEnums.h"
#import "MCTMessagesPlugin.h"
#import "MCTMessageHelper.h"
#import "MCTOperation.h"
#import "MCTMessageScrollView.h"
#import "MCTMessageTextView.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"
#import "MCTServiceMenuItem.h"
#import "MCTFriendBroadcastInfo.h"
#import "MCTMenuItemView.h"

#import "UIImage+FontAwesome.h"
#import "TTButton.h"
#import "TTTextStyle.h"

#define MCT_TAG_MESSAGE_TEXT 1

#define MCT_ICON_MEMBER_STATUS_ONTHEWAY @"status-yellow.png"
#define MCT_ICON_MEMBER_STATUS_RECEIVED @"status-green.png"
#define MCT_ICON_MEMBER_STATUS_ACKED    @"status-blue.png"

static int MARGIN = 10;
static int BTN_AVA_WIDTH = 40;
static int BTN_AVA_MARGIN = 3;


@interface MCTMessageDetailView ()

@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) UIControl *contentView;
@property (nonatomic, strong) UIView *recipientsView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UIView *attachmentsView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIView *recipientSummaryView;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *senderImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) UIImageView *statusImageView;

@property (nonatomic, strong) MCTFriendsPlugin *friendsPlugin;
@property (nonatomic, strong) MCTMessagesPlugin *messagesPlugin;

@property (nonatomic) CGPoint contentOffset;

@property (nonatomic, strong) UIView *broadcastNotificationView;

@property (nonatomic) BOOL shouldShowBroadcastHint;

- (void)registerIntents;

- (UIFont *)titleFont;
- (UIFont *)contentFont;

- (void)createSpinner;
- (void)createSubviews;

- (UIView *)createSeperatorWithYPosition:(CGFloat)y andTitle:(NSString *)title;
- (UIView *)createMessageViewWithYPosition:(CGFloat)y;
- (UIView *)createButtonsViewWithYPosition:(CGFloat)y;
- (MCTFormView *)createFormViewWithYPosition:(CGFloat)y;
- (UIImageView *)createRecipientsStatusIconForMember:(MCT_com_mobicage_to_messaging_MemberStatusTO *)member
                                     withAvatarWidth:(CGFloat)width;
- (NSArray *)createRecipientsSummaryAvatars;
- (BOOL)iAmOnlyRecipient;
- (UIView *)createRecipientsSummaryViewWithYPosition:(CGFloat)y;
- (UIView *)createRecipientsViewWithYPosition:(CGFloat)y;

- (TTButton *)createTTButtonWithButtonTO:(MCT_com_mobicage_to_messaging_ButtonTO *)btn index:(NSInteger)index;
- (int)addAvatarsForButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
              toScrollView:(UIScrollView *)avaScrollView;
- (IBAction)onDismissButtonClicked:(UIButton *)btn;
- (IBAction)onMagicButtonClicked:(UIButton *)btn;

- (void)repositionView:(UIView *)view withOffset:(CGFloat)offset;
- (void)repositionWebView:(UIWebView *)webView;

@end

#pragma mark -

@implementation MCTMessageDetailView

- (void)dealloc
{
    T_UI();
    HERE();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];    
}

- (void)removeFromSuperview
{
    HERE();
    // This would be a good place to unregister intents an listeners
    [super removeFromSuperview];
}

#pragma mark -

- (MCTMessageDetailView *)initWithFrame:(CGRect)frame
                       inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
                     withBrandingResult:(MCTBrandingResult *)brandingResult
                             andIsRefresh:(BOOL)isRefresh
{
    T_UI();

    if (self = [super initWithFrame:frame]) {
        self.detailsExpanded = NO;
        self.brandingResult = brandingResult;
        self.messagesPlugin = [MCTComponentFramework messagesPlugin];
        self.friendsPlugin = [MCTComponentFramework friendsPlugin];
        self.viewController = vc;
        self.shouldShowBroadcastHint = !isRefresh;

        [self addTarget:self action:@selector(onBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self createSubviews];
        [self registerIntents];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }

    return self;
}

- (UIFont *)titleFont
{
    T_UI();
    return [UIFont systemFontOfSize:13];
}

- (UIFont *)contentFont
{
    T_UI();
    return [UIFont systemFontOfSize:17];
}

- (void)createSpinner
{
    self.spinnerView = [[UIView alloc] initWithFrame:self.frame];
    self.spinnerView.backgroundColor = self.backgroundColor;
    [self.scrollView addSubview:self.spinnerView];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    int sW = 40;
    CGRect sFrame = CGRectMake((self.frame.size.width - sW) / 2, sW, sW, sW);
    spinner.frame = sFrame;
    [self.spinnerView addSubview:spinner];

    NSString *text = NSLocalizedString(@"Loading message ...", nil);
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont systemFontOfSize:17];
    gettingSizeLabel.text = text;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByClipping;

    CGSize lSize = [gettingSizeLabel sizeThatFits:CGSizeMake(self.frame.size.width, 20)];

    int lX = (self.frame.size.width - lSize.width) / 2;
    int lY = sFrame.origin.y + sFrame.size.height + MARGIN;
    CGRect lFrame = CGRectMake(lX, lY, lSize.width, lSize.height);
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:lFrame];
    loadingLabel.text = text;
    loadingLabel.textColor = [UIColor blackColor];
    loadingLabel.backgroundColor = [UIColor clearColor];
    [self.spinnerView addSubview:loadingLabel];

    [spinner startAnimating];
}

- (void)createSubviews
{
    T_UI();
    CGRect svFrame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, self.height);
    MCTMessageScrollView *sv = [[MCTMessageScrollView alloc] initWithFrame:svFrame];
    sv.touchDelegate = self;
    self.scrollView = sv;

    self.headerView = [[UIView alloc] init];

    CGFloat siW = 50;

    CGRect siFrame = CGRectMake(MARGIN, MARGIN, siW, siW);
    self.senderImageView = [[UIImageView alloc] initWithFrame:siFrame];
    [MCTUIUtils addRoundedBorderToView:self.senderImageView];

    int liH = 40;
    int liW = liH*12/19;
    CGRect liFrame = CGRectMake(self.frame.size.width - 6 - liW, CGRectGetMaxY(siFrame) - liH, liW, liH);
    self.statusImageView = [[UIImageView alloc] initWithFrame:liFrame];
    [self.headerView addSubview:self.statusImageView];

    int tlX = CGRectGetMaxX(siFrame) + MARGIN;
    int tlW = liFrame.origin.x - tlX;

    CGRect tlFrame = CGRectMake(tlX, siFrame.origin.y, tlW, 21);
    self.timeLabel = [[UILabel alloc] initWithFrame:tlFrame];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [self titleFont];

    CGRect slFrame = CGRectMake(tlX, tlFrame.origin.y + 14, tlW, 36);
    self.senderLabel = [[UILabel alloc] initWithFrame:slFrame];
    self.senderLabel.backgroundColor = [UIColor clearColor];
    self.senderLabel.font = [self contentFont];
    self.senderLabel.adjustsFontSizeToFitWidth = YES;

    CGRect ctrlFrame = CGRectMake(0, 0, CGRectGetMinX(self.statusImageView.frame) - MARGIN, CGRectGetMaxY(self.senderLabel.frame));
    UIControl *uiCtrl = [[UIControl alloc] initWithFrame:ctrlFrame];
    uiCtrl.tag = -1;
    [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];

    [uiCtrl addSubview:self.senderImageView];
    [uiCtrl addSubview:self.timeLabel];
    [uiCtrl addSubview:self.senderLabel];
    [self.headerView addSubview:uiCtrl];

    self.headerView.frame = CGRectMake(0, 0, self.frame.size.width, CGRectGetMaxY(ctrlFrame));

    self.contentView = [[UIControl alloc] init];
    self.contentView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 0);
    [self.contentView addTarget:self action:@selector(onBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.headerView];

    [self addSubview:self.scrollView];
}

- (void)setMessage:(MCTMessage *)msg
{
    T_UI();
    if (msg == nil && self.spinnerView == nil)
        [self createSpinner];

    if (_message == msg)
        return;

    BOOL reloadMessage = (msg != nil && ![msg.key isEqualToString:self.message.key]);
    _message = msg;

    MCT_RELEASE(self.myAnswer);

    if (self.message) {
        if (self.spinnerView) {
            [self.spinnerView removeFromSuperview];
            MCT_RELEASE(self.spinnerView);
        }
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {
            if ([self.friendsPlugin isMyEmail:member.member]) {
                self.myAnswer = member.button_id;
                break;
            }
        }

        [self refreshViewWithIsOtherMessage:reloadMessage];
    } else {
        self.headerView.hidden = YES;

        [self.controlView removeFromSuperview];
        MCT_RELEASE(self.controlView);

        [self.recipientSummaryView removeFromSuperview];
        MCT_RELEASE(self.recipientSummaryView);

        [self.recipientsView removeFromSuperview];
        MCT_RELEASE(self.recipientsView);

        [self.messageView removeFromSuperview];
        MCT_RELEASE(self.messageView);
    }

}

- (void)refreshViewWithIsOtherMessage:(BOOL)isOther
{
    T_UI();
    CGFloat y = 0;

    if (self.brandingResult.color) {
        // Remove gradient layer
        for (CALayer *layer in [self.layer.sublayers reverseObjectEnumerator]) {
            if ([layer isKindOfClass:[CAGradientLayer class]])
                [layer removeFromSuperlayer];
        }
        self.backgroundColor = [UIColor colorWithString:self.brandingResult.color];
    } else {
        self.backgroundColor = [UIColor MCTMercuryColor];
    }

    if (!self.brandingResult || self.brandingResult.showHeader) {
        self.headerView.hidden = NO;

        self.senderImageView.image = [self.friendsPlugin userAvatarImageByEmail:self.message.sender];
        self.senderLabel.text = [self.friendsPlugin friendDisplayNameByEmail:self.message.sender];
        self.timeLabel.text = [MCTUtils timestampNotation:self.message.timestamp];

        if ([self.message isLocked]) {
            self.statusImageView.image = [UIImage imageNamed:@"lock-closed.png"];
        } else if (self.message.alert_flags >= MCTAlertFlagRing5 && ![self.messagesPlugin messageAckedByMe:self.message]) {
            self.statusImageView.image = [UIImage imageNamed:@"status-ringing.png"];
        } else {
            self.statusImageView.image = nil;
        }
        self.statusImageView.hidden = (self.statusImageView.image == nil);

        y += CGRectGetMaxY(self.headerView.frame) + MARGIN;
    } else {
        self.headerView.hidden = YES;
    }

    MCTColorScheme scheme = [self.viewController colorSchemeForBrandingResult:self.brandingResult];
    if (scheme == MCTColorSchemeLight) {
        self.senderLabel.textColor = [UIColor blackColor];
        self.timeLabel.textColor = [UIColor darkGrayColor];
    } else {
        self.senderLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textColor = [UIColor lightGrayColor];
    }

    [self.attachmentsView removeFromSuperview];
    [self.controlView removeFromSuperview];
    [self.recipientSummaryView removeFromSuperview];
    [self.recipientsView removeFromSuperview];
    [self.broadcastNotificationView removeFromSuperview];

    if (isOther || self.messageView == nil) {
        [self.messageView removeFromSuperview];
        self.messageView = [self createMessageViewWithYPosition:y];
        [self.contentView addSubview:self.messageView];
    }

    y = CGRectGetMaxY(self.messageView.frame);
    if (self.messageView.frame.size.height)
        y += MARGIN;

    if ([self.message.attachments count]) {
        self.attachmentsView = [self createAttachmentsViewWithYPosition:y];
        [self.contentView addSubview:self.attachmentsView];
        y = CGRectGetMaxY(self.attachmentsView.frame) + MARGIN;
    }

    if (self.message.form) {
        if (!isOther && self.controlView) {
            [((MCTFormView *) self.controlView) refreshView];
        } else {
            if (self.controlView) {
                [[NSNotificationCenter defaultCenter] removeObserver:((MCTFormView *) self.controlView).widgetView];
                MCT_RELEASE(self.controlView);
            }
            self.controlView = [self createFormViewWithYPosition:y];
        }
    } else {
        self.controlView = [self createButtonsViewWithYPosition:y];
    }

    [self.contentView addSubview:self.controlView];
    y = CGRectGetMaxY(self.controlView.frame) + MARGIN;

    if (!self.detailsExpanded) {
        self.recipientSummaryView = [self createRecipientsSummaryViewWithYPosition:y];
        if (self.recipientSummaryView != nil) {
            [self.contentView insertSubview:self.recipientSummaryView atIndex:0];
        }
    }

    UIView *bottomContentView = [self bottomContentView];

    CGRect cvFrame = self.contentView.frame;
    cvFrame.size.height = CGRectGetMaxY(bottomContentView.frame);
    if (!self.detailsExpanded)
        cvFrame.origin.y = 0;
    self.contentView.frame = cvFrame;

    if (self.detailsExpanded) {
        y = CGRectGetMaxY(self.contentView.frame) + MARGIN;
        self.recipientsView = [self createRecipientsViewWithYPosition:y];
        [self.scrollView addSubview:self.recipientsView];
    }

    self.broadcastNotificationView = [self createBroadcastNotificationView];
    if (self.broadcastNotificationView != nil) {
        [self addSubview:self.broadcastNotificationView];

        CGRect svFrame = self.scrollView.frame;
        svFrame.size.height = self.height - self.broadcastNotificationView.height;
        self.scrollView.frame = svFrame;
        if (self.shouldShowBroadcastHint) {
            self.shouldShowBroadcastHint = NO;
            MCTFriend *service = [[[MCTComponentFramework friendsPlugin] store] friendByEmail:self.message.sender];
            if (service) {
                [MCTMessageHelper showBroadcastHintWithServiceName:service.name andBroadcastType:self.message.broadcast_type inVC:self.viewController];
            }
        }
    }

    [self setNeedsLayout];
}

- (UIView *)bottomContentView
{
    T_UI();
    if (self.detailsExpanded) {
        if (self.controlView.frame.size.height != 0) {
            return self.controlView;
        } else {
            return self.messageView;
        }
    } else if (self.recipientSummaryView != nil) {
        return self.recipientSummaryView;
    } else if (self.controlView.frame.size.height != 0) {
        return self.controlView;
    } else {
        return self.messageView;
    }
}

- (void)layoutSubviews
{
    T_UI();
    HERE();
    [super layoutSubviews];

    CGRect cvFrame = self.contentView.frame;
    cvFrame.size.height = CGRectGetMaxY([self bottomContentView].frame);
    if (!self.detailsExpanded)
        cvFrame.origin.y = 0;
    self.contentView.frame = cvFrame;

    if (self.detailsExpanded) {
        self.recipientsView.top = CGRectGetMaxY(self.contentView.frame) + MARGIN;
    }

    CGFloat contentHeight = CGRectGetMaxY((self.detailsExpanded ? self.recipientsView : self.contentView).frame);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, contentHeight);
    if (self.detailsExpanded) {
        [self scrollToBottom];
    }
}

#pragma mark -

- (UIView *)createSeperatorWithYPosition:(CGFloat)y andTitle:(NSString *)title
{
    T_UI();
    CGRect frame = CGRectMake(0, y, self.frame.size.width-2*MARGIN, 20);
    UILabel *seperator = [[UILabel alloc] initWithFrame:frame];
    seperator.backgroundColor = [UIColor MCTSectionBackgroundColor];
    seperator.font = [self titleFont];
    seperator.textAlignment = NSTextAlignmentCenter;
    seperator.textColor = [UIColor whiteColor];
    seperator.text = title;
    return seperator;
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    T_UI();
    return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    T_UI();
    // TODO: sometimes wrong results e.g. when in bg
    // Need to delay repositioning because calling sizeThatFits: at this point may give incorrect results

    [self performSelector:@selector(repositionWebView:) withObject:webView afterDelay:0.1];
}

- (void)repositionView:(UIView *)view withOffset:(CGFloat)offset
{
    T_UI();
    if (view) {
        CGRect frame = view.frame;
        frame.origin.y += offset;
        view.frame = frame;
    }
}

- (void)repositionWebView:(UIWebView *)webView
{
    T_UI();
    // Get the height of the webview content
    CGRect msgFrame = webView.frame;
    CGFloat w = webView.frame.size.width;
    msgFrame.size = [webView sizeThatFits:CGSizeMake(w, 0)];
    msgFrame.size.width = w;
    webView.frame = msgFrame;

    CGFloat addedHeight = webView.frame.size.height;

    // Make the parent views grow
    for (UIView *view in [NSArray arrayWithObjects:self.messageView, self.contentView, nil]) {
        CGRect frame = view.frame;
        frame.size.height += addedHeight;
        view.frame = frame;
    }

    // reposition the views under the messageView

    [self repositionView:self.controlView withOffset:addedHeight];
    [self repositionView:self.attachmentsView withOffset:addedHeight];
    [self repositionView:self.recipientSummaryView withOffset:addedHeight];
    [self repositionView:self.recipientsView withOffset:addedHeight];

    CGSize contentSize = self.scrollView.contentSize;
    if (self.detailsExpanded) {
        contentSize.height = self.recipientsView.frame.origin.y + self.recipientsView.frame.size.height;
    } else {
        contentSize.height = self.contentView.frame.origin.y + self.contentView.frame.size.height;
    }
    self.scrollView.contentSize = contentSize;

    if (self.scrollView.contentOffset.y > CGRectGetMinY(webView.frame)) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                    self.scrollView.contentOffset.y + addedHeight);
    }
}

- (UIView *)createMessageViewWithYPosition:(CGFloat)y
{
    T_UI();
    // if hideHeader is true, then there should be no margin!
    BOOL hideHeader = (self.brandingResult != nil && !self.brandingResult.showHeader);

    CGFloat w = self.contentView.frame.size.width;
    if (!hideHeader)
        w -= 2*MARGIN;

    UIView *msgView = [[UIView alloc] init];
    CGRect msgFrame = CGRectMake(hideHeader ? 0 : MARGIN, y, w, 1);

    BOOL showBranded = NO;
    if (self.message.branding != nil) {
        if (self.brandingResult.file != nil) {
            if (self.webView) {
                [self.webView removeFromSuperview];
                MCT_RELEASE(self.webView);
            }
            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, msgFrame.size.width, msgFrame.size.height)];
            [self.webView loadBrandingResult:self.brandingResult];

            self.webView.bounces = NO;
            self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
            self.webView.delegate = self;
            self.webView.tag = MCT_TAG_MESSAGE_TEXT;
            self.webView.backgroundColor = self.brandingResult.color ? [UIColor colorWithString:self.brandingResult.color] : [UIColor clearColor];

            [msgView addSubview:self.webView];
            if (!hideHeader)
                [MCTUIUtils addRoundedBorderToView:self.webView withBorderColor:[UIColor clearColor] andCornerRadius:5];
            showBranded = YES;
        }
    }

    if (!showBranded) {
        int textViewPadding = 9;

        // Calculate height of message

        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = [self contentFont];
        gettingSizeLabel.text = self.message.message;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByClipping;

        CGSize msgSize = [gettingSizeLabel sizeThatFits:CGSizeMake(w - msgFrame.origin.x - 2 * textViewPadding, 1000)];

        msgFrame.size.height = msgSize.height + 2 * textViewPadding;

        CGRect txtFrame = msgFrame;
        txtFrame.origin.x = 0;
        txtFrame.origin.y = 0;

        MCTMessageTextView *msgTextView = [[MCTMessageTextView alloc] initWithFrame:txtFrame];
        msgTextView.text = self.message.message;
        msgTextView.textColor = [UIColor blackColor];
        msgTextView.font = [self contentFont];
        msgTextView.scrollEnabled = NO;
        msgTextView.editable = NO;
        msgTextView.tag = MCT_TAG_MESSAGE_TEXT;
        msgTextView.backgroundColor = [UIColor whiteColor];
        msgTextView.touchDelegate = self;

        [msgView addSubview:msgTextView];

        [MCTUIUtils addRoundedBorderToView:msgTextView withBorderColor:[UIColor lightGrayColor] andCornerRadius:8];
    }

    msgView.frame = msgFrame;
    return msgView;
}

#pragma mark -

- (UIView *)createAttachmentsViewWithYPosition:(CGFloat)y
{
    T_UI();
    CGRect pvFrame = CGRectMake(MARGIN, y, self.contentView.frame.size.width - 2 * MARGIN, 0);
    UIView *parentView = [[UIView alloc] initWithFrame:pvFrame];

    for (int i = 0; i < [self.message.attachments count]; i++) {
        MCT_com_mobicage_to_messaging_AttachmentTO *attachment = [self.message.attachments objectAtIndex:i];
        UIControl *attachmentControl = (UIControl *) [[[NSBundle mainBundle] loadNibNamed:@"attachmentView"
                                                                                    owner:self
                                                                                  options:nil] objectAtIndex:0];

        [MCTUIUtils addRoundedBorderToView:attachmentControl
                           withBorderColor:[UIColor darkGrayColor]
                           andCornerRadius:10];

        attachmentControl.tag = i;
        attachmentControl.width = parentView.width;
        attachmentControl.top = i * (attachmentControl.height + MARGIN);
        attachmentControl.centerX = parentView.width / 2;
        [attachmentControl addTarget:self
                              action:@selector(onAttachmentClicked:)
                    forControlEvents:UIControlEventTouchUpInside];

        UIImageView *imageView = ((UIImageView *) [attachmentControl viewWithTag:-1]);
        UILabel *label = ((UILabel *) [attachmentControl viewWithTag:-2]);

        imageView.image = [MCTMessageHelper imageForContentType:attachment.content_type];
        label.text = attachment.name;

        [parentView addSubview:attachmentControl];
    }
    parentView.height = ((UIView *) parentView.subviews.lastObject).bottom;
    return parentView;
}

#pragma mark -

- (TTButton *)createTTButtonWithButtonTO:(MCT_com_mobicage_to_messaging_ButtonTO *)btn index:(NSInteger)index
{
    T_UI();
    BOOL isDismissBtn = (index == [self.message.buttons count]);
    TTButton *ttBtn = [TTButton buttonWithStyle:isDismissBtn ? MCT_STYLE_DISMISS_BUTTON : MCT_STYLE_MAGIC_BUTTON
                                          title:btn.caption];
    if ([MCTMessageHelper shouldDisableButton:btn forMessage:self.message withSenderIsService:YES]) {
        ttBtn.enabled = NO;
    }
    ttBtn.tag = index;
    SEL onBtnClicked = isDismissBtn ? @selector(onDismissButtonClicked:) : @selector(onMagicButtonClicked:);
    [ttBtn addTarget:self action:onBtnClicked forControlEvents:UIControlEventTouchUpInside];
    return ttBtn;
}

- (int)addAvatarsForButton:(MCT_com_mobicage_to_messaging_ButtonTO *)btn
             toScrollView:(UIScrollView *)avaScrollView
{
    T_UI();
    BOOL isDmismissBtn = (btn.idX == nil);
    int answerCount = 0;
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {
        BOOL memberDismissed = member.button_id == nil && (member.status & MCTMessageStatusAcked) != 0;
        if ((isDmismissBtn && memberDismissed) || [member.button_id isEqualToString:btn.idX]) {
            // |avaX| will be increased later by |widestBtnWidth|
            CGFloat avaX = answerCount * (BTN_AVA_WIDTH + BTN_AVA_MARGIN);
            CGRect avaFrame = CGRectMake(0, 0, BTN_AVA_WIDTH, BTN_AVA_WIDTH);
            UIImageView *ava = [[UIImageView alloc] initWithFrame:avaFrame];
            ava.image = [self.friendsPlugin userAvatarImageByEmail:member.member];
            [MCTUIUtils addRoundedBorderToView:ava];

            CGRect ctrlFrame = avaFrame;
            ctrlFrame.origin.x = avaX;
            UIControl *uiCtrl = [[UIControl alloc] initWithFrame:ctrlFrame];
            uiCtrl.tag = [self.message.members indexOfObject:member];
            [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];
            [uiCtrl addSubview:ava];

            [avaScrollView addSubview:uiCtrl];
            answerCount++;
        }
    }

    return answerCount;
}

- (UIView *)createButtonsViewWithYPosition:(CGFloat)y
{
    T_UI();
    CGFloat w = self.contentView.frame.size.width - 2*MARGIN;

    // X position of the buttons
    CGFloat btnX = 0;
    // Y position of the next button/avatar
    CGFloat nextY = 0;

    NSMutableArray *btnArray = [NSMutableArray arrayWithCapacity:[self.message.buttons count]];
    NSMutableArray *scrollArray = [NSMutableArray arrayWithCapacity:[self.message.buttons count]];

    NSMutableArray *btnTOArray = [NSMutableArray arrayWithArray:self.message.buttons];
    if ((self.message.flags & MCTMessageFlagAllowDismiss) == MCTMessageFlagAllowDismiss) {
        MCT_com_mobicage_to_messaging_ButtonTO *btn = [MCT_com_mobicage_to_messaging_ButtonTO transferObject];
        btn.caption = NSLocalizedString(@"Roger that", nil);
        [btnTOArray addObject:btn];
    }

    int maxAnswerCount = 0;
    for (MCT_com_mobicage_to_messaging_ButtonTO *btn in self.message.buttons) {
        int btnAnswerCount = 0;
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {
            if ([member.button_id isEqualToString:btn.idX]) {
                btnAnswerCount++;
            }
        }
        maxAnswerCount = MAX(maxAnswerCount, btnAnswerCount);
    }
    if (IS_FLAG_SET(self.message.flags, MCTMessageFlagAllowDismiss)) {
        int dismissBtnAnswerCount = 0;
        for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {
            if (IS_FLAG_SET(member.status, MCTMessageStatusAcked) && member.button_id == nil) {
                dismissBtnAnswerCount++;
            }
        }
        maxAnswerCount = MAX(maxAnswerCount, dismissBtnAnswerCount);
    }

    CGFloat btnWidth = w - btnX;
    if (maxAnswerCount)
        btnWidth -= MARGIN + MIN(3, maxAnswerCount) * (BTN_AVA_MARGIN + BTN_AVA_WIDTH) - BTN_AVA_MARGIN;

    int i = 0;
    for (MCT_com_mobicage_to_messaging_ButtonTO *btn in btnTOArray) {
        // Add avatars in a scroll view
        CGRect scrlFrame = CGRectMake(btnX, nextY, w, BTN_AVA_WIDTH);
        UIScrollView *avaScrollView = [[UIScrollView alloc] initWithFrame:scrlFrame];
        int answerCount = [self addAvatarsForButton:btn toScrollView:avaScrollView];
        avaScrollView.contentSize = CGSizeMake(answerCount * (BTN_AVA_WIDTH + BTN_AVA_MARGIN), scrlFrame.size.height);
        [scrollArray addObject:avaScrollView];

        TTButton *ttBtn = [self createTTButtonWithButtonTO:btn index:i];
        [btnArray addObject:ttBtn];

        // Calculate button size based on the caption
        CGSize capSize = [MCTUIUtils sizeForTTButton:ttBtn constrainedToSize:CGSizeMake(btnWidth, 126)];
        ttBtn.frame = CGRectMake(btnX, nextY, btnWidth, MAX(BTN_AVA_WIDTH, capSize.height));

        nextY += ttBtn.frame.size.height + MARGIN - 5;
        i++;
    }

    CGRect btnViewFrame = CGRectMake(MARGIN, y, w, (i == 0) ? 0 : nextY);
    UIView *btnView = [[UIView alloc] initWithFrame:btnViewFrame];

    for (UIView *ttBtn in btnArray)
        [btnView addSubview:ttBtn];

    // re-position the scroll views next to the buttons
    for (UIScrollView *avaScrollView in scrollArray) {
        CGRect frame = avaScrollView.frame;
        frame.origin.x += btnWidth + MARGIN;
        frame.size.width = w - frame.origin.x;
        avaScrollView.frame = frame;

        [btnView addSubview:avaScrollView];
    }

    return btnView;
}

#pragma mark -

- (MCTFormView *)createFormViewWithYPosition:(CGFloat)y
{
    T_UI();
    CGFloat w = self.contentView.frame.size.width - 2*MARGIN;
    MCTColorScheme scheme = (self.brandingResult) ? self.brandingResult.scheme : MCT_DEFAULT_COLOR_SCHEME;
    MCTFormView *v = [MCTFormView viewWithMessage:self.message andWidth:w andColorScheme:scheme inViewController:self.viewController];
    [v layoutIfNeeded];
    v.frame = CGRectMake(MARGIN, y, w, [v height] + MARGIN);
    return v;
}

#pragma mark -

- (UIImageView *)createRecipientsStatusIconForMember:(MCT_com_mobicage_to_messaging_MemberStatusTO *)member
                                     withAvatarWidth:(CGFloat)width
{
    T_UI();
    CGFloat sW = 12;
    CGFloat sH = 19;

    NSString *statusImgName;
    if ((member.status & MCTMessageStatusAcked) != 0) {
        statusImgName = MCT_ICON_MEMBER_STATUS_ACKED;
    } else if ((member.status & MCTMessageStatusReceived) != 0) {
        statusImgName = MCT_ICON_MEMBER_STATUS_RECEIVED;
    } else {
        statusImgName = MCT_ICON_MEMBER_STATUS_ONTHEWAY;
    }

    UIImageView *status = [[UIImageView alloc] initWithImage:[UIImage imageNamed:statusImgName]];
    status.frame = CGRectMake(width - 2*sW/3, (sW-sH)/2 - sW/3, sW, sH);
    return status;
}

- (NSArray *)createRecipientsSummaryAvatars
{
    T_UI();
    NSMutableArray *received = [NSMutableArray array];
    NSMutableArray *notReceived = [NSMutableArray array];

    int count = 0;
    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {
        if (member.button_id != nil || [member.member isEqualToString:self.message.sender]
            || (member.status & MCTMessageStatusAcked) != 0)
            continue;

        count++;

        UIImageView *avatar = [[UIImageView alloc]
                                initWithImage:[self.friendsPlugin userAvatarImageByEmail:member.member]];
        avatar.frame = CGRectMake(0, 0, BTN_AVA_WIDTH, BTN_AVA_WIDTH);
        [MCTUIUtils addRoundedBorderToView:avatar];

        CGRect f = CGRectMake(0, 0, BTN_AVA_WIDTH, BTN_AVA_WIDTH);
        UIControl *uiCtrl = [[UIControl alloc] initWithFrame:f];
        uiCtrl.tag = [self.message.members indexOfObject:member];
        [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];

        [uiCtrl addSubview:avatar];
        [uiCtrl addSubview:[self createRecipientsStatusIconForMember:member withAvatarWidth:BTN_AVA_WIDTH]];

        NSMutableArray *array;
        if ((member.status & MCTMessageStatusReceived) != 0) {
            array = received;
        } else {
            array = notReceived;
        }
        [array addObject:uiCtrl];
    }

    NSMutableArray *avatars = [NSMutableArray arrayWithCapacity:count];

    for (NSArray *array in [NSArray arrayWithObjects:received, notReceived, nil])
        for (UIView *view in array)
            [avatars addObject:view];

    return avatars;
}

- (BOOL)iAmOnlyRecipient
{
    T_UI();
    if ([self.friendsPlugin isMyEmail:self.message.sender])
        return NO;

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members)
        if (![self.friendsPlugin isMyEmail:member.member] && ![self.message.sender isEqualToString:member.member])
            return NO;

    return YES;
}

- (UIView *)createRecipientsSummaryViewWithYPosition:(CGFloat)y
{
    T_UI();
    if ([self iAmOnlyRecipient])
        return nil; // No recipient summary if I am the only recipient

    CGFloat w = self.contentView.frame.size.width - 2*MARGIN;
    CGFloat m = 12;

    NSArray *avatars = [self createRecipientsSummaryAvatars];

    NSInteger count = [avatars count];

    if (count == 0)
        return nil;

    int totalWidth = count * BTN_AVA_WIDTH + (count - 1) * m;
    int rows = ceil(totalWidth / w);
    CGFloat h = rows * BTN_AVA_WIDTH + (rows - 1) * m;

    CGRect rsFrame = CGRectMake(MARGIN, y, w, h + MARGIN);
    UIView *summaryView = [[UIView alloc] initWithFrame:rsFrame];

    // |w| = |avasPerRow| * |BTN_AVA_WIDTH| + (|avasPerRow| - 1) * |m|
    int avasPerRow = floor((w + m) / (BTN_AVA_WIDTH + m));

    for (int i = 0; i < count; i++) {
        UIView *avatarView = [avatars objectAtIndex:i];

        int col = (i % avasPerRow);
        CGFloat x = col * BTN_AVA_WIDTH;
        if (col != 0)
            x += col * m;

        int row = (i / avasPerRow);
        CGFloat y = row * BTN_AVA_WIDTH;
        if (row != 0)
            y += row * m;

        CGRect f = avatarView.frame;
        f.origin.x = x;
        f.origin.y = y;
        avatarView.frame = f;

        [summaryView addSubview:avatarView];
    }

    return summaryView;
}

- (UIView *)createRecipientsViewWithYPosition:(CGFloat)y
{
    T_UI();
    CGFloat w = self.contentView.frame.size.width - 2*MARGIN;

    UIControl *recipientsView = [[UIControl alloc] init];
    [recipientsView addTarget:self action:@selector(onBackgroundTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIView *sep = [self createSeperatorWithYPosition:0 andTitle:NSLocalizedString(@"Details", nil)];
    [recipientsView addSubview:sep];

    CGFloat memberY = sep.frame.origin.y + sep.frame.size.height + MARGIN;

    for (MCT_com_mobicage_to_messaging_MemberStatusTO *member in self.message.members) {

        BOOL memberIsSender = [member.member isEqualToString:self.message.sender];
        if (memberIsSender && member.button_id == nil) {
            continue;
        }

        // Avatar
        CGRect aFrame = CGRectMake(0, 0, 50, 50);
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:aFrame];
        [MCTUIUtils addRoundedBorderToView:avatarView];
        avatarView.image = [self.friendsPlugin userAvatarImageByEmail:member.member];

        CGRect ctrlFrame = aFrame;
        ctrlFrame.origin.y = memberY;
        UIControl *uiCtrl = [[UIControl alloc] initWithFrame:ctrlFrame];
        uiCtrl.tag = [self.message.members indexOfObject:member];
        [uiCtrl addTarget:self action:@selector(onParticipantTapped:) forControlEvents:UIControlEventTouchUpInside];

        [uiCtrl addSubview:avatarView];
        [uiCtrl addSubview:[self createRecipientsStatusIconForMember:member withAvatarWidth:aFrame.size.width]];
        [recipientsView addSubview:uiCtrl];

        MCTColorScheme scheme = (self.brandingResult) ? self.brandingResult.scheme : MCT_DEFAULT_COLOR_SCHEME;
        UIColor *textColor = (scheme == MCTColorSchemeLight) ? [UIColor blackColor] : [UIColor whiteColor];

        // Recipient name
        CGFloat nX = aFrame.origin.x + aFrame.size.width + MARGIN;
        CGRect nFrame = CGRectMake(nX, memberY - 6, w - nX, 23);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nFrame];
        nameLabel.text = [self.friendsPlugin friendDisplayNameByEmail:member.member];
        nameLabel.font = [self contentFont];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = textColor;
        [recipientsView addSubview:nameLabel];

        // Received on
        CGFloat recY = nFrame.origin.y + nFrame.size.height;
        CGRect recFrame = CGRectMake(nX, recY, w - nX, 16);
        UILabel *receivedLabel = [[UILabel alloc] initWithFrame:recFrame];
        receivedLabel.font = [self titleFont];
        receivedLabel.adjustsFontSizeToFitWidth = YES;
        receivedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        receivedLabel.backgroundColor = [UIColor clearColor];
        receivedLabel.textColor = textColor;

        if ((member.status & MCTMessageStatusReceived) == 0) {
            receivedLabel.text = NSLocalizedString(@"Not yet received", nil);
        } else {
            receivedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ at %@", nil),
                                  memberIsSender ? NSLocalizedString(@"Sent", nil) : NSLocalizedString(@"Received", nil),
                                  [MCTUtils timestampNotation:member.received_timestamp]];
        }
        [recipientsView addSubview:receivedLabel];

        // Replied on
        CGFloat ackY = recFrame.origin.y + recFrame.size.height;
        CGRect ackFrame = CGRectMake(nX, ackY, w - nX, 16);
        UILabel *ackLabel = [[UILabel alloc] initWithFrame:ackFrame];
        ackLabel.font = [self titleFont];
        ackLabel.adjustsFontSizeToFitWidth = YES;
        ackLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        ackLabel.backgroundColor = [UIColor clearColor];
        ackLabel.textColor = textColor;

        if ((member.status & MCTMessageStatusAcked) == 0) {
            ackLabel.text = NSLocalizedString(@"Not yet replied", nil);
        } else {
            NSString *action;
            if (member.button_id == nil) {
                action = NSLocalizedString(@"Acknowledged", nil);
            } else {
                NSString *answer = [self.message buttonWithId:member.button_id].caption;
                action = [NSString stringWithFormat:NSLocalizedString(@"Replied %@", nil), answer];
            }
            ackLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ at %@", nil),
                             action, [MCTUtils timestampNotation:member.acked_timestamp]];
        }
        [recipientsView addSubview:ackLabel];

        memberY += avatarView.frame.size.height + MARGIN;
    }

    recipientsView.frame = CGRectMake(MARGIN, y, w, memberY);

    return recipientsView;
}

- (UIView *)createBroadcastNotificationView
{
    T_UI();
    if (self.message.broadcast_type == nil) {
        return nil;
    }

    LOG(@"broadcast type: %@", self.message.broadcast_type);

    MCTFriendBroadcastInfo *fbi = [self.friendsPlugin.store broadcastInfoWithFriend:self.message.sender];
    if (fbi == nil) {
        [MCTSystemPlugin logError:nil
                      withMessage:[NSString stringWithFormat:@"BroadcastData was null for: %@", self.message.sender]];
        return nil;
    }

    CGFloat notificationSettingsHeight = 78;
    MCTFloat notificationSettingsWidth = [UIScreen mainScreen].applicationFrame.size.width / 4;
    MCTFloat notificationPadding = 5;
    MCTFloat borderSize = 2;

    CGRect bnvFrame = CGRectMake(0, self.height - (notificationSettingsHeight + borderSize), [UIScreen mainScreen].applicationFrame.size.width, notificationSettingsHeight + borderSize);
    UIView *broadcastView = [[UIView alloc] initWithFrame:bnvFrame];

    UIView *topBorder = [[UIView alloc] init];
    UIView *seperator = [[UIView alloc] init];
    UILabel *broadcastNotificationText = [[UILabel alloc] init];
    MCTMenuItemView *broadcastNotificationMIV;
    MCTColorScheme scheme = [self.viewController colorSchemeForBrandingResult:self.brandingResult];

    CGRect mivFrame = CGRectMake([UIScreen mainScreen].applicationFrame.size.width - notificationSettingsWidth, self.height - notificationSettingsHeight, notificationSettingsWidth, notificationSettingsHeight);
    broadcastView.backgroundColor = [UIColor MCTMercuryColor];

    CGFloat margin = 2;
    CGFloat imageWidth = 28;
    CGFloat labelFontSize = 12;
    CGFloat menuItemWidth = 76;
    CGRect imageFrame = CGRectMake(MAX(0, (menuItemWidth - imageWidth) / 2), 10, imageWidth, imageWidth);

    UIFont *font = [UIFont boldSystemFontOfSize:labelFontSize - 2];


    if (scheme == MCTColorSchemeDark) {
        topBorder.backgroundColor = [UIColor whiteColor];
        seperator.backgroundColor = [UIColor whiteColor];
        broadcastNotificationText.textColor = [UIColor blackColor];

        UIImage *img = [UIImage imageWithIcon:@"fa-bell"
                              backgroundColor:[UIColor clearColor]
                                    iconColor:[UIColor blackColor]
                                      andSize:CGSizeMake(imageWidth,imageWidth)];

        broadcastNotificationMIV = [[MCTMenuItemView alloc] initWithFrame:mivFrame
                                                                  menuItem:fbi
                                                                     image:img
                                                               colorScheme:MCTColorSchemeLight
                                                               badgeString:nil
                                                                imageFrame:imageFrame
                                                                      font:font];
        broadcastView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    } else {
        topBorder.backgroundColor = [UIColor blackColor];
        seperator.backgroundColor = [UIColor blackColor];
        broadcastNotificationText.textColor = [UIColor whiteColor];

        UIImage *img = [UIImage imageWithIcon:@"fa-bell"
                              backgroundColor:[UIColor clearColor]
                                    iconColor:[UIColor whiteColor]
                                      andSize:CGSizeMake(imageWidth,imageWidth)];

        broadcastNotificationMIV = [[MCTMenuItemView alloc] initWithFrame:mivFrame
                                                                  menuItem:fbi
                                                                     image:img
                                                               colorScheme:MCTColorSchemeDark
                                                               badgeString:nil
                                                                imageFrame:imageFrame
                                                                      font:font];
        broadcastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    notificationSettingsWidth = broadcastNotificationMIV.width;

    broadcastNotificationText.frame = CGRectMake(notificationPadding, 0, [UIScreen mainScreen].applicationFrame.size.width - (notificationSettingsWidth +  2 * notificationPadding + borderSize), notificationSettingsHeight);
    broadcastNotificationText.lineBreakMode = NSLineBreakByWordWrapping;
    broadcastNotificationText.numberOfLines = 0;
    broadcastNotificationText.text = [NSString stringWithFormat:NSLocalizedString(@"You received this message because you are subscribed to: %@.", nil),
                                      self.message.broadcast_type];;
    broadcastNotificationText.font = [broadcastNotificationText.font fontWithSize:labelFontSize];
    broadcastNotificationText.backgroundColor = [UIColor clearColor];
    [broadcastNotificationText sizeToFit];
    MCTFloat height = broadcastNotificationText.height;
    if (height > notificationSettingsHeight) {
        broadcastView.frame = CGRectMake(0, self.height - (height + borderSize), [UIScreen mainScreen].applicationFrame.size.width, height + borderSize);
    } else {
        height = notificationSettingsHeight;
    }
    broadcastNotificationText.height = height;
    broadcastNotificationText.centerY = broadcastView.height / 2 + borderSize /2;


    CGRect topBorderFrame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, borderSize);
    topBorder.frame = topBorderFrame;
    [broadcastView addSubview:topBorder];
    CGRect seperatorFrame = CGRectMake([UIScreen mainScreen].applicationFrame.size.width - (notificationSettingsWidth + borderSize), 0, borderSize, broadcastView.height);
    seperator.frame = seperatorFrame;
    [broadcastView addSubview:seperator];

    broadcastNotificationMIV.left = [UIScreen mainScreen].applicationFrame.size.width - notificationSettingsWidth;
    broadcastNotificationMIV.width = notificationSettingsWidth;
    broadcastNotificationMIV.height = notificationSettingsHeight;
    broadcastNotificationMIV.centerY = broadcastView.height / 2 + borderSize / 2;
    [broadcastView addSubview:broadcastNotificationMIV];

    [broadcastNotificationMIV addTarget:self
                                 action:@selector(didClickNotificationSettings:)
                       forControlEvents:UIControlEventTouchUpInside];

    [broadcastView addSubview:broadcastNotificationText];

    return broadcastView;
}

- (void)didClickNotificationSettings:(id)sender
{
    T_UI();
    MCTFriendBroadcastInfo *fbi = [self.friendsPlugin.store broadcastInfoWithFriend:self.message.sender];
    if (fbi == nil) {
        [MCTSystemPlugin logError:nil
                      withMessage:[NSString stringWithFormat:@"BroadcastData was null for: %@", self.message.sender]];
        return;
    }

    MCT_com_mobicage_to_service_PressMenuIconRequestTO *request = [MCT_com_mobicage_to_service_PressMenuIconRequestTO transferObject];
    request.context = [NSString stringWithFormat:@"BROADCAST_%@", self.message.key];
    request.service = self.message.sender;
    request.coords = fbi.coords;
    request.hashed_tag = fbi.hashedTag;
    request.generation = fbi.generation;
    request.timestamp = [MCTUtils currentServerTime];

    MCTMessageFlowRun *mfr = [MCTMessageFlowRun messageFlowRun];
    mfr.staticFlowHash = fbi.staticFlowHash;
    request.static_flow_hash = fbi.staticFlowHash;

    NSDictionary *userInput = [NSDictionary dictionaryWithObjectsAndKeys:[request dictRepresentation], @"request",
                               @"com.mobicage.api.services.pressMenuItem", @"func", nil];

    MCTMessageDetailVC *vc = (MCTMessageDetailVC *) self.viewController;

    @try {
        [[MCTComponentFramework menuViewController] executeMFR:mfr withUserInput:userInput throwIfNotReady:YES];
    } @catch (MCTBizzException *e) {
        vc.currentAlertView = [MCTUIUtils showAlertWithTitle:e.name andText:e.reason];
        vc.currentAlertView.delegate = vc;
        vc.currentAlertView.tag = MCT_TAG_ERROR;
        [[MCTComponentFramework workQueue] addOperationWithBlock:^{
            [[MCTComponentFramework friendsPlugin] requestStaticFlowWithItem:fbi andService:self.message.sender];
        }];
        return;
    }

    vc.currentActionSheet = [vc showActionSheetWithTitle:NSLocalizedString(@"Processing ...", nil)];
    vc.currentActionSheet.delegate = vc;
    vc.expectNextTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                          target:vc
                                                        selector:@selector(onExpectNextTimeout:)
                                                        userInfo:nil
                                                         repeats:NO];
}


#pragma mark -

- (IBAction)onBackgroundTapped:(id)sender
{
    T_UI();
    SEL selector = @selector(onBackgroundTapped:);
    if ([self.controlView respondsToSelector:selector]) {
        IMP imp = [self.controlView methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self.controlView, selector);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    T_UI();
    [self onBackgroundTapped:self];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)onDismissButtonClicked:(UIControl *)sender
{
    T_UI();
    sender.enabled = NO;
    [MCTMessageHelper onDismissButtonClickedForMessage:self.message];
    [self refreshViewWithIsOtherMessage:NO];
}

- (IBAction)onMagicButtonClicked:(UIControl *)sender
{
    T_UI();
    sender.enabled = NO;
    [MCTMessageHelper onMagicButtonClicked:[self.message.buttons objectAtIndex:sender.tag]
                                forMessage:self.message
                                     forVC:self.viewController];
    [self refreshViewWithIsOtherMessage:NO];
}

- (IBAction)onAttachmentClicked:(UIControl *)sender
{
    T_UI();
    [(MCTMessageDetailVC *)self.viewController onAttachmentClickedWithIndex:sender.tag];
}

- (void)onShowDetailsTapped
{
    T_UI();
    self.detailsExpanded = !self.detailsExpanded;

    if (self.message.form)
        [self.message.form setValue:[((MCTFormView *) self.controlView).widgetView widget] forKey:@"widget"];

    [self refreshViewWithIsOtherMessage:NO];
}

- (void)onParticipantTapped:(id)sender
{
    T_UI();
    UIControl *uiCtrl = sender;
    NSString *email = uiCtrl.tag == -1 ? self.message.sender : [[self.message.members objectAtIndex:uiCtrl.tag] member];
    [MCTMessageHelper onParticipantClicked:email inNavigationController:self.viewController.navigationController];
}

#pragma mark -

 - (void)scrollToBottom
{
    T_UI();
    CGFloat availableScreenHeight = [MCTUIUtils availableSizeForViewWithController:self.viewController].height;
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.height);
    if (bottomOffset.y > 0 || bottomOffset.y > availableScreenHeight - self.scrollView.height) {
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        [self.scrollView flashScrollIndicators];
    }
}

- (void)scrollUpForBottomViewWithHeight:(CGFloat)h
{
    T_UI();
    self.contentOffset = self.scrollView.contentOffset;

    if (![self.controlView isKindOfClass:[MCTFormView class]])
        return;

    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat navHeight = self.viewController.navigationController.navigationBar.frame.size.height;

    CGFloat containerHeight = CGRectGetMaxY(self.controlView.frame);

    CGFloat y1 = appFrame.origin.y + navHeight + containerHeight + MARGIN;
    CGFloat y2 = CGRectGetMaxY(appFrame) - h;

    if (y1 > y2) {
        CGFloat visibleMsgHeight = y2;
        CGFloat applyDiff;
        if (CGRectGetMaxY(appFrame) <= self.height) {
            applyDiff = 0;
        }
        else {
            applyDiff = -64;
        }
        CGFloat widgetViewH = ((MCTFormView *)self.controlView).maxWidgetHeight;
        CGFloat topOfControlViewOnScreen = visibleMsgHeight - widgetViewH - MARGIN;
        CGFloat topOfControlViewInScrollView = self.controlView.frame.origin.y;


        if (topOfControlViewInScrollView > topOfControlViewOnScreen || topOfControlViewOnScreen - topOfControlViewInScrollView < widgetViewH ) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3];

            self.scrollView.contentOffset = CGPointMake(0, topOfControlViewInScrollView - topOfControlViewOnScreen - applyDiff);

            [UIView commitAnimations];
        }
    }

    self.scrollView.scrollEnabled = NO;
}

- (void)scrollBack
{
    T_UI();
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];

    self.scrollView.contentOffset = self.contentOffset;
    self.scrollView.scrollEnabled = YES;

    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    T_UI();
    CGSize kbSize = [MCTUIUtils keyboardSizeWithNotification:aNotification];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollUpForBottomViewWithHeight:kbSize.height];
    });

}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    T_UI();
    [self scrollBack];
}

#pragma mark -
#pragma mark Intents

- (void)registerIntents
{
    T_UI();
    NSArray *actions = [NSArray arrayWithObjects:kINTENT_MESSAGE_MODIFIED, kINTENT_MESSAGE_RECEIVED,
                        kINTENT_IDENTITY_MODIFIED, kINTENT_MESSAGE_REPLACED, kINTENT_FRIEND_MODIFIED,
                        kINTENT_FRIEND_REMOVED, kINTENT_MESSAGE_DETAIL_SCROLL_DOWN,
                        nil];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                   forIntentActions:actions
                                                            onQueue:[MCTComponentFramework mainQueue]];
}

- (void)unregisterDelegatesAndListeners
{
    T_UI();
    HERE();
    [[MCTComponentFramework intentFramework] unregisterIntentListener:self];

    if ([self.controlView respondsToSelector:@selector(unregisterIntents)]) {
        [self.controlView performSelector:@selector(unregisterIntents)];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([self.controlView isKindOfClass:[MCTFormView class]]) {
        // Need to unregister widget views ... would be cleaner to do in widgetView itself
        [[NSNotificationCenter defaultCenter] removeObserver:((MCTFormView *)self.controlView).widgetView];
    }

    ((MCTMessageScrollView *) self.scrollView).touchDelegate = nil;
    for (UIView *subview in self.messageView.subviews) {
        if ([subview isKindOfClass:[MCTMessageTextView class]])
            ((MCTMessageTextView *) subview).touchDelegate = nil;
    }
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    BOOL needsRefresh = NO;

    if (intent.action == kINTENT_IDENTITY_MODIFIED) {
        needsRefresh = YES;
    }
    else if (intent.action == kINTENT_MESSAGE_MODIFIED
             && [[intent stringForKey:@"message_key"] isEqualToString:self.message.key]) {

         if ([intent hasBoolKey:@"message_processed"] || [intent hasBoolKey:@"message_locked"]) {
             self.message = [self.messagesPlugin.store messageDetailsByKey:self.message.key]; // will also refresh UI
         }
    }
    else if (intent.action == kINTENT_MESSAGE_REPLACED
             && [[intent stringForKey:@"tmp_key"] isEqualToString:self.message.key]) {

        self.message = [self.messagesPlugin.store messageDetailsByKey:[intent stringForKey:@"key"]]; // will also refresh UI
    }
    else if (intent.action == kINTENT_FRIEND_MODIFIED || intent.action == kINTENT_FRIEND_REMOVED) {
        if ([self.message.sender isEqualToString:[intent stringForKey:@"email"]]) {
            if (intent.action == kINTENT_FRIEND_MODIFIED) {
                if (!self.brandingResult || self.brandingResult.showHeader) {
                    // update only the headerView
                    self.senderImageView.image = [self.friendsPlugin userAvatarImageByEmail:self.message.sender];
                    self.senderLabel.text = [self.friendsPlugin friendDisplayNameByEmail:self.message.sender];
                }
            } else {
                needsRefresh = YES;
            }
        } else {
            needsRefresh = (BOOL) [self.message memberWithEmail:[intent stringForKey:@"email"]];
        }
    }
    else if (intent.action == kINTENT_MESSAGE_DETAIL_SCROLL_DOWN) {
        [self scrollToBottom];
    }

    if (needsRefresh) {
        [self refreshViewWithIsOtherMessage:NO];
    }
}

- (void)processAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL processed = [MCTMessageHelper processAlertViewForVC:self.viewController clickedButtonAtIndex:buttonIndex forMessage:self.message];
    if (!processed) {
        if ([self.controlView isKindOfClass:[MCTFormView class]])
            processed = [((MCTFormView *)self.controlView) processAlertViewClickedButtonAtIndex:buttonIndex];
    }
    if (!processed)
        BUG(@"Cannot process alertView with tag %d and buttonIndex %d for message %@", alertView.tag, buttonIndex, self.message.key);
}

- (void)processActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL processed = false;
    if ([self.controlView isKindOfClass:[MCTFormView class]]) {
        processed = [((MCTFormView *)self.controlView) processActionSheetClickedButtonAtIndex:buttonIndex];
    }
    if (!processed)
        BUG(@"Cannot process actionSheet with tag %d and buttonIndex %d for message %@", actionSheet.tag, buttonIndex, self.message.key);
}



@end