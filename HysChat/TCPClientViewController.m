//
//  TCPClientViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "TCPClientViewController.h"

@interface TCPClientViewController ()<AsyncSocketDelegate>{
    
    AsyncSocket *socket;
}

@end

@implementation TCPClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TCP CLIENT";
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(50, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"连接" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openUDP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    // Do any additional setup after loading the view.
}

- (void)openUDP:(UIButton*)sender{
    
    socket=[[AsyncSocket alloc] initWithDelegate:self];
    [socket connectToHost:@"www.baidu.com" onPort:80 error:nil];
    [socket readDataToLength:50 withTimeout:5 tag:1];
    [socket readDataToLength:50 withTimeout:5 tag:2];
    [socket writeData:[@"GET / HTTP/1.1nn" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3 tag:1];
    
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)_data withTag:(long)tag{
    NSLog(@"did read data");
    NSString* message = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"message is: n%@",message);
    if (tag==2) {
        [socket disconnect];
    }
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
