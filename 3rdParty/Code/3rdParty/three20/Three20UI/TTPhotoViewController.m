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

#import "TTPhotoViewController.h"

// UI
#import "TTNavigator.h"
#import "TTThumbsViewController.h"
#import "TTNavigationController.h"
#import "TTPhotoSource.h"
#import "TTPhoto.h"
#import "TTPhotoView.h"
#import "TTActivityLabel.h"
#import "TTScrollView.h"
#import "UIViewAdditions.h"
#import "UINavigationControllerAdditions.h"
#import "UIToolbarAdditions.h"

// UINavigator
#import "TTGlobalNavigatorMetrics.h"
#import "TTURLObject.h"
#import "TTURLMap.h"
#import "TTBaseNavigationController.h"

// UICommon
#import "TTGlobalUICommon.h"
#import "UIViewControllerAdditions.h"

// Style
#import "TTGlobalStyle.h"
#import "TTDefaultStyleSheet.h"

// Network
#import "TTGlobalNetwork.h"
#import "TTURLCache.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCoreLocale.h"

static const NSTimeInterval kPhotoLoadLongDelay   = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay  = 0.25;
static const NSTimeInterval kSlideshowInterval    = 2;
static const NSInteger kActivityLabelTag          = 96;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTPhotoViewController

