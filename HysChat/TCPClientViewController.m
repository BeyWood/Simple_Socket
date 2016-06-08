//
//  TCPClientViewController.m
//  HysChat
//
//  Created by Jason Huang on 16/6/7.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "TCPClientViewController.h"

@interface TCPClientViewController ()<AsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    AsyncSocket *socket;
    UITextField *text;
    UILabel *receiveLab;
    UIButton *openBtn;
    UITableView *mainTable;
    NSMutableArray *recordArr;
}
@end

@implementation TCPClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TCP client";
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self initUI];
    [self initData];
}

- (void)initUI{
    [self.view setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    
    mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 15,self.view.frame.size.width, 400) style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    [mainTable setBackgroundColor:RGBACOLOR(243, 243, 243, 1)];
    mainTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mainTable];
    openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(30, self.view.frame.size.height-80, self.view.frame.size.width-60, 35);
    [openBtn setBackgroundColor:[UIColor blackColor]];
    [openBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [openBtn setTitle:@"连接" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openUDP:) forControlEvents:UIControlEventTouchUpInside];
    [openBtn setTitle:@"关闭" forState:UIControlStateSelected];
    [self.view addSubview:openBtn];
    
    text = [[UITextField alloc] initWithFrame:CGRectMake(30, 530, 260, 35)];
    text.backgroundColor = [UIColor whiteColor];
    text.placeholder = @"请输入";
    text.text = @"小明在吗?";
    [self setRoundBtn:text];
    [self.view addSubview:text];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(self.view.frame.size.width-60-20, 530, 60, 35);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor blackColor]];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [self setRoundBtn:sendBtn];
    [self setRoundBtn:openBtn];
    receiveLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 570, 200, 35)];
    receiveLab.textColor = [UIColor blackColor];
//    [self.view addSubview:receiveLab];
}

- (void)initData{
    recordArr = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)openUDP:(UIButton*)sender{
    if (!sender.isSelected) {
        socket=[[AsyncSocket alloc] initWithDelegate:self];
        NSError *error=nil;
        if(![socket connectToHost:@"10.8.206.103" onPort:4322 error:&error]) {
            sender.selected = YES;
            NSLog(@"connect");
        } else {
            NSLog(@"disconnect");
        }
    } else {
        [socket disconnect];
        sender.selected = NO;
    }
}

- (void)sendMessage:(UIButton*)sender{
    if (socket) {
        if (text.text.length > 0) {
            text.text = @"";
            [recordArr addObject:@{@"name":@"我",@"content":text.text}];
            [socket writeData:[text.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
            [mainTable reloadData];
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    openBtn.selected = YES;
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
    [sock readDataWithTimeout:-1 tag:0];
    [self sendMessage:nil];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout: -1 tag: 0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [recordArr addObject:@{@"name":@"小明",@"content":aStr}];
    receiveLab.text = aStr;
    [mainTable reloadData];
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    openBtn.selected = NO;
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, [err description]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    openBtn.selected = NO;
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
    receiveLab.text = @"已断开连接";
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return recordArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifierCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 300, 44)];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    NSDictionary *dic = recordArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: ",[dic objectForKey:@"name"]];
    lab.text = [dic objectForKey:@"content"];
    [cell addSubview:lab];
    return cell;
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
