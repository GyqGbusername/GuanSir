//
//  ViewController.m
//  二次封装AFNetworking3.0
//
//  Created by dllo on 15/11/21.
//  Copyright © 2015年 GYQ. All rights reserved.
//

#import "ViewController.h"
#import "HTTPTOOL.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleData];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)handleData {
    [HTTPTOOL GETWithURL:@"http://c.3g.163.com/recommend/getChanRecomNews?channel=duanzi&passport=91153191bdb987ca2bc10b1d3e7a5004@tencent.163.com&devId=CE80EFE4-9CE9-4E06-B117-DFA8DE7893F1&size=20" withBody:nil withHttpHead:nil responseStyle:JSON withSuccess:^(id result) {
        NSLog(@"%@", result);
    } withFail:^(id result) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
