//
//  TCPServerViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "TCPServerViewController.h"

@interface TCPServerViewController (){
    AsyncSocket *acceptSocket;
}

@end

@implementation TCPServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(50, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"开启" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openUDP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    // Do any additional setup after loading the view.
}

- (void)openUDP:(UIButton*)sender{
    
    acceptSocket =[[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    if ([acceptSocket  acceptOnPort:4322 error:&err]) {
        NSLog(@"accept ok.");
    }else {
        NSLog(@"accept failed.");
    }
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    if (!acceptSocket) {
        acceptSocket = newSocket;
        NSLog(@"did accept new socket");
    }
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"will connect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"did connect to host");
    [acceptSocket readDataWithTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"did read data");
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"message is: n%@",message);
    [acceptSocket writeData:data withTimeout:2 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"message did write");
    [acceptSocket readDataWithTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"socket did disconnect");
//    acceptSocket;
    acceptSocket=nil;
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
