//
//  TCPServerViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "TCPServerViewController.h"

@interface TCPServerViewController ()<AsyncSocketDelegate>{
    AsyncSocket *listener;
    BOOL isRunning;
    UITextField *text;
    NSMutableArray *connectSockets;
}

@end

@implementation TCPServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TCP SERVER";
    connectSockets = [[NSMutableArray alloc] initWithCapacity:30];
    isRunning = NO;
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(30, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"开启" forState:UIControlStateNormal];
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
    listener =[[AsyncSocket alloc] initWithDelegate:self];
    
    // Do any additional setup after loading the view.
}

- (void)openUDP:(UIButton*)sender{
    
    
    NSError *err = nil;
    if (!isRunning) {
        if ([listener  acceptOnPort:4322 error:&err]) {
            NSLog(@"accept ok.");
//            listener.runLoopModes = @[NSRunLoopCommonModes];
            isRunning = YES;
        } else {
            NSLog(@"accept failed.");
        }
    } else {
        [listener disconnect];
        for (int i = 0;i < connectSockets.count;i++) {
            AsyncSocket *socket = [connectSockets objectAtIndex:i];
            [socket disconnect];
        }
        isRunning = FALSE;
    }
    
}

- (void)sendMessage:(UIButton*)sender {
    [listener writeData:[text.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    [connectSockets addObject:newSocket];
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
    [listener readDataWithTimeout:-1 tag:1];
    NSString *returnMessage=@"Welcome To Socket Test Server!";
    //将NSString转换成为NSData类型
    NSData *data=[returnMessage dataUsingEncoding:NSUTF8StringEncoding];
    //向当前连接服务器的客户端发送连接成功信息
    [sock writeData:data withTimeout:-1 tag:0];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"did read data");
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"message is: n%@",message);
    [listener writeData:data withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"message did write");
    [listener readDataWithTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"socket did disconnect");
    [connectSockets removeObject:sock];
//    listener;
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
