//
//  ChatViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/6.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "ChatViewController.h"
#import "UDPClientViewController.h"
#import "TCPClientViewController.h"
#import "UDPServerViewController.h"
#import "TCPServerViewController.h"

@interface ChatViewController ()<GCDAsyncSocketDelegate>

@property(nonatomic,strong)GCDAsyncSocket *socket;
@property(nonatomic,strong)GCDAsyncSocket *recesocket;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Think In app";
    self.view.backgroundColor = RGBACOLOR(243, 243, 243, 1);
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectBtn.frame = CGRectMake(30, 100, 100, 35);
    [connectBtn setTitle:@"connect" forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [connectBtn setBackgroundColor:[UIColor blackColor]];
    
    UIButton *disConnect = [UIButton buttonWithType:UIButtonTypeCustom];
    disConnect.frame = CGRectMake(30, 150, 100, 35);
    [disConnect setTitle:@"disconnect" forState:UIControlStateNormal];
    [disConnect setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [disConnect setBackgroundColor:[UIColor blackColor]];
    disConnect.layer.cornerRadius = 6.0;
    disConnect.layer.masksToBounds = YES;
    [connectBtn addTarget:self action:@selector(connectToServer:) forControlEvents:UIControlEventTouchUpInside];
    [self.reciveBtn addTarget:self action:@selector(reveive:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [connectBtn addTarget:self action:@selector(disConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self setRoundBtn:disConnect];
    [self setRoundBtn:connectBtn];
    [self setRoundBtn:self.sendBtn];
    [self setRoundBtn:self.reciveBtn];
    [self.reciveBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.ipAdress.placeholder = @"IP地址";
    [self.view addSubview:connectBtn];
    [self.view addSubview:disConnect];
    [self.tcpBtn addTarget:self action:@selector(tcpSocket:) forControlEvents:UIControlEventTouchUpInside];
    [self.udpBtn addTarget:self action:@selector(udpSocket:) forControlEvents:UIControlEventTouchUpInside];
    [self.tcpServerBtn addTarget:self action:@selector(tcpServerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.udpServerBtn addTarget:self action:@selector(udpServerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tcpSocket:(UIButton*)sender{
    TCPClientViewController *nextCtl = [[TCPClientViewController alloc] init];
    [self.navigationController pushViewController:nextCtl animated:YES];
}

-(void)udpSocket:(UIButton*)sender{
    UDPServerViewController *nextCtl = [[UDPServerViewController alloc] init];
    [self.navigationController pushViewController:nextCtl animated:YES];
}

-(void)tcpServerBtnAction:(UIButton*)sender{
    TCPServerViewController *nextCtl = [[TCPServerViewController alloc] init];
    [self.navigationController pushViewController:nextCtl animated:YES];
}

-(void)udpServerBtnAction:(UIButton*)sender{
    
    UDPClientViewController *nextCtl = [[UDPClientViewController alloc] init];
    [self.navigationController pushViewController:nextCtl animated:YES];
}

-(void)connectToServer:(UIButton*)sender{
    NSString *host = @"10.8.206.103";
    int port = 8006;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
//    _socket.userData = kCFSocketCloseOnInvalidate;
    [_socket setIPv4PreferredOverIPv6:YES];
    [_socket connectToHost:host onPort:port error:&error];
    if (error) {
        NSLog(@"suc");
    }
}

-(void)disConnect:(UIButton*)sender{
    [_socket disconnect];
    AsyncUdpSocket *socket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    [socket bindToPort:5555 error:&error];
    
    if (error) {
        NSLog(@"error: %@",error);
    }
    
    [socket receiveWithTimeout:-1 tag:1];
}

-(void)sendMessage{
    NSString *str = self.inputTxt.text;
    if (_socket) {
        [_socket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1001];
    }
}

- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock{
    return dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s",__func__);
}


//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
//    NSLog(@"receive");
//}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        NSLog(@"异常断开");
    } else {
        NSLog(@"正常断开");
    }
}

-(void)reveive:(UIButton*)sender{

    _recesocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error;
    _recesocket.delegate = self;
    [_recesocket acceptOnPort:8006 error:&error];
    NSLog(@"suc");
    
    AsyncUdpSocket *socket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    
    NSError *error1 = nil;
    [socket bindToPort:3333 error:&error1];
    [socket enableBroadcast:YES error:&error1];
    [socket joinMulticastGroup:@"239.0.0.1" error:&error1];
    
    if (error) {
        NSLog(@"error: %@",error);
    }
    
    [socket receiveWithTimeout:-1 tag:1];
    NSLog(@"start udp server");
    
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port{
    NSLog(@"received data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return YES;
}


#pragma mark 数据发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
}
#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:tag];
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@",__func__,receiverStr);
}


-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"socket suc");
}

-(void)socketDidSecure:(GCDAsyncSocket *)sock{
    NSLog(@"socket suc");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
