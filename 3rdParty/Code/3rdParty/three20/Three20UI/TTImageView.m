//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTImageView.h"

// UI
#import "TTImageViewDelegate.h"

// UI (private)
#import "TTImageLayer.h"
#import "TTImageViewInternal.h"

// Style
#import "TTShape.h"
#import "TTStyleContext.h"
#import "TTContentStyle.h"
#import "UIImageAdditions.h"

// Network
#import "TTURLCache.h"
#import "TTURLImageResponse.h"
#import "TTURLRequest.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTImageView

@synthesize urlPath             = _urlPath;
@synthesize image               = _image;
@synthesize defaultImage        = _defaultImage;
@synthesize autoresizesToImage  = _autoresizesToImage;
@synthesize request				= _request;

@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    _autoresizesToImage = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_request cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (Class)layerClass {
  return [TTImageLayer class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  if (self.style) {
    [super drawRect:rect];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawContent:(CGRect)rect {
  if (nil != _image) {
    [_image drawInRect:rect contentMode:self.contentMode];

  } else {
    [_defaultImage drawInRect:rect contentMode:self.contentMode];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {

  _request = request;

  [self imageViewDidStartLoad];
  if ([_delegate respondsToSelector:@selector(imageViewDidStartLoad:)]) {
    [_delegate imageViewDidStartLoad:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  [self setImage:response.image];

  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);

  [self imageViewDidFailLoadWithError:error];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:error];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);

  [self imageViewDidFailLoadWithError:nil];
  if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [_delegate imageView:self didFailLoadWithError:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
  if ([style isKindOfClass:[TTContentStyle class]]) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGRect rect = context.frame;
    [context.shape addToPath:rect];
    CGContextClip(ctx);

    [self drawContent:rect];

    CGContextRestoreGState(ctx);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_request;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return nil != _image && _image != _defaultImage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  if (nil == _request && nil != _urlPath) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_urlPath];

    if (nil != image) {
      self.image = image;

    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
        request.response = [[TTURLImageResponse alloc] init];

      // Give the delegate one chance to configure the requester.
      if ([_delegate respondsToSelector:@selector(imageView:willSendARequest:)]) {
    	  [_delegate imageView:self willSendARequest:request];
      }

      if (![request send]) {
        // Put the default image in place while waiting for the request to load
        if (_defaultImage && nil == self.image) {
          self.image = _defaultImage;
        }
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoading {
  [_request cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidStartLoad {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidLoadImage:(UIImage*)image {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidFailLoadWithError:(NSError*)error {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetImage {
  [self stopLoading];
  self.image = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDefaultImage:(UIImage*)theDefaultImage {
  if (_defaultImage != theDefaultImage) {
      _defaultImage = theDefaultImage;
  }
  if (nil == _urlPath || 0 == _urlPath.length) {
    //no url path set yet, so use it as the current image
    self.image = _defaultImage;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUrlPath:(NSString*)urlPath {
  // Check for no changes.
  if (nil != _image && nil != _urlPath && [urlPath isEqualToString:_urlPath]) {
    return;
  }

  [self stopLoading];

  _urlPath = urlPath;

  if (nil == _urlPath || 0 == _urlPath.length) {
    // Setting the url path to an empty/nil path, so let's restore the default image.
    self.image = _defaultImage;

  } else {
    [self reload];
  }
}


@end
