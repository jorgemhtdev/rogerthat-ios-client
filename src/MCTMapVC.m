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
#import "MCTLocationPlugin.h"
#import "MCTMapVC.h"
#import "MCTUtils.h"
#import "MCTUIUtils.h"

#define MCT_HOUR 3600
#define MCT_MINUTE 60

@implementation MCTMapVC


+ (MCTMapVC *)viewController
{
    return [[MCTMapVC alloc] initWithNibName:@"map" bundle:nil];
}

- (void)viewDidLoad {
    T_UI();
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] applicationFrame];

    [[MCTComponentFramework intentFramework] registerIntentListener:self
                                                    forIntentAction:kINTENT_LOCATION_RETRIEVED
                                                            onQueue:[MCTComponentFramework mainQueue]];
    [self poll];

    self.timestampLabel.text = NSLocalizedString(@"Last update\n0s ago", nil);
    self.timestampLabel.font = [UIFont systemFontOfSize:14];

    // Replace UIButtons with TTButtons
    TTButton *ttBtn = [TTButton buttonWithStyle:MCT_STYLE_EMBOSSED_BUTTON
                                              title:NSLocalizedString(@"Refresh", nil)];
    [ttBtn addTarget:self action:@selector(poll) forControlEvents:UIControlEventTouchUpInside];
    ttBtn.frame = self.refreshButton.frame;
    ttBtn.height += 5;
    [self.refreshButton.superview addSubview:ttBtn];
    [self.refreshButton removeFromSuperview];
    self.refreshButton = ttBtn;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(updateTimestamp:)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer fire];
}

- (void)updateTimestamp:(id)timer
{
    T_UI();
    MCTlong secsAgo = ([MCTUtils currentTimeMillis] / 1000) - self.timestamp;

    NSMutableArray *time = [NSMutableArray array];
    if (secsAgo > MCT_HOUR)
        [time addObject:[NSString stringWithFormat:@"%dh", (int) (secsAgo / MCT_HOUR)]];

    if (secsAgo > MCT_MINUTE)
        [time addObject:[NSString stringWithFormat:@"%dm", (int)((secsAgo % MCT_HOUR) / MCT_MINUTE)]];

    [time addObject:[NSString stringWithFormat:@"%ds", (int)(secsAgo % MCT_MINUTE)]];

    NSString *ago = [time componentsJoinedByString:@" "];

    self.timestampLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last update\n%@ ago", nil), ago];
}

- (IBAction)poll
{
    T_UI();
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];

    self.timestamp = [MCTUtils currentTimeMillis] / 1000;

    MCTLocationPlugin *plugin = [MCTComponentFramework locationPlugin];
    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [plugin requestLocationOfAllFriends];
    }];

    [[MCTComponentFramework workQueue] addOperationWithBlock:^{
        T_BIZZ();
        [plugin requestMyLocationWithGPS:NO];
    }];
}

- (void)onIntent:(MCTIntent *)intent
{
    T_UI();
    if (intent.action == kINTENT_LOCATION_RETRIEVED) {
        NSString *friendEmail = [intent stringForKey:@"friend"];
        CLLocationAccuracy accuracy = [intent longForKey:@"accuracy"];
        CLLocationDegrees latitude = (double)[intent longForKey:@"latitude"] / MCT_LOCATION_FACTOR;
        CLLocationDegrees longitude = (double)[intent longForKey:@"longitude"] / MCT_LOCATION_FACTOR;
        MCTlong timestamp = [intent longForKey:@"timestamp"];

        CLLocationCoordinate2D coordinate = {.latitude = latitude, .longitude = longitude};
        CLLocation *loc = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:-1
                                               horizontalAccuracy:accuracy
                                                 verticalAccuracy:-1
                                                        timestamp:[NSDate dateWithTimeIntervalSince1970:timestamp]];
        [self addAnnotationWithFriend:friendEmail andLocation:loc];
    }
}

@end