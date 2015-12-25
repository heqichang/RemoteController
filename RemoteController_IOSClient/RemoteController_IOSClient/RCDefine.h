//
//  RCDefine.h
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/23/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#ifndef RCDefine_h
#define RCDefine_h

typedef NS_ENUM(NSInteger, RCConnectStatus) {
    
    RCConnect_BlueToothIsOff,
    RCConnect_NoConnected,
    RCConnect_Scanning,
    RCConnect_Connected
};

#endif /* RCDefine_h */
