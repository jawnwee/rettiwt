//
//  JYLLoginViewController.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "JYLLoginViewController.h"
#import "JYLErrorViewController.h"
#import "JYLMainRettiwtViewController.h"
#import "JYLProfileViewController.h"
#import "JYLFeedCollectionViewController.h"
#import "JYLRettiwtManagedStore.h"

@interface JYLLoginViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) ACAccount *mainAcc;

@end

@implementation JYLLoginViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - View Setup

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkSSO];
}

#pragma mark - Twitter User Setup
// Check if user is permission is still allowed; if so, proceed with login and timelineviewcontroller
- (void)checkSSO {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil
                                      completion:^(BOOL granted, NSError *error) {
        if (granted == YES) {
            _accounts = [account accountsWithAccountType:accountType];
            if ([self.accounts count] == 1) {
                // Pick the first twitter account set in settings if only one account
                _mainAcc = [self.accounts objectAtIndex:0];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self loadMain];
                });

            } else if ([self.accounts count] > 0) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self displayTwitterAccounts:self.accounts];
                });
            } else {
                // Pop up error message
                // This controller does not exist in iOS7 so i'll leave this commented out for now

                /* UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account Unavailable"
                                                    message:@"Please set a twitter account in your settings"
                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction =
                [UIAlertAction actionWithTitle:@"Ok"
                                         style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action) {

                                           JYLErrorViewController *error =
                                           [[JYLErrorViewController alloc] init];
                                           [self presentViewController:error
                                                              animated:NO
                                                            completion:nil];
                                       }];

                [alert addAction:cancelAction]; */
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // [self presentViewController:alert animated:YES completion:nil];
                    JYLErrorViewController *error = [[JYLErrorViewController alloc] init];
                    [self presentViewController:error
                                       animated:NO
                                     completion:nil];
                });
            }
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIAlertController *alert =
                    [UIAlertController alertControllerWithTitle:@"Twitter"
                                                        message:@"Allow twitter authentication in this app!" 
                                                 preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *cancelAction =
                        [UIAlertAction actionWithTitle:@"Ok" 
                                                 style:UIAlertActionStyleCancel 
                                               handler:^(UIAlertAction *action) {
                                                      JYLErrorViewController *error =
                                                          [[JYLErrorViewController alloc] init];
                                                      [self presentViewController:error 
                                                                         animated:NO 
                                                                       completion:nil];
                                                 }];
                [alert addAction:cancelAction];

                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

/* iOS8 seems to have a bug where action sheets crash app */
- (void)displayTwitterAccounts:(NSArray *)twitterAccounts {
    __block UIActionSheet * select = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];

    [twitterAccounts enumerateObjectsUsingBlock:^(id twitterAccount, NSUInteger idx, BOOL *stop) {
        [select addButtonWithTitle:[twitterAccount username]];
    }];

    [select showInView:self.view];
}

#pragma mark - Setup Main
- (void)loadMain {
    // Initialize stores and controllers and chcange rootviewcontroller to mainvc
    [[JYLRettiwtManagedStore sharedStore] setAccount:self.mainAcc];
    
    JYLFeedCollectionViewController *feed =
    [[JYLFeedCollectionViewController alloc] initWithAccount:self.mainAcc];
    JYLProfileViewController *profile =
    [[JYLProfileViewController alloc] initWithAccount:self.mainAcc];
    JYLMainRettiwtViewController *mainVC =
    [[JYLMainRettiwtViewController alloc] initWithAccount:self.mainAcc
                                                profileVC:profile
                                                   feedVC:feed];
    self.view.window.rootViewController = mainVC;
}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex != actionSheet.cancelButtonIndex) {
        self.mainAcc = [self.accounts objectAtIndex:buttonIndex];
        [self loadMain];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
