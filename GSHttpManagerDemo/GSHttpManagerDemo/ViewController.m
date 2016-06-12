//
//  ViewController.m
//  GSHttpManagerDemo
//
//  Created by 关宇琼 on 16/6/8.
//  Copyright © 2016年 GuanSir. All rights reserved.
//

#import "ViewController.h"
#import "GSHttpManager.h"
#import "CommonCrypto/CommonDigest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button setFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    
    // Do any additional setup after loading the view.
}
- (void)button {
    NSDictionary *param = @{
                            
                            @"phone_mob":@"123132132",
                            
                            @"password": [self md5:@"12331213"]
                            
                            };
    
    
    [gs_HttpManager httpManagerPostParameter:param toHttpUrlStr:@"http://192.168.0.107/sl/hrb_sj/index.php?app=default_api&act=login" isCacheorNot:YES targetViewController:self andUrlFunctionName:@"ceshi" success:^(id result) {
        NSLog(@"%@", result);
    } orFail:^(NSError *error) {
        
    }];
}

- (NSString *) md5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
    
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
