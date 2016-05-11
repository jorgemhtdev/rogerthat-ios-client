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

#import "MCTMenuVC.h"
#import "Three20UI+Additions.h"

@interface MCTHomeScreenItem : NSObject

@property(nonatomic, assign) MCTlong x;
@property(nonatomic, assign) MCTlong y;
@property(nonatomic, copy) NSString *label;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) NSString *click;
@property(nonatomic, strong) NSArray *coords;
@property(nonatomic, assign) BOOL collapse;

+ (MCTHomeScreenItem *)homeScreenItemWithPositionY:(MCTlong)y
                                                 x:(MCTlong)x
                                             label:(NSString *)label
                                             click:(NSString *)click
                                            coords:(NSArray *)coords
                                          collapse:(BOOL)collapse;

@end

@interface MCTAbstractHomeScreenVC : MCTMenuVC <UIScrollViewDelegate> {
    UIScrollView *scrollView_;
    UILabel *myQrDescriptionLbl_;
    UIImageView *myQrImageView_;
    UIActivityIndicatorView *myQrSpinner_;
    TTButton *myQrBackBtn_;
    UIImageView *homescreenHeader_;
    UIImageView *homescreenFooter_;
    UIControl *mainControl_;
    NSString *context_;
    TTLabel *badgeView_;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *myQrDescriptionLbl;
@property (nonatomic, strong) UIImageView *myQrImageView;
@property (nonatomic, strong) UIActivityIndicatorView *myQrSpinner;
@property (nonatomic, strong) TTButton *myQrBackBtn;
@property (nonatomic, strong) IBOutlet UIImageView *homescreenHeader;
@property (nonatomic, strong) IBOutlet UIImageView *homescreenFooter;
@property (nonatomic, strong) IBOutlet UIControl *mainControl;
@property (nonatomic, copy) NSString *context;
@property (nonatomic, strong) IBOutlet TTLabel *badgeView;

- (IBAction)onIconTapped:(id)sender;

@end