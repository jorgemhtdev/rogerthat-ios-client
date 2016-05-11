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

#import "MCTComponentFramework.h"
#import "MCTFormView.h"
#import "MCTHTTPRequest.h"
#import "MCTIntent.h"
#import "MCTMessageHelper.h"
#import "MCTMessage.h"
#import "MCTMessageDetailView.h"
#import "MCTMyDigiPassView.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "MDPMobile.h"
#import "NSData+Base64.h"
#import "TTButtonContent.h"
#import "UIImage+FontAwesome.h"

#define MARGIN 10
#define ROW_HEIGHT 44
#define MAX_COLLAPSED_CELLS 3

#define SCOPE_EMAIL @"email"
#define SCOPE_PHONE @"phone"
#define SCOPE_ADDRESS @"address"
#define SCOPE_PROFILE @"profile"
#define SCOPE_EID_PROFILE @"eid_profile"
#define SCOPE_EID_ADDRESS @"eid_address"
#define SCOPE_EID_PHOTO @"eid_photo"

#define MCT_TAG_MDP_IMAGE_VIEW 2

#define MCT_TAG_INSTALL_MDP 1


@interface MCTMyDigiPassRow : NSObject

@property (nonatomic, copy) NSString *faCode;
@property (nonatomic, copy) NSString *value;

+ (instancetype)instanceWithFaCode:(NSString *)faCode value:(NSString *)value;

@end


@implementation MCTMyDigiPassRow

+ (instancetype)instanceWithFaCode:(NSString *)faCode value:(NSString *)value
{
    MCTMyDigiPassRow *row = [[MCTMyDigiPassRow alloc] init];
    row.faCode = faCode;
    row.value = value;
    return row;
}

@end


#pragma mark -

@interface MCTMdpTableViewCell : UITableViewCell

@end


@implementation MCTMdpTableViewCell

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    CGFloat M = 3;  // margin

    self.imageView.left = M;
    self.imageView.centerY = self.height / 2;

    CGFloat oldLeft = self.textLabel.left;
    self.textLabel.left = self.imageView.right + M;
    self.textLabel.width += oldLeft - self.textLabel.left;

    self.detailTextLabel.left = self.textLabel.left;
    self.detailTextLabel.width = self.textLabel.width;
}

@end


#pragma mark -

@interface MCTMyDigiPassView () 

@property (nonatomic) BOOL collapsed;
@property (nonatomic, copy) NSString *currentState;
@property (nonatomic, strong) MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *result;
@property (nonatomic, strong) NSDateFormatter *userDateFormatter;
@property (nonatomic, strong) NSDateFormatter *mdpDateFormatter;
@property (nonatomic, strong) NSDateFormatter *mdpDateTimeFormatter;
@property (nonatomic, strong) NSArray *scopes;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) MCTMdpTableViewCell *dummyCell;

@end


@implementation MCTMyDigiPassView



#pragma mark -

- (id)initWithDict:(NSDictionary *)widgetDict
          andWidth:(CGFloat)width
    andColorScheme:(MCTColorScheme)colorScheme
  inViewController:(MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *)vc
{
    T_UI();
    if (self = [super init]) {
        self.width = width;
        self.widgetDict = widgetDict;
        NSString *scope = [widgetDict stringForKey:@"scope" withDefaultValue:nil];
        if ([MCTUtils isEmptyOrWhitespaceString:scope]) {
            self.scopes = @[SCOPE_EID_PROFILE];
        } else{
            self.scopes = [scope componentsSeparatedByString:@" "];
        }
        self.viewController = vc;
        self.currentState = nil;

        self.mdpDateFormatter = [[NSDateFormatter alloc] init];
        self.mdpDateFormatter.dateFormat = @"yyyy-MM-dd";

        self.mdpDateTimeFormatter = [[NSDateFormatter alloc] init];
        self.mdpDateTimeFormatter.dateFormat = @"yyyy-MM-ddTHH:mm:ss.SSSZ";

        self.userDateFormatter = [[NSDateFormatter alloc] init];
        self.userDateFormatter.dateStyle = NSDateFormatterLongStyle;
        self.userDateFormatter.timeStyle = NSDateFormatterNoStyle;
        self.userDateFormatter.locale = [NSLocale currentLocale];

        id result = self.widgetDict[@"value"];
        if (result) {
            self.result = [MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO transferObjectWithDict:result];
            [self createResultTableView];
        } else {
            self.result = nil;
            [self createAutenticateBtn];
        }
        self.collapsed = self.result == nil;

    }
    return self;
}

- (void)createAutenticateBtn
{
    T_UI();
    if (self.authenticateBtn == nil) {
        self.authenticateBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_BUTTON
                                                   title:NSLocalizedString(@"Authenticate", nil)];

        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mdp_icon.png"]];
        imgView.size = CGSizeMake(65, 65);
        imgView.tag = MCT_TAG_MDP_IMAGE_VIEW;
        [self.authenticateBtn addSubview:imgView];
        [self.authenticateBtn addTarget:self
                                 action:@selector(onAuthenticateButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.authenticateBtn];
    }
}

- (void)createResultTableView
{
    T_UI();
    [self createTableViewData];

    if (self.resultTableView == nil) {
        self.resultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.resultTableView.dataSource = self;
        self.resultTableView.delegate = self;
        self.resultTableView.separatorInset = UIEdgeInsetsZero;
        IF_IOS8_OR_GREATER({
            self.resultTableView.layoutMargins = UIEdgeInsetsZero;
        });
        [MCTUIUtils addRoundedBorderToView:self.resultTableView
                           withBorderColor:self.resultTableView.separatorColor
                           andCornerRadius:5];
        [self addSubview:self.resultTableView];
    }
}

- (NSString *)stringFromDateString:(NSString *)dateString
{
    if ([MCTUtils isEmptyOrWhitespaceString:dateString])
        return @"";
    NSDate *date = [self.mdpDateFormatter dateFromString:dateString];
    return [self.userDateFormatter stringFromDate:date];
}

- (NSString *)stringFromDateTimeString:(NSString *)dateTimeString
{
    if ([MCTUtils isEmptyOrWhitespaceString:dateTimeString])
        return @"";
    NSDate *date = [self.mdpDateTimeFormatter dateFromString:dateTimeString];
    return [self.userDateFormatter stringFromDate:date];
}

- (void)addRowWithFaCode:(NSString *)faCode value:(NSString *)value
{
    [self.tableViewData addObject:[MCTMyDigiPassRow instanceWithFaCode:faCode
                                                                 value:value]];
}

- (void)createTableViewData
{
    T_UI();
    assert(self.result);

    self.tableViewData = [NSMutableArray array];
    if ([self.scopes containsObject:SCOPE_EID_PHOTO]) {
        // Special treatment for photo
        if (self.imageView == nil) {
            self.imageView = [[UIImageView alloc] init];
            [self addSubview:self.imageView];
        }
        self.imageView.image = [UIImage imageWithData:[NSData dataFromBase64String:self.result.eid_photo]];
    }
    if ([self.scopes containsObject:SCOPE_EID_PROFILE]) {
        [self addRowWithFaCode:@"fa-user"
                         value:self.result.eid_profile.displayName];
        [self addRowWithFaCode:@"fa-transgender"
                         value:self.result.eid_profile.displayGender];
        [self addRowWithFaCode:@"fa-birthday-cake"
                         value:[NSString stringWithFormat:@"%@, %@",
                                [self stringFromDateString:self.result.eid_profile.date_of_birth],
                                self.result.eid_profile.location_of_birth]];
        if (![MCTUtils isEmptyOrWhitespaceString:self.result.eid_profile.noble_condition]) {
            [self addRowWithFaCode:@"fa-black-tie"
                             value:self.result.eid_profile.noble_condition];
        }
        [self addRowWithFaCode:@"fa-hourglass-half"
                         value:[NSString stringWithFormat:NSLocalizedString(@"Valid from %@ to %@", nil),
                                [self stringFromDateString:self.result.eid_profile.validity_begins_at],
                                [self stringFromDateString:self.result.eid_profile.validity_ends_at]]];
        [self addRowWithFaCode:@"fa-flag"
                         value:self.result.eid_profile.nationality];
        [self addRowWithFaCode:@"fa-home"
                         value:self.result.eid_profile.issuing_municipality];
        if (![MCTUtils isEmptyOrWhitespaceString:self.result.eid_profile.created_at]) {
            [self addRowWithFaCode:@"fa-clock-o"
                             value:[self stringFromDateTimeString:self.result.eid_profile.created_at]];
        }
        [self addRowWithFaCode:@"fa-credit-card"
                         value:self.result.eid_profile.displayCardInfo];
    }
    if ([self.scopes containsObject:SCOPE_EID_ADDRESS]) {
        [self addRowWithFaCode:@"fa-home"
                         value:self.result.eid_address.displayValue];
    }
    if ([self.scopes containsObject:SCOPE_EMAIL]) {
        [self addRowWithFaCode:@"fa-envelope"
                         value:self.result.email];
    }
    if ([self.scopes containsObject:SCOPE_PHONE]) {
        [self addRowWithFaCode:@"fa-phone"
                         value:self.result.phone];
    }
    if ([self.scopes containsObject:SCOPE_PROFILE]) {
        [self addRowWithFaCode:@"fa-user"
                         value:self.result.profile.displayName];
        if (![MCTUtils isEmptyOrWhitespaceString:self.result.profile.preferred_locale]) {
            [self addRowWithFaCode:@"fa-flag"
                             value:self.result.profile.displayLanguage];
        }
        if (![MCTUtils isEmptyOrWhitespaceString:self.result.profile.born_on]) {
            [self addRowWithFaCode:@"fa-birthday-cake"
                             value:[self stringFromDateString:self.result.profile.born_on]];
        }
    }
    if ([self.scopes containsObject:SCOPE_ADDRESS]) {
        [self addRowWithFaCode:@"fa-home"
                         value:self.result.address.displayValue];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    T_UI();
    self.authenticateBtn.enabled = enabled;
    [super setEnabled:enabled];
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];

    assert(self.authenticateBtn || self.resultTableView);

    CGFloat widgetWidth = self.width;
    if (self.authenticateBtn) {
        CGSize s1 = [MCTUIUtils sizeForTTButton:self.authenticateBtn constrainedToSize:CGSizeMake(widgetWidth, 126)];
        CGRect frame1 = CGRectMake(0, MARGIN, widgetWidth, MAX(88, s1.height));
        self.authenticateBtn.frame = frame1;
        self.authenticateBtn.centerX = self.width / 2;

        UIImageView *mdpImageView = [self.authenticateBtn viewWithTag:MCT_TAG_MDP_IMAGE_VIEW];
        mdpImageView.centerY = self.authenticateBtn.height / 2;
        mdpImageView.left = mdpImageView.top;
    } else {
        if (self.imageView != nil) {
            CGFloat imgHeight = fminf(100.0, self.imageView.image.size.height);
            CGFloat imgWidth = imgHeight * self.imageView.image.size.width / self.imageView.image.size.height;
            self.imageView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
            self.imageView.centerX = self.width / 2;
            self.imageView.backgroundColor = [UIColor redColor];
        }

        CGFloat h = 0;
        NSUInteger rowCount = [self tableView:self.resultTableView numberOfRowsInSection:0];
        for (NSInteger i = 0; i < rowCount; i++) {
            h += [self tableView:self.resultTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i
                                                                                                 inSection:1]];
        }
        CGRect frame1 = CGRectMake(0, self.imageView.bottom + MARGIN, widgetWidth, h);
        self.resultTableView.frame = frame1;
        self.resultTableView.centerX = self.width / 2;
    }
}


#pragma mark -

- (void)showErrorPleaseRetryAlert
{
    T_UI();
    self.viewController.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
    self.viewController.currentAlertView.delegate = self;
}

- (void)showProgressHUDWithText:(NSString *)text
{
    T_UI();
    MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *vc = self.viewController;
    UIView *view = vc.navigationController ? vc.navigationController.view : vc.view;
    vc.currentProgressHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:vc.currentProgressHUD];
    vc.currentProgressHUD.labelText = text;
    vc.currentProgressHUD.mode = MBProgressHUDModeIndeterminate;
    vc.currentProgressHUD.dimBackground = YES;
    [vc.currentProgressHUD show:YES];
}

- (void)hideProgressHUD
{
    T_UI();
    MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *vc = self.viewController;
    [vc.currentProgressHUD hide:YES];
    [vc.currentProgressHUD removeFromSuperview];
    MCT_RELEASE(vc.currentProgressHUD);
}

