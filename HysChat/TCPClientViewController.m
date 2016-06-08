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
    UITextField *text;
}

@end

@implementation TCPClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TCP CLIENT";
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(30, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"连接" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openUDP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
    text = [[UITextField alloc] initWithFrame:CGRectMake(30, 150, 200, 35)];
    text.placeholder = @"请输入";
    [self.view addSubview:text];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(30, 200, 60, 40);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor blackColor]];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [self setRoundBtn:sendBtn];
    [self setRoundBtn:openBtn];
    // Do any additional setup after loading the view.
}

- (void)openUDP:(UIButton*)sender{
    
    socket=[[AsyncSocket alloc] initWithDelegate:self];
    NSError *error;
    [socket connectToHost:@"10.8.206.103" onPort:4322 error:&error];
    [socket readDataToLength:50 withTimeout:10000 tag:1];
//    [socket readDataToLength:50 withTimeout:5 tag:2];
    [socket writeData:[@"GET / HTTP/1.1nn" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    socket.runLoopModes = @[NSRunLoopCommonModes];
    
}

- (void)sendMessage:(UIButton*)sender{
    if (socket) {
//        [socket connectToHost:@"10.8.206.103" onPort:4322 error:nil];
        [socket writeData:[text.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    }
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
