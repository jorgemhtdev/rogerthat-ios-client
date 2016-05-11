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

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "MCTUIViewController.h"
#import "MCTIntentFramework.h"

@interface MCTServiceSearchVC : MCTUIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,
IMCTIntentReceiver, CLLocationManagerDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIScrollView *headerView;
@property (nonatomic, strong) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet UIView *indicatorView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *spinnerLabel;
@property (nonatomic) MCTServiceOrganizationType organizationType;
@property (nonatomic, copy) NSString *automaticSearchString;

+ (MCTServiceSearchVC *)viewController;

@end