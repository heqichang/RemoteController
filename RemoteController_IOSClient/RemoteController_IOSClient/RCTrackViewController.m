//
//  RCTrackViewController.m
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/22/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCTrackViewController.h"
#import "RCTrackView.h"
#import "RCBLEClient.h"
#import "RCDefine.h"

@interface RCTrackViewController ()

@property (nonatomic, strong) RCBLEClient *BLEClient;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet RCTrackView *trackView;

@end

@implementation RCTrackViewController

static void * const RCTrackViewControllerKVOContext = (void *)&RCTrackViewControllerKVOContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.BLEClient = [RCBLEClient sharedInstance];
    [self changeStatus:self.BLEClient.status];
    [self.BLEClient addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:RCTrackViewControllerKVOContext];
    
    
    __weak RCTrackViewController *weakSelf = self;
    self.trackView.moveBlock = ^(NSArray *points) {
        
        if (weakSelf.BLEClient.status != RCConnect_Connected) {
            return;
        }
        
        NSMutableString *pointString = [NSMutableString string];
        
        for (NSString *s in points) {
            CGPoint point = CGPointFromString(s);
            [pointString appendString:[NSString stringWithFormat:@"%lf, %lf", point.x, point.y]];
            [pointString appendString:@";"];
        }
        
        pointString = [[pointString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]] mutableCopy];
        
        NSData *data = [pointString dataUsingEncoding:NSUTF8StringEncoding];
        
        [weakSelf.BLEClient sendData:data];
    };
    
    self.trackView.tapBlock = ^() {
        
        if (weakSelf.BLEClient.status != RCConnect_Connected) {
            return;
        }
        
        NSString *s = @"[tap]";
        NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
        
        [weakSelf.BLEClient sendData:data];
    };
    
    
    [self.BLEClient startAdvertisement];
}

- (void)dealloc {
    [self.BLEClient removeObserver:self forKeyPath:@"status"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == RCTrackViewControllerKVOContext) {
        if ([keyPath isEqualToString:@"status"]) {
            NSInteger status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            [self changeStatus:status];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private
- (void)changeStatus:(RCConnectStatus)status {
    switch (status) {
        case RCConnect_BlueToothIsOff:
            self.statusLabel.text = @"蓝牙关闭了";
            break;
        case RCConnect_NoConnected:
            self.statusLabel.text = @"未链接";
            break;
        case RCConnect_Connected:
            self.statusLabel.text = @"已链接";
            break;
        default:
            break;
    }
}
@end
