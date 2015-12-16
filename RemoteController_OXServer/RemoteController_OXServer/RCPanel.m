//
//  RCPanel.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/15/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCPanel.h"

@implementation RCPanel

// issue: http://stackoverflow.com/questions/14096270/nswindow-is-not-receiving-any-notification-when-it-loses-focus
- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
