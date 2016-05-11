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

#import "MCTActivity.h"
#import "MCTFriendsPlugin.h"

@interface MCTActivityCell : UITableViewCell 

@property (nonatomic, strong) MCTActivity *activity;
@property (nonatomic, strong) IBOutlet UIView *separatorView;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIView *iconOverlayView;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIView *detailView;

- (id)initWithReuseIdentifier:(NSString *)ident;

- (void)addOverlayImage:(UIImage *)img;

@end

#pragma mark -

@interface MCTActivityCellFactory : NSObject {
    MCTFriendsPlugin *friendsPlugin_;
}

+ (MCTActivityCell *)tableView:(UITableView *)tableView cellForActivity:(MCTActivity *)activity;
+ (UIImage *)iconImageForActivity:(MCTActivity *)activity;
+ (UIImage *)iconOverlayForActivity:(MCTActivity *)activity;
+ (NSString *)friendDisplayNameForActivity:(MCTActivity *)activity;

@end