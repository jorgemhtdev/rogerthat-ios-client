#import "MCTZXingWidgetController.h"
#import "MCTZXingUtils.h"

#import "QRCodeReader.h"


@implementation MCTZXingUtils

+ (void)presentZXingWidgetWithDelegate:(UIViewController<ZXingDelegate> *)delegate handleOrientation:(BOOL)handleOrientation
{
    ZXingWidgetController *widget =
        [[MCTZXingWidgetController alloc] initWithDelegate:delegate
                                                 showCancel:YES
                                                   OneDMode:NO
                                           andUserTextLine1:NSLocalizedString(@"(scan line1) Place QR code", nil)
                                           andUserTextLine2:NSLocalizedString(@"(scan line2) inside the rectangle", nil)
                                        andCancelButtonText:NSLocalizedString(@"Cancel", nil)
                                          handleOrientation:handleOrientation];


    QRCodeReader *reader = [[QRCodeReader alloc] init];
    widget.readers = [NSSet setWithObjects:reader, nil];

    NSBundle *mainBundle = [NSBundle mainBundle];
    widget.soundToPlay = [NSURL fileURLWithPath:[mainBundle pathForResource:@"msg-received" ofType:@"wav"] isDirectory:NO];

    [delegate presentViewController:widget animated:YES completion:nil];
}

+ (ZXingWidgetController *)ZXingWidgetWithDelegate:(UIViewController<ZXingDelegate> *)delegate
                                             frame:(CGRect)frame
                                      isBackCamera:(BOOL)isBackCamera
{
    ZXingWidgetController *widget = [[MCTZXingWidgetController alloc] initWithDelegate:delegate frame:frame isBackCamera:isBackCamera];
    QRCodeReader *reader = [[QRCodeReader alloc] init];
    widget.readers = [NSSet setWithObjects:reader, nil];

    NSBundle *mainBundle = [NSBundle mainBundle];
    widget.soundToPlay = [NSURL fileURLWithPath:[mainBundle pathForResource:@"msg-received" ofType:@"wav"] isDirectory:NO];
    return widget;
}

@end
