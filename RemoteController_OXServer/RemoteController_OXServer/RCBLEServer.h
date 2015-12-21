//
//  RCBLEServer.h
//  RemoteController_OXServer
//
//  Created by heqichang on 12/17/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDefine.h"

@protocol RCBLEServerDelegate <NSObject>

@optional

- (void)ServerDidReadCommandString:(NSString *)command;

@end


@interface RCBLEServer : NSObject

@property (nonatomic, assign) RCConnectStatus status;

@property (nonatomic, weak) id<RCBLEServerDelegate> delegate;

- (void)startScan;

- (void)stopScan;

@end
