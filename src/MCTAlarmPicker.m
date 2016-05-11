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

#import <AVFoundation/AVFoundation.h>

#import "MCTAlarmPicker.h"
#import "MCTComponentFramework.h"
#import "MCTIntent.h"
#import "MCTSettingsVC.h"
#import "MCTUIUtils.h"
#import "MCTUtils.h"

#import "TSLibraryImport.h"


@interface MCTAlarmPicker ()

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString *)title andArtist:(NSString *)artist;
- (void)showActionSheetWithTitle:(NSString *)title;

@end


@implementation MCTAlarmPicker


- (id)initWithViewController:(MCTUIViewController *)vc
{
    T_UI();
    if (self = [super init]) {
        self.viewController = vc;
    }
    return self;
}

- (void)pickAlarm
{
    T_UI();
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    if (mediaPicker) {
        mediaPicker.delegate = self;

        [self.viewController presentViewController:mediaPicker animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:MCT_NOTIFICATION_BACKGROUND
                                                   object:nil];
    }
}

- (void)didEnterBackground
{
    T_UI();
    [self hideMediaPickerAnimated:NO];
}

- (void)hideMediaPickerAnimated:(BOOL)animated
{
    T_UI();
    [self.viewController dismissViewControllerAnimated:animated completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCT_NOTIFICATION_BACKGROUND object:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    T_UI();
	[self hideMediaPickerAnimated:YES];

	MPMediaItem *item = [mediaItemCollection.items objectAtIndex:0];

    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];

    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    if (assetURL == nil) {
        LOG(@"MPMediaItemPropertyAssetURL is nil, this typically means the file in question is protected by DRM. (old m4p files)");
        self.viewController.currentAlertView = [MCTUIUtils showErrorAlertWithText:NSLocalizedString(@"The format of the selected song is not supported. Please try again.", nil)];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showActionSheetWithTitle:NSLocalizedString(@"Importing ...", nil)];
    });

    [self exportAssetAtURL:assetURL withTitle:title andArtist:artist];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    T_UI();
	[self hideMediaPickerAnimated:YES];
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString *)title andArtist:(NSString *)artist
{
    T_UI();
	NSString *ext = [TSLibraryImport extensionForAssetURL:assetURL];
	NSString *alarmFolder = [[MCTUtils documentsFolder] stringByAppendingPathComponent:@"alarm"];
    NSString *alarmFile = [[alarmFolder stringByAppendingPathComponent:@"alarm"] stringByAppendingPathExtension:ext];
	NSURL *outURL = [NSURL fileURLWithPath:alarmFile];

	// We're responsible for making sure the destination url doesn't already exist
	[[NSFileManager defaultManager] removeItemAtPath:alarmFolder error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:alarmFolder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

	// create the import object
	TSLibraryImport *import = [[TSLibraryImport alloc] init];

    @try {
        [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport *import) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // TODO: is this safe?
                MCT_RELEASE(self.viewController.currentActionSheet);
            });

            if (import.status == AVAssetExportSessionStatusCompleted) {
                NSString *alarmTitle = nil;
                if (artist && title)
                    alarmTitle = [NSString stringWithFormat:@"%@ - %@", artist, title];
                else if (title)
                    alarmTitle = title;
                else if (artist)
                    alarmTitle = artist;
                else
                    alarmTitle = @"";

                [[NSUserDefaults standardUserDefaults] setValue:alarmTitle forKey:MCT_SETTINGS_CUSTOM_ALARM];

                MCTIntent * intent = [MCTIntent intentWithAction:kINTENT_NEW_ALARM_SOUND];
                [intent setString:alarmFile forKey:@"file"];
                [[MCTComponentFramework intentFramework] broadcastIntent:intent];
            } else {
                ERROR(@"%@", import.error);
                self.viewController.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
            }
        }];
    }
    @catch (NSException * e) {
        [MCTSystemPlugin logError:e withMessage:nil];
        self.viewController.currentAlertView = [MCTUIUtils showErrorPleaseRetryAlert];
    }
}

#pragma mark -
#pragma mark UIActionSheet

- (void)showActionSheetWithTitle:(NSString *)title
{
    T_UI();
    if (self.viewController.currentActionSheet == nil) {
        self.viewController.currentActionSheet = [MCTUIUtils showActivityActionSheetWithTitle:title inViewController:self.viewController];
    } else {
        self.viewController.currentActionSheet.title = title;
    }
}

@end