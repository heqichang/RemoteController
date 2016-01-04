//
//  RCBLEClient.h
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/23/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDefine.h"

@interface RCBLEClient : NSObject

@property (nonatomic, assign) RCConnectStatus status;

+ (instancetype)sharedInstance;

- (void)startAdvertisement;
- (void)stopAdvertisement;
- (BOOL)sendData:(NSData *)data;
- (void)isAutoAdvertisement:(BOOL)isAuto;

@end
