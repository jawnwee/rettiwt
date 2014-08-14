//
//  JYLErrorViewController.m
//  rettiwt
//
//  Created by John Lee on 8/12/14.
//  Copyright (c) 2014 johnjlee. All rights reserved.
//

#import "JYLErrorViewController.h"

@interface JYLErrorViewController ()

@end

@implementation JYLErrorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addErrorMessage];
}

- (void)addErrorMessage {
    CGRect frame = CGRectMake(0, 0, 320, 300);
    UILabel *error = [[UILabel alloc] initWithFrame:frame];
    error.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    error.numberOfLines = 2;
    error.text = @"Login Error. Cannot proceed. Please correct your settings and restart";
    error.textAlignment = NSTextAlignmentCenter;
    error.center = self.view.center;
    [self.view addSubview:error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
