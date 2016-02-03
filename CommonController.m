//
//  CommonController.m
//  messenger
//
//  Created by Kudinov Denis on 30.10.15.
//  Copyright © 2015 Trinity digital. All rights reserved.
//

#import "CommonController.h"

#import "MBProgressHud.h"
#import "MNavigationController.h"

#import "PopupAlert.h"

#import "Reachability.h"

@interface CommonController () <PopupProtocol>

@property (strong, nonatomic) PopupAlert *popupAlert;

@end

@implementation CommonController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    if (self.navigationItem) {
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoFindFace"]]];
        [self.navigationItem setHidesBackButton:YES];
    }
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MBProgressHUD *)showProgressHUD {
    return [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)hideAllHUDs {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (BOOL)haveInternetConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)openMenu {
    MNavigationController *nc = (MNavigationController *)self.navigationController;
    nc.previousVC = self;
    UIViewController *profileVC = [[UIStoryboard storyboardWithName:@"Profile"
                                                             bundle:nil] instantiateInitialViewController];
    NSMutableArray *vcs =  [NSMutableArray arrayWithArray:nc.viewControllers];
    [vcs insertObject:profileVC atIndex:[vcs count]-1];
    [nc setViewControllers:vcs animated:NO];
    [nc popViewControllerAnimated:YES];
}

- (void)openPreviousPoppedController {
    MNavigationController *nc = (MNavigationController *)self.navigationController;
    [self.navigationController pushViewController:nc.previousVC animated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showBarWithWithText:(NSString *)text color:(UIColor *)color {
    int errorBarHeight = 25;
    UIView *errorBar = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                -errorBarHeight,
                                                                self.view.frame.size.width,
                                                                errorBarHeight)];
    UILabel *errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      errorBar.frame.size.width,
                                                                      errorBar.frame.size.height)];
    errorMessage.text = text;
    errorMessage.font = [Helper futuraBookCRegularFontWithSize:14];
    errorMessage.textColor = [UIColor whiteColor];
    errorMessage.textAlignment = NSTextAlignmentCenter;
    [errorBar addSubview:errorMessage];
    
    errorBar.backgroundColor = color;
    [self.view addSubview:errorBar];
    [UIView animateWithDuration:.25 animations:^{
        CGRect errorBarRect = errorBar.frame;
        errorBarRect.origin.y = 0;
        errorBar.frame = errorBarRect;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                CGRect errorBarRect = errorBar.frame;
                errorBarRect.origin.y = -errorBarRect.size.height;
                errorBar.frame = errorBarRect;
            } completion:^(BOOL finished) {
                [errorBar removeFromSuperview];
            }];
        });
    }];
}

- (void)showErrorBarWithMessage:(NSString *)message {
    [self showBarWithWithText:message color:[UIColor redColor]];
}

- (void)showMessageWithText:(NSString *)text {
    [self showBarWithWithText:text color:[UIColor colorWithRed:0.1 green:0 blue:1 alpha:0.7]];
}

#pragma mark - Popup
//-------------------------------------------------
// Popup
//-------------------------------------------------

/**
 *  Попап на весь экран на чёрном фоне с кнопками перейти к оплате и закрыть
 *
 *  @param text     текст на попапе
 *  @param delegate может быть nil
 */
- (void)showPopupWithText:(NSString *)text delegate:(id<PopupProtocol>)delegate {
    if (self.popupAlert) {
        [self closePopupWithCompletion:nil];
    }
    self.popupAlert = [[[NSBundle mainBundle] loadNibNamed:@"PopupAlert" owner:self options:nil] objectAtIndex:0];
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    self.popupAlert.frame = CGRectMake(0,
                             0,
                             mainWindow.frame.size.width,
                             mainWindow.frame.size.height);
    self.popupAlert.popupText = text;
    self.popupAlert.delegate = delegate ?: self;
    self.popupAlert.alpha = 0.0;
    [mainWindow addSubview:self.popupAlert];
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.popupAlert.alpha = 1.0;
    }];
}

- (void)closePopupWithCompletion:(void(^)())completion {
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        self.popupAlert.alpha = 0.0;
    } completion:^(BOOL finished) {
        @strongify(self)
        [self.popupAlert removeFromSuperview];
        self.popupAlert.delegate = nil;
        self.popupAlert = nil;
        if (completion) {
            completion();
        }
    }];
}

- (void)openPurchases {
    [self closePopupWithCompletion:^{
        UIViewController *purchasesController = [[UIStoryboard storyboardWithName:@"Purchases" bundle:nil] instantiateInitialViewController];
        [self.navigationController pushViewController:purchasesController animated:YES];
    }];
}

- (void)closePopup:(PopupAlert *)popup {
    [self closePopupWithCompletion:nil];
}

@end
