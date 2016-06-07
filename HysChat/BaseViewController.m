//
//  BaseViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/6.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
       // Do any additional setup after loading the view.
}

-(void)tapGesture:(UITapGestureRecognizer*)gesture{
    [self.view endEditing:YES];
}

-(void)setRoundBtn:(UIButton*)button{
    button.layer.cornerRadius = 6.0;
    button.layer.masksToBounds = YES;
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

@end
