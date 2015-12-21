//
//  RCPanelController.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/3/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCPanelController.h"

@interface RCPanelController ()<NSWindowDelegate>

@property (nonatomic, assign) BOOL isConnectButtonEnabled; // 用于 Binding

@property (nonatomic, strong) NSStatusItem *statusItem;

@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *connectButton;

- (IBAction)connectButtonDidClick:(id)sender;

@end

@implementation RCPanelController

- (id)init {
    self = [super initWithWindowNibName:@"RCPanelController"];
    if (self) {
        // 在状态栏上加上程序图片，statusItem 必须被retain
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24.0];
        NSStatusBarButton *button = [self.statusItem button];
        [button setImage:[NSImage imageNamed:@"Status"]];
        [button setTarget:self];
        [button setAction:@selector(toggleRCPanel:)];
        
        self.isPanelActive = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.window setBackgroundColor:[NSColor clearColor]];
}


- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)connectButtonDidClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(connectClientButtonDidClick)]) {
        [self.delegate connectClientButtonDidClick];
    }
    
}

#pragma mark - NSWindowDelegate
- (void)windowDidResignKey:(NSNotification *)notification {
    if ([self.window isVisible]) {
        self.isPanelActive = NO;
    }
}


#pragma mark - private

- (void)toggleRCPanel:(id)sender {
    self.isPanelActive = !self.isPanelActive;
}

- (void)openPanel {
    
    NSWindow *panel = [self window];
    
    NSStatusBarButton *button = [self.statusItem button];
    NSRect statusRect = [button.window convertRectToScreen:[button frame]];
    
    NSRect panelRect = [panel frame];
    panelRect.origin.x = NSMidX(statusRect) - NSWidth(panelRect) / 2;
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect) - 10;
    [panel setFrame:panelRect display:YES];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:nil];
    
}

- (void)closePanel {
   
    NSWindow *panel = [self window];
    [panel orderOut:nil];
}



#pragma mark - getter & setter

- (void)setStatus:(RCConnectStatus)status {
    switch (status) {
        case RCConnect_BlueToothIsOff:
            self.isConnectButtonEnabled = NO;
            [self.connectButton setTitle:@"开始扫描"];
            [self.statusLabel setStringValue:@"请打开系统蓝牙"];
            break;
        case RCConnect_NoConnected:
            self.isConnectButtonEnabled = YES;
            [self.connectButton setTitle:@"开始扫描"];
            [self.statusLabel setStringValue:@"请开始扫描"];
            break;
        case RCConnect_Scanning:
            self.isConnectButtonEnabled = YES;
            [self.connectButton setTitle:@"停止扫描"];
            [self.statusLabel setStringValue:@"正在扫描"];
            break;
        case RCConnect_Connected:
            self.isConnectButtonEnabled = NO;
            [self.connectButton setTitle:@"开始扫描"];
            [self.statusLabel setStringValue:@"已连接上"];
            break;
        default:
            break;
    }
    
    _status = status;
}


- (void)setIsPanelActive:(BOOL)isPanelActive {
    
    if (isPanelActive) {
        [self openPanel];
    } else {
        [self closePanel];
    }
    _isPanelActive = isPanelActive;
}





@end
