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

#import "MCTUINavigationController.h"

@interface MCTUINavigationController ()

@end

@implementation MCTUINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate
{
    T_UI();
    HERE();
    return [OR(self.presentedViewController, self.topViewController) shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    T_UI();
    HERE();
    UIViewController *presentedVC;
    if (self.presentedViewController && ![self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        presentedVC = self.presentedViewController;
    } else {
        presentedVC = self.topViewController;
    }
    return [presentedVC supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    T_UI();
    HERE();
    UIViewController *presentedVC;
    if (self.presentedViewController && ![self.presentedViewController isKindOfClass:[UIAlertController class]]) {
        presentedVC = self.presentedViewController;
    } else {
        presentedVC = self.topViewController;
    }
    return [presentedVC preferredInterfaceOrientationForPresentation];
}

@end