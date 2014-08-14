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

@interface JYLLoginViewController ()

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
                NSArray *accounts = [account accountsWithAccountType:accountType];

                if ([accounts count] > 0) {
                    // Pick the first twitter account set in settings (most likely main one
                    // Could implement a view to select from multiple accounts, but for the
                    // sake of this interview, not done.
                    ACAccount *mainAcc = [accounts objectAtIndex:0];
                    [JYLRettiwtManagedStore sharedStore];
                    JYLFeedCollectionViewController *feed =
                                  [[JYLFeedCollectionViewController alloc] initWithAccount:mainAcc];
                    JYLProfileViewController *profile =
                                  [[JYLProfileViewController alloc] initWithAccount:mainAcc];
                    JYLMainRettiwtViewController *mainVC =
                    [[JYLMainRettiwtViewController alloc] initWithAccount:mainAcc 
                                                                profileVC:profile 
                                                                   feedVC:feed];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        self.view.window.rootViewController = mainVC;
                    });
                } else {
                    // Pop up error message
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertController *alert =
                        [UIAlertController alertControllerWithTitle:@"Account Unavailable"
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
                        [alert addAction:cancelAction];
                        [self presentViewController:alert animated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
