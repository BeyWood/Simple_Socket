//
//  UDPServerViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "UDPServerViewController.h"

@interface UDPServerViewController ()<AsyncUdpSocketDelegate>{
    UITextField *text;
}

@property(nonatomic,strong)AsyncUdpSocket *socket;
@end

@implementation UDPServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UDP SERVER";
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(50, 100, 60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"开启" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openUDP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
    text = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, 200 , 40)];
    text.placeholder = @"发送内容";
    [self.view addSubview:text];;
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(50, 200, 60, 35);
    [sendBtn setBackgroundColor:[UIColor blackColor]];
    [sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self setRoundBtn:openBtn];
    [self setRoundBtn:sendBtn];
    [self.view addSubview:sendBtn];
    // Do any additional setup after loading the view.
}

-(void)openUDP:(UIButton *)sender{
    _socket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    _socket.delegate = self;
    NSData *data=[@"Hello from iPhone" dataUsingEncoding:NSUTF8StringEncoding];
    [_socket sendData:data toHost:@"10.8.206.103" port:5555 withTimeout:-1 tag:1];
    NSError *error = nil;
    [_socket bindToPort:5555 error:&error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    [_socket receiveWithTimeout:-1 tag:1];
    NSLog(@"send upd complete.");
}

-(void)sendMessage:(UIButton*)sender{
    NSData *data=[text.text dataUsingEncoding:NSUTF8StringEncoding];
    [_socket sendData:data toHost:@"10.8.206.103" port:9001 withTimeout:-1 tag:1];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port{
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
