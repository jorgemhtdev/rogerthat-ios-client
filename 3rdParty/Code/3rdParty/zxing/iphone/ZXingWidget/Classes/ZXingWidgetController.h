/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include "Decoder.h"
#include "parsedResults/ParsedResult.h"
#include "OverlayView.h"

@protocol ZXingDelegate;

#if !TARGET_IPHONE_SIMULATOR
#define HAS_AVFF 1
#endif

@interface ZXingWidgetController : UIViewController<DecoderDelegate,
                                                    CancelDelegate,
                                                    UINavigationControllerDelegate
#if HAS_AVFF
                                                    , AVCaptureVideoDataOutputSampleBufferDelegate
#endif
                                                    > {
  NSSet *readers;
  ParsedResult *result;
  OverlayView *overlayView;
  SystemSoundID beepSound;
  BOOL showCancel;
  NSURL *soundToPlay;
  id<ZXingDelegate> delegate;
  BOOL wasCancelled;
  BOOL oneDMode;
#if HAS_AVFF
  AVCaptureSession *captureSession;
  AVCaptureVideoPreviewLayer *prevLayer;
#endif
  BOOL decoding;
  BOOL isBackCamera_;
  BOOL justScan_;
  CGRect scanFrame_;
  BOOL smallPreview_;
  BOOL handleOrientation_;
}

#if HAS_AVFF
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;
#endif
@property (nonatomic, retain ) NSSet *readers;
@property (nonatomic, weak) id<ZXingDelegate> delegate;
@property (nonatomic, strong) NSURL *soundToPlay;
@property (nonatomic, strong) ParsedResult *result;
@property (nonatomic, strong) OverlayView *overlayView;

- (id)initWithDelegate:(id<ZXingDelegate>)delegate
            showCancel:(BOOL)shouldShowCancel
              OneDMode:(BOOL)shouldUseoOneDMode
     handleOrientation:(BOOL)handleOrientation;
- (id)initWithDelegate:(id<ZXingDelegate>)delegate
            showCancel:(BOOL)shouldShowCancel
              OneDMode:(BOOL)shouldUseoOneDMode
      andUserTextLine1:(NSString *)userTextLine1
      andUserTextLine2:(NSString *)userTextLine2
   andCancelButtonText:(NSString *)cancelButtonText
     handleOrientation:(BOOL)handleOrientation;
- (id)initWithDelegate:(id<ZXingDelegate>)scanDelegate frame:(CGRect)frame isBackCamera:(BOOL)isBackCamera;

- (BOOL)fixedFocus;
- (BOOL)updatePreviewSize;
@end

@protocol ZXingDelegate
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result;
- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller;
@end
