//
//  UDPClientViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "UDPClientViewController.h"

@interface UDPClientViewController ()<AsyncUdpSocketDelegate>{
    UITextField *text;
    NSString *reciveHost;
    UInt16 reciveport;
}

@property(nonatomic,strong)AsyncUdpSocket *socket;
@end

@implementation UDPClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UDP SERVER";
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 243)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(50, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"连接" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    [self setRoundBtn:openBtn];
    [self.view addSubview:openBtn];
    text = [[UITextField alloc] initWithFrame:CGRectMake(30, 150, 200, 40)];
    text.placeholder = @"请输入发送内容";
    [self.view addSubview:text];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTintColor:[UIColor greenColor]];
    sendBtn.frame = CGRectMake(30, 200, 60, 40);
    [sendBtn setBackgroundColor:[UIColor blackColor]];
    [self setRoundBtn:sendBtn];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
}

-(void)sendMessage:(UIButton*)sender {
    if (reciveHost && reciveHost.length > 0) {
        [_socket sendData:[text.text dataUsingEncoding:NSUTF8StringEncoding] toHost:reciveHost port:reciveport withTimeout:-1 tag:1];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"未连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)connect:(UIButton*)sender{
    _socket =[[AsyncUdpSocket alloc] initWithDelegate:self];
    _socket.delegate = self;
    NSError *error = nil;
    [_socket bindToPort:9001 error:&error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    [_socket receiveWithTimeout:-1 tag:1];
    NSLog(@"start udp server");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port{
    reciveHost = host;
    reciveport = port;
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    return YES;
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
