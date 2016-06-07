//
//  ChatViewController.h
//  HysChat
//
//  Created by Jason Huang on 16/6/6.
//  Copyright © 2016年 JasonHuang. All rights reserved.
//

#import "BaseViewController.h"
#import "CocoaAsyncSocket.h"

@interface ChatViewController : BaseViewController

@property (nonatomic,weak)IBOutlet UIButton *sendBtn;

@property (nonatomic,weak)IBOutlet UITextField *inputTxt;

@property (nonatomic,weak)IBOutlet UITextField *ipAdress;

@property (nonatomic,weak)IBOutlet UIButton *reciveBtn;

@property (nonatomic,weak)IBOutlet UIButton *tcpBtn;

@property (nonatomic,weak)IBOutlet UIButton *udpBtn;

@end
