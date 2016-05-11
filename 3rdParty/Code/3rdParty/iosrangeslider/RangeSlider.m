//
//  RangeSlider.m
//  RangeSlider
//
//  Created by Mal Curtis on 5/08/11.

#import "RangeSlider.h"

@interface RangeSlider (PrivateMethods)
- (float)xForValue:(float)value;
- (float)valueForX:(float)x;
- (void)updateTrackHighlight;
@end

@implementation RangeSlider

@synthesize minimumValue, maximumValue, minimumRange, selectedMinimumValue, selectedMaximumValue;

- (id)initWithFrame:(CGRect)frame
           minValue:(float)minValue
           maxValue:(float)maxValue
           minRange:(float)minRange
   selectedMinValue:(float)selectedMinValue
   selectedMaxValue:(float)selectedMaxValue
{
    if (self = [super initWithFrame:frame]) {
        minimumValue = minValue;
        maximumValue = maxValue;
        minimumRange = minRange;
        selectedMinimumValue = selectedMinValue;
        selectedMaximumValue = selectedMaxValue;

        // Set the initial state
        _minThumbOn = NO;
        _maxThumbOn = NO;
        _padding = 10;

        _trackBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-background.png"]];
        CGFloat tbH = 10;
        _trackBackground.frame = CGRectMake(0, (self.frame.size.height - tbH) / 2, self.frame.size.width, tbH);
        [self addSubview:_trackBackground];

        _track = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-highlight.png"]];
        _track.frame = _trackBackground.frame;
        [self addSubview:_track];

        _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
        _minThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _minThumb.contentMode = UIViewContentModeCenter;
		_minThumb.center = CGPointMake([self xForValue:selectedMinimumValue], self.frame.size.height/2);
		[self addSubview:_minThumb];

        _maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle-hover.png"]];
        _maxThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _maxThumb.contentMode = UIViewContentModeCenter;
		_maxThumb.center = CGPointMake([self xForValue:selectedMaximumValue], self.frame.size.height/2);
		[self addSubview:_maxThumb];
        NSLog(@"Tapable size %f", _minThumb.bounds.size.width);
        [self updateTrackHighlight];
    }
    return self;
}


- (float)xForValue:(float)value
{
    return (self.frame.size.width-(_padding*2))*((value - minimumValue) / (maximumValue - minimumValue))+_padding;
}

- (float)valueForX:(float)x
{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_minThumbOn && !_maxThumbOn){
        return YES;
    }

    CGPoint touchPoint = [touch locationInView:self];

    if (_minThumbOn && _maxThumbOn) {
        if (_beginTouchX < touchPoint.x) {
            _minThumbOn = NO;
        } else {
            _maxThumbOn = NO;
        }
    }

    if (_minThumbOn) {
        _minThumb.center = CGPointMake(MAX([self xForValue:minimumValue], MIN(touchPoint.x, [self xForValue:selectedMaximumValue - minimumRange])), _minThumb.center.y);
        selectedMinimumValue = [self valueForX:_minThumb.center.x];
    }

    if (_maxThumbOn) {
        _maxThumb.center = CGPointMake(MIN([self xForValue:maximumValue], MAX(touchPoint.x, [self xForValue:selectedMinimumValue + minimumRange])), _maxThumb.center.y);
        selectedMaximumValue = [self valueForX:_maxThumb.center.x];
    }

    [self updateTrackHighlight];
    [self setNeedsDisplay];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    _beginTouchX = touchPoint.x;
    _minThumbOn = CGRectContainsPoint(_minThumb.frame, touchPoint);
    _maxThumbOn = CGRectContainsPoint(_maxThumb.frame, touchPoint);
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _minThumbOn = NO;
    _maxThumbOn = NO;
}

- (void)updateTrackHighlight
{
	_track.frame = CGRectMake(
                              _minThumb.center.x,
                              _track.center.y - (_track.frame.size.height / 2),
                              _maxThumb.center.x - _minThumb.center.x,
                              _track.frame.size.height
                              );
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