- (void)onAuthenticateButtonTapped:(id)sender
{
    T_UI();
    HERE();
    MCTUIViewController<UIAlertViewDelegate, UIActionSheetDelegate> *vc = self.viewController;

    if (![MCTUtils connectedToInternet]) {
        vc.currentAlertView = [MCTUIUtils showNetworkErrorAlert];
        vc.currentAlertView.delegate = self;
        return;
    }

    if (![[MDPMobile sharedSession] isMdpInstalled]) {
        vc.currentAlertView = [[UIAlertView alloc] initWithTitle:@"MYDIGIPASS"
                                                          message:NSLocalizedString(@"Please install MYDIGIPASS Authenticator for Mobile before proceeding.", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                otherButtonTitles:NSLocalizedString(@"Install", nil), nil];
        vc.currentAlertView.tag = MCT_TAG_INSTALL_MDP;
        [vc.currentAlertView show];
        return;
    }

    [self authorizeMDP];
}

- (void)authorizeMDP
{
    T_UI();
    self.currentState = nil;
    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_MDP_LOGIN
                                                            onQueue:[MCTComponentFramework mainQueue]];

    [self showProgressHUDWithText:NSLocalizedString(@"Processing ...", nil)];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_MDP_SESSION_INIT]];
    MCTHTTPRequest *request = [[MCTHTTPRequest alloc] initWithURL:url];
    __weak typeof(request) weakHttpRequest = request;
    request.shouldRedirect = YES;
    [request addRequestHeader:@"X-MCTracker-User"
                        value:[[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_USERNAME] MCTBase64Encode]];
    [request addRequestHeader:@"X-MCTracker-Pass"
                        value:[[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_PASSWORD] MCTBase64Encode]];
    [request setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [request setFailedBlock:^{
        T_UI();
        [self hideProgressHUD];
        [self showErrorPleaseRetryAlert];
    }];
    [request setCompletionBlock:^{
        T_UI();
        [self hideProgressHUD];

        if (request.responseStatusCode != 200) {
            ERROR(@"Failed to get MDP clientId. Status code: %d", weakHttpRequest.responseStatusCode);
            [self showErrorPleaseRetryAlert];
            return;
        }

        NSDictionary *result = [weakHttpRequest.responseString MCT_JSONValue];
        if (![self handleError:result]) {
            self.currentState = result[@"state"];

            [MDPMobile setSharedSessionRedirectUri:[NSString stringWithFormat:@"mdp-%@://x-callback-url/mdp_callback", MCT_PRODUCT_ID]
                                          clientId:result[@"client_id"]];
            [[MDPMobile sharedSession] authenticateWithState:result[@"state"]
                                                       scope:[self.scopes componentsJoinedByString:@" "]
                                               andParameters:nil];
        }
    }];
    [[MCTComponentFramework workQueue] addOperation:request];
}

