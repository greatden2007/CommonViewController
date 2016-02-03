//
//  CommonController.h
//  messenger
//
//  Created by Kudinov Denis on 30.10.15.
//  Copyright © 2015 Trinity digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionController, VKController, User, MBProgressHUD;
@protocol PopupProtocol;

@interface CommonController : UIViewController

@property (weak) SessionController *sessionController;
@property (weak) VKController *vkController;

@property (strong) User *user;

// hud
- (MBProgressHUD *)showProgressHUD;
- (void)hideHUD;
- (void)hideAllHUDs;

- (BOOL)haveInternetConnection;

//navigation
// menu
- (void)openMenu;
- (void)openPreviousPoppedController;
//back
- (IBAction)back:(id)sender;

- (void)showErrorBarWithMessage:(NSString *)message;
- (void)showMessageWithText:(NSString *)text;

// алерт о необходимости покупки
- (void)showPopupWithText:(NSString *)text delegate:(id<PopupProtocol>)delegate;
- (void)closePopupWithCompletion:(void(^)())completion;

@end