@synthesize centerPhoto       = _centerPhoto;
@synthesize centerPhotoIndex  = _centerPhotoIndex;
@synthesize defaultImage      = _defaultImage;
@synthesize captionStyle      = _captionStyle;
@synthesize photoSource       = _photoSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc]
        initWithTitle:
        TTLocalizedString(@"Photo",
                          @"Title for back button that returns to photo browser")
        style: UIBarButtonItemStylePlain
        target: nil
        action: nil];

    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;

    self.defaultImage = TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPhoto:(id<TTPhoto>)photo {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
    self.centerPhoto = photo;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
    self.photoSource = photoSource;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _thumbsController.delegate = nil;
  TT_INVALIDATE_TIMER(_slideshowTimer);
  TT_INVALIDATE_TIMER(_loadTimer);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTPhotoView*)centerPhotoView {
  return (TTPhotoView*)_scrollView.centerPage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImageDelayed {
  _loadTimer = nil;
  [self.centerPhotoView loadImage];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startImageLoadTimer:(NSTimeInterval)delay {
  [_loadTimer invalidate];
  _loadTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                target:self
                                              selector:@selector(loadImageDelayed)
                                              userInfo:nil
                                               repeats:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelImageLoadTimer {
  [_loadTimer invalidate];
  _loadTimer = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImages {
  TTPhotoView* centerPhotoView = self.centerPhotoView;
  for (TTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    if (photoView == centerPhotoView) {
      [photoView loadPreview:NO];

    } else {
      [photoView loadPreview:YES];
    }
  }

  if (_delayLoad) {
    _delayLoad = NO;
    [self startImageLoadTimer:kPhotoLoadLongDelay];

  } else {
    [centerPhotoView loadImage];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateChrome {
  if (_photoSource.numberOfPhotos < 2) {
    self.title = _photoSource.title;

  } else {
    self.title = [NSString stringWithFormat:
                  TTLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"),
                  _centerPhotoIndex+1, _photoSource.numberOfPhotos];
  }

  if (![self.ttPreviousViewController isKindOfClass:[TTThumbsViewController class]]) {
    if (_photoSource.numberOfPhotos > 1) {
      self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"See All",
                                                                @"See all photo thumbnails")
                                        style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(showThumbnails)];

    } else {
      self.navigationItem.rightBarButtonItem = nil;
    }

  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }

  UIBarButtonItem* playButton = [_toolbar itemWithTag:1];
  playButton.enabled = _photoSource.numberOfPhotos > 1;
  _previousButton.enabled = _centerPhotoIndex > 0;
  _nextButton.enabled = _centerPhotoIndex >= 0 && _centerPhotoIndex < _photoSource.numberOfPhotos-1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  _toolbar.height = TTToolbarHeight();
  _toolbar.top = self.view.height - _toolbar.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePhotoView {
  _scrollView.centerPageIndex = _centerPhotoIndex;
  [self loadImages];
  [self updateChrome];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPhoto:(id<TTPhoto>)photo {
  id<TTPhoto> previousPhoto = _centerPhoto;
  _centerPhoto = photo;
  [self didMoveToPhoto:_centerPhoto fromPhoto:previousPhoto];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
  _centerPhotoIndex = photoIndex == TT_NULL_PHOTO_INDEX ? 0 : photoIndex;
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];
  _delayLoad = withDelay;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPhoto:(id<TTPhoto>)photo inView:(TTPhotoView*)photoView {
  photoView.photo = photo;
  if (!photoView.photo && _statusText) {
    [photoView showStatus:_statusText];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateVisiblePhotoViews {
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];

  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    TTPhotoView* photoView = [photoViews objectForKey:key];
    [photoView showProgress:-1];

    id<TTPhoto> photo = [_photoSource photoAtIndex:key.intValue];
    [self showPhoto:photo inView:photoView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (TTPhotoView* photoView in photoViews.objectEnumerator) {
    if (!photoView.isLoading) {
      [photoView showProgress:-1];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTPhotoView*)statusView {
  if (!_photoStatusView) {
    _photoStatusView = [[TTPhotoView alloc] initWithFrame:_scrollView.frame];
    _photoStatusView.defaultImage = _defaultImage;
    _photoStatusView.photo = nil;
    [_innerView addSubview:_photoStatusView];
  }

  return _photoStatusView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
  if ((self.hasViewAppeared || self.isViewAppearing) && progress >= 0 && !self.centerPhotoView) {
    [self.statusView showProgress:progress];
    self.statusView.hidden = NO;

  } else {
    _photoStatusView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)status {

    _statusText = status;

  if ((self.hasViewAppeared || self.isViewAppearing) && status && !self.centerPhotoView) {
    [self.statusView showStatus:status];
    self.statusView.hidden = NO;

  } else {
    _photoStatusView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCaptions:(BOOL)show {
  for (TTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    photoView.hidesCaption = !show;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForThumbnails {
  if ([self.photoSource respondsToSelector:@selector(URLValueWithName:)]) {
    return [self.photoSource performSelector:@selector(URLValueWithName:)
                                  withObject:@"TTThumbsViewController"];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showThumbnails {
  NSString* URL = [self URLForThumbnails];
  if (!_thumbsController) {
    if (URL) {
      // The photo source has a URL mapping in TTURLMap, so we use that to show the thumbs
      NSDictionary* query = [NSDictionary dictionaryWithObject:self forKey:@"delegate"];
      TTBaseNavigator* navigator = [TTBaseNavigator navigatorForView:self.view];
      _thumbsController = (TTThumbsViewController*)[navigator viewControllerForURL:URL
                                                                              query:query];
      [navigator.URLMap setObject:_thumbsController forURL:URL];

    } else {
      // The photo source had no URL mapping in TTURLMap, so we let the subclass show the thumbs
      _thumbsController = [self createThumbsViewController];
      _thumbsController.photoSource = _photoSource;
    }
  }

  if (URL) {
    TTOpenURLFromView(URL, self.view);

  } else {
    if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
      [(TTNavigationController*)self.navigationController
           pushViewController: _thumbsController
       animatedWithTransition: UIViewAnimationTransitionCurlDown];

    } else {
      [self.navigationController pushViewController:_thumbsController animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)slideshowTimer {
  if (_centerPhotoIndex == _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = 0;

  } else {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)playAction {
  if (!_slideshowTimer) {
    UIBarButtonItem* pauseButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause
                                                     target: self
                                                     action: @selector(pauseAction)];
    pauseButton.tag = 1;

    [_toolbar replaceItemWithTag:1 withItem:pauseButton];

    _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:kSlideshowInterval
                                                       target:self
                                                     selector:@selector(slideshowTimer)
                                                     userInfo:nil
                                                      repeats:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pauseAction {
  if (_slideshowTimer) {
    UIBarButtonItem* playButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                     target:self
                                                     action:@selector(playAction)];
    playButton.tag = 1;

    [_toolbar replaceItemWithTag:1 withItem:playButton];

    [_slideshowTimer invalidate];
    _slideshowTimer = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nextAction {
  [self pauseAction];
  if (_centerPhotoIndex < _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)previousAction {
  [self pauseAction];
  if (_centerPhotoIndex > 0) {
    _scrollView.centerPageIndex = _centerPhotoIndex-1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[UIView alloc] initWithFrame:screenFrame];

  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height);
  _innerView = [[UIView alloc] initWithFrame:innerFrame];
  _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_innerView];

  _scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.rotateEnabled = NO;
  _scrollView.backgroundColor = [UIColor blackColor];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [_innerView addSubview:_scrollView];

  _nextButton =
    [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://Three20.bundle/images/nextIcon.png")
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(nextAction)];
  _previousButton =
    [[UIBarButtonItem alloc] initWithImage:
     TTIMAGE(@"bundle://Three20.bundle/images/previousIcon.png")
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(previousAction)];

  UIBarButtonItem* playButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                   target:self
                                                   action:@selector(playAction)];
  playButton.tag = 1;

  UIBarItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                       UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

  _toolbar = [[UIToolbar alloc] initWithFrame:
              CGRectMake(0, screenFrame.size.height - TT_ROW_HEIGHT,
                         screenFrame.size.width, TT_ROW_HEIGHT)];
  if (self.navigationBarStyle == UIBarStyleDefault) {
    _toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
  }

  _toolbar.barStyle = self.navigationBarStyle;
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
  _toolbar.items = [NSArray arrayWithObjects:
                    space, _previousButton, space, _nextButton, space, nil];
  [_innerView addSubview:_toolbar];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_photoStatusView);
  TT_RELEASE_SAFELY(_nextButton);
  TT_RELEASE_SAFELY(_previousButton);
  TT_RELEASE_SAFELY(_toolbar);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateToolbarWithOrientation:self.interfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [_scrollView cancelTouches];
  [self pauseAction];
  if (self.nextViewController) {
    [self showBars:YES animated:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)rotatingFooterView {
  return _toolbar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [super showBars:show animated:animated];

  CGFloat alpha = show ? 1 : 0;
  if (alpha == _toolbar.alpha)
    return;

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    if (show) {
      [UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];

    } else {
      [UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
    }

  } else {
    if (show) {
      [self showBarsAnimationDidStop];

    } else {
      [self hideBarsAnimationDidStop];
    }
  }

  [self showCaptions:show];

  _toolbar.alpha = alpha;

  if (animated) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoad {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoadMore {
  return !_centerPhoto;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
  return _photoSource.numberOfPhotos > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
  [super didRefreshModel];
  [self updatePhotoView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
  [super didLoadModel:firstTime];
  if (firstTime) {
    [self updatePhotoView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
  [self showProgress:show ? 0 : -1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
  if (show) {
    [_scrollView reloadData];
    [self showStatus:TTLocalizedString(@"This photo set contains no photos.", @"")];

  } else {
    [self showStatus:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
  if (show) {
    [self showStatus:TTDescriptionForError(_modelError)];

  } else {
    [self showStatus:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToNextValidPhoto {
  if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
    // We were positioned at an index that is past the end, so move to the last photo
    [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];

  } else {
    [self moveToPhotoAtIndex:_centerPhotoIndex withDelay:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
      [self moveToNextValidPhoto];
      [_scrollView reloadData];
      [self resetVisiblePhotoViews];

    } else {
      [self updateVisiblePhotoViews];
    }
  }
  [super modelDidFinishLoad:model];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super model:model didFailLoadWithError:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    [self resetVisiblePhotoViews];
  }
  [super modelDidCancelLoad:model];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if (object == self.centerPhoto) {
    [self showActivity:nil];
    [self moveToNextValidPhoto];
    [_scrollView reloadData];
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView {
  [self cancelImageLoadTimer];
  [self showCaptions:NO];
  [self showBars:NO animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(TTScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillRotate:(TTScrollView*)scrollView
               toOrientation:(UIInterfaceOrientation)orientation {
  self.centerPhotoView.hidesExtras = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidRotate:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView {
  return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch {
  if ([self isShowingChrome]) {
    [self showBars:NO animated:YES];

  } else {
    [self showBars:YES animated:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
  return _photoSource.numberOfPhotos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  TTPhotoView* photoView = (TTPhotoView*)[_scrollView dequeueReusablePage];
  if (!photoView) {
    photoView = [self createPhotoView];
    photoView.captionStyle = _captionStyle;
    photoView.defaultImage = _defaultImage;
    photoView.hidesCaption = _toolbar.alpha == 0;
  }

  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  [self showPhoto:photo inView:photoView];

  return photoView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  return photo ? photo.size : CGSizeZero;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTThumbsViewControllerDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo {
  self.centerPhoto = photo;

  if ([self.navigationController isKindOfClass:[TTBaseNavigationController class]]) {
    [(TTBaseNavigationController*)self.navigationController
     popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];

  } else {
    [self.navigationController popViewControllerAnimated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
       shouldNavigateToPhoto:(id<TTPhoto>)photo {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (_photoSource != photoSource) {
      _photoSource = photoSource;

    [self moveToPhotoAtIndex:0 withDelay:NO];
    self.model = _photoSource;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPhoto:(id<TTPhoto>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
        _photoSource = photo.photoSource;

      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      self.model = _photoSource;

    } else {
      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      [self refresh];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTPhotoView*)createPhotoView {
  return [[TTPhotoView alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTThumbsViewController*)createThumbsViewController {
  return [[TTThumbsViewController alloc] initWithDelegate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToPhoto:(id<TTPhoto>)photo fromPhoto:(id<TTPhoto>)fromPhoto {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(NSString*)title {
  if (title) {
    TTActivityLabel* label = [[TTActivityLabel alloc]
                               initWithStyle:TTActivityLabelStyleBlackBezel];
    label.tag = kActivityLabelTag;
    label.text = title;
    label.frame = _scrollView.frame;
    [_innerView addSubview:label];

    _scrollView.scrollEnabled = NO;

  } else {
    UIView* label = [_innerView viewWithTag:kActivityLabelTag];
    if (label) {
      [label removeFromSuperview];
    }

    _scrollView.scrollEnabled = YES;
  }
}


@end