- (void)mdpAuthorizedWithState:(NSString *)state code:(NSString *)code
{
    T_UI();
    [self showProgressHUDWithText:NSLocalizedString(@"Processing ...", nil)];


    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", MCT_HTTPS_BASE_URL, MCT_MDP_SESSION_AUTHORIZED]];
    MCTFormDataRequest *request = [[MCTFormDataRequest alloc] initWithURL:url];
    __weak typeof(request) weakHttpRequest = request;
    request.shouldRedirect = YES;
    [request setPostValue:[self.scopes componentsJoinedByString:@" "]
                   forKey:@"scope"];
    [request setPostValue:state forKey:@"state"];
    [request setPostValue:code forKey:@"authorization_code"];
    [request addRequestHeader:@"X-MCTracker-User"
                        value:[[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_USERNAME] MCTBase64Encode]];
    [request addRequestHeader:@"X-MCTracker-Pass"
                        value:[[[MCTComponentFramework configProvider] stringForKey:MCT_CONFIGKEY_PASSWORD] MCTBase64Encode]];
    [request setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [request setFailedBlock:^{
        T_UI();
        [self hideProgressHUD];
        [self showErrorPleaseRetryAlert];
    }];
    [request setCompletionBlock:^{
        T_UI();
        [self hideProgressHUD];

        if (request.responseStatusCode != 200) {
            [self showErrorPleaseRetryAlert];
            return;
        }

        @try {
            NSDictionary *result = [weakHttpRequest.responseString MCT_JSONValue];
            if (![self handleError:result]) {
                self.result = [MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO transferObjectWithDict:result];
                [self.authenticateBtn removeFromSuperview];
                MCT_RELEASE(self.authenticateBtn);
                [self createResultTableView];
                [self refreshView];
            }
        }
        @catch (NSException *exception) {
            [MCTSystemPlugin logError:exception withMessage:@"Failed to parse MDP authentication result"];
            [self showErrorPleaseRetryAlert];
        }
    }];
    [[MCTComponentFramework workQueue] addOperation:request];
}

- (BOOL)handleError:(NSDictionary *)result
{
    T_UI();
    if (result == nil) {
        // No JSON could be parsed
        [self showErrorPleaseRetryAlert];
        return YES;
    }

    NSString *error = [result stringForKey:@"error" withDefaultValue:nil];
    if (![MCTUtils isEmptyOrWhitespaceString:error]) {
        if ([result boolForKey:@"mdp_update_required" withDefaultValue:NO]) {
            self.viewController.currentAlertView = [[UIAlertView alloc] initWithTitle:@"MYDIGIPASS"
                                                                               message:error
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                                     otherButtonTitles:NSLocalizedString(@"Update", nil), nil];
            self.viewController.currentAlertView.tag = MCT_TAG_INSTALL_MDP;
            [self.viewController.currentAlertView show];
        } else {
            self.viewController.currentAlertView = [MCTUIUtils showErrorAlertWithText:error];
            self.viewController.currentAlertView.delegate = self;
        }
        return YES;
    }

    return NO;
}

- (void)refreshView
{
    T_UI();
    MCTFormView *formView = (MCTFormView *) [MCTUIUtils superViewWithClass:[MCTFormView class]
                                                                   forView:self];
    MCTMessageDetailView *msgDetailView = (MCTMessageDetailView *) [MCTUIUtils superViewWithClass:[MCTMessageDetailView class]
                                                                                          forView:self];
    if (!formView || !msgDetailView) {
        @throw [NSException exceptionWithName:@"Did not find MCTFormView/MCTMessageDetailView in view hierarchy!"
                                       reason:nil
                                     userInfo:nil];
    }
    [formView layoutSubviews];
    [msgDetailView setNeedsLayout];
}

#pragma mark - MCTWidget

- (CGFloat)height
{
    T_UI();
    return OR(self.resultTableView, self.authenticateBtn).bottom + MARGIN;
}

- (NSDictionary *)widget
{
    [self.widgetDict setValue:[self.result dictRepresentation] forKey:@"value"];
    return self.widgetDict;
}

+ (NSString *)valueStringForWidget:(NSDictionary *)widgetDict
{
    T_UI();
    NSDictionary *result = widgetDict[@"value"];
    if (result) {
        MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO *resultTO =
            [MCT_com_mobicage_to_messaging_forms_MyDigiPassWidgetResultTO transferObjectWithDict:result];

        NSMutableArray *stringBuilder = [NSMutableArray array];
        if (resultTO.email) {
            [stringBuilder addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"E-mail", nil),
                                      resultTO.email]];
        }
        if (resultTO.phone) {
            [stringBuilder addObject:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Phone", nil),
                                      resultTO.phone]];
        }
        if (resultTO.address) {
            [stringBuilder addObject:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Address", nil),
                                      [resultTO.address.displayValue stringByReplacingOccurrencesOfString:@"\n"
                                                                                               withString:@", "]]];
        }
        if (resultTO.profile) {
            [stringBuilder addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Profile", nil),
                                      resultTO.profile.displayValue]];
        }
        if (resultTO.eid_address) {
            [stringBuilder addObject:[NSString stringWithFormat:@"eID %@: %@", NSLocalizedString(@"Address", nil),
                                      [resultTO.eid_address.displayValue stringByReplacingOccurrencesOfString:@"\n"
                                                                                                   withString:@", "]]];
        }
        if (resultTO.eid_profile) {
            [stringBuilder addObject:[NSString stringWithFormat:@"eID %@: %@", NSLocalizedString(@"Profile", nil),
                                      resultTO.eid_profile.displayValue]];
        }
        if (resultTO.eid_photo) {
            [stringBuilder addObject:[NSString stringWithFormat:@"eID %@", NSLocalizedString(@"Photo", nil)]];
        }

        return [stringBuilder componentsJoinedByString:@"\n"];
    }
    return @"";
}

- (id)toBeShownBeforeSubmitWithPositiveButton:(BOOL)isPositiveButton
{
    if (isPositiveButton && self.result == nil) {
        return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not authenticated", nil)
                                           message:NSLocalizedString(@"You need to authenticate before you can continue.", nil)
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                 otherButtonTitles:[self.authenticateBtn titleForState:UIControlStateNormal], nil];
    }

    return nil;
}

