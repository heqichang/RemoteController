//
//  ViewController.m
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/2/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "ViewController.h"
#import "RCDefine.h"
#import "RCBLEClient.h"

@interface ViewController ()

@property (nonatomic, strong) RCBLEClient *BLEClient;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectTrackPadButton;

@end

@implementation ViewController

static void * const ViewControllerKVOContext = (void *)&ViewControllerKVOContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.BLEClient = [RCBLEClient sharedInstance];
    [self.BLEClient addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:ViewControllerKVOContext];
}

- (void)dealloc {
    [self.BLEClient removeObserver:self forKeyPath:@"status"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)unwindToSource:(UIStoryboardSegue*)sender {
    [self.BLEClient stopAdvertisement];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == ViewControllerKVOContext) {
        if ([keyPath isEqualToString:@"status"]) {
            NSInteger newValue = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            [self changeStatus:newValue];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private
- (void)changeStatus:(RCConnectStatus)status {
    switch (status) {
        case RCConnect_BlueToothIsOff:
            self.statusLabel.text = @"未打开蓝牙或者该设备不支持";
            self.connectTrackPadButton.enabled = NO;
            break;
            
        default:
            self.statusLabel.text = @"";
            self.connectTrackPadButton.enabled = YES;
            break;
    }
}

@end
