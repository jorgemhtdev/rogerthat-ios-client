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

#import "MCTDiscoveredFriendCell.h"
#import "MCTUIUtils.h"


@implementation MCTDiscoveredFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    T_UI();
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.ttImageView = [[TTImageView alloc] init];
        self.ttImageView.defaultImage = [UIImage imageNamed:MCT_UNKNOWN_AVATAR];
        self.ttImageView.delegate = self;
        [self.contentView addSubview:self.ttImageView];
        [MCTUIUtils addRoundedBorderToView:self.ttImageView];

        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    T_UI();
    [super layoutSubviews];
    CGFloat M = 5; // margin

    self.ttImageView.left = M;
    self.ttImageView.top = M;
    self.ttImageView.height = self.contentView.height - 2 * self.ttImageView.top;
    self.ttImageView.width = self.ttImageView.height;

    self.textLabel.left = self.ttImageView.right + M;
    self.textLabel.width = self.contentView.right - self.textLabel.left - M;
    self.textLabel.height = self.ttImageView.height;
    self.textLabel.top = self.ttImageView.top;
}

- (void)setName:(NSString *)name
{
    T_UI();
    self.textLabel.text = name;
}

- (void)setPicture:(NSString *)picture
{
    T_UI();
    self.ttImageView.urlPath = picture;
}

#pragma mark -
#pragma mark TTImageViewDelegate

- (void)imageViewDidStartLoad:(TTImageView*)imageView
{
    T_UI();
    HERE();
}

- (void)imageView:(TTImageView*)imageView didLoadImage:(UIImage*)image
{
    T_UI();
    HERE();
}

- (void)imageView:(TTImageView*)imageView didFailLoadWithError:(NSError*)error
{
    T_UI();
    HERE();

}

- (void)imageView:(TTImageView*)imageView willSendARequest:(TTURLRequest*)requester
{
    T_UI();
    HERE();
}

@end