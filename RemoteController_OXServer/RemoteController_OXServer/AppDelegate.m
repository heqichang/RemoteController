//
//  AppDelegate.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/2/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "AppDelegate.h"
#import "RCGesture.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) RCBLEServer *server;
@property (nonatomic, strong) RCGesture *gesture;
@property (nonatomic, strong) RCPanelController *panel;

@end

@implementation AppDelegate

void *kAppContext = &kAppContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.panel = [[RCPanelController alloc] init];
    [self.panel setDelegate:self];
    
    self.server = [[RCBLEServer alloc] init];
    [self.server setDelegate:self];
    
    self.gesture = [[RCGesture alloc] init];
    
    [self.server addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kAppContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == kAppContext) {
        NSInteger newStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        self.panel.status = newStatus;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - RCPanelControllerDelegate
- (void)connectClientButtonDidClick {
    if ([self.server status] == RCConnect_NoConnected) {
        [self.server startScan];
    } else if ([self.server status] == RCConnect_Connected) {
        [self.server cancelConnect];
    } else {
        [self.server stopScan];
    }
}

#pragma mark - RCBLEServerDelegate
- (void)ServerDidReadCommandString:(NSString *)command {
//    NSLog(@"command: %@", command);
    [self.gesture parseCommand:command];
}

@end