- (void)beforeSubmitAlertView:(UIAlertView *)alertView
      answeredWithButtonIndex:(NSInteger)buttonIndex
               submitCallback:(void (^)(void))submitForm
{
    T_UI();
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self onAuthenticateButtonTapped:nil];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    T_UI();
    if (alertView == self.viewController.currentAlertView) {
        MCT_RELEASE(self.viewController.currentAlertView);
    }

    if (alertView.tag == MCT_TAG_INSTALL_MDP) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[MDPMobile sharedSession] installMdp];
        }
    }
}


#pragma mark - UITableViewDataSource / UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    CGFloat h;
    if (self.collapsed && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        h = 0; // "Show more..." cell
    } else {
        MCTMyDigiPassRow *mdpRow = self.tableViewData[indexPath.row];
        if (self.dummyCell == nil) {
            self.dummyCell = [[MCTMdpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            self.dummyCell.size = CGSizeMake(self.width, ROW_HEIGHT);
            self.dummyCell.textLabel.superview.size = self.dummyCell.size;
            self.dummyCell.imageView.image = [UIImage imageWithIcon:@"fa-glass"
                                                    backgroundColor:[UIColor clearColor]
                                                          iconColor:[UIColor grayColor]
                                                            andSize:CGSizeMake(40, 20)];
            self.dummyCell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            self.dummyCell.textLabel.numberOfLines = 0;
            [self.dummyCell layoutSubviews];
        };
        self.dummyCell.textLabel.text = mdpRow.value;
        h = 18 + [MCTUIUtils sizeForLabel:self.dummyCell.textLabel].height;
    }
    return MAX(ROW_HEIGHT, h);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    T_UI();
    if (self.collapsed) {
        return MIN(MAX_COLLAPSED_CELLS, [self.tableViewData count]);
    }
    return [self.tableViewData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    MCTMyDigiPassRow *mdpRow = self.tableViewData[indexPath.row];
    BOOL isMore = self.collapsed && [self.tableViewData count] > MAX_COLLAPSED_CELLS && indexPath.row == MAX_COLLAPSED_CELLS - 1;
    NSString *identifier;
    if (isMore) {
        identifier = @"more";
    } else {
        identifier = @"normal";
    }

    MCTMdpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MCTMdpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeCenter;
    }

    if (isMore) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = NSLocalizedString(@"Show more...", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = OR(MCT_APP_TINT_COLOR, RGBCOLOR(3, 122, 255));
    } else {
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.text = mdpRow.value;
        cell.textLabel.numberOfLines = ([mdpRow.value numberOfLines] == 1) ? 1 : 0;
        UIImage *image = [UIImage imageWithIcon:mdpRow.faCode
                                backgroundColor:[UIColor clearColor]
                                      iconColor:[UIColor grayColor]
                                        andSize:CGSizeMake(40, 20)];
        cell.imageView.image = image;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    cell.separatorInset = UIEdgeInsetsZero;
    IF_IOS8_OR_GREATER({
        cell.layoutMargins = UIEdgeInsetsZero;
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    T_UI();
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.collapsed && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        self.collapsed = NO;
        [tableView reloadData];
        [self refreshView];
    }
}

# pragma mark - MCTIntent

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_MDP_LOGIN) {
        NSString *state = [intent stringForKey:@"state"];
        if (![state isEqualToString:self.currentState]) {
            LOG(@"MDP state mismatch. Expected %@. Got %@", self.currentState, state);
            return;
        }

        [[MCTComponentFramework intentFramework] unregisterIntentListener:self
                                                          forIntentAction:intent.action];

        // Example results
        // {"error" : "redirect_uri_mismatch",
        //  "error_description" : "Parameter identifier does not match the redirect_uri",
        //  "state" : "d1d87de1-8d97-40db-b535-94fd90132963"}
        // {"code" : "5hbjy4nop99yri0zvw1gzltsj",
        //  "identifier" : "com.mobicage.rogerthat",
        //  "redirect_uri" : "mdp-rogerthat://x-callback-url/mdp_callback",
        //  "state" : "4d47e8ee-5740-401d-8424-87e1b18728e4"}

        if ([intent hasStringKey:@"error"]) {
            [self showErrorPleaseRetryAlert];
        } else {
            [self mdpAuthorizedWithState:state
                                    code:[intent stringForKey:@"code"]];
        }
    }
}

@end