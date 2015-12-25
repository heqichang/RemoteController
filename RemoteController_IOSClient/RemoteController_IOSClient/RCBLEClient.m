//
//  RCBLEClient.m
//  RemoteController_IOSClient
//
//  Created by heqichang on 12/23/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCBLEClient.h"
@import CoreBluetooth;

@interface RCBLEClient ()<CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *character;

@end


@implementation RCBLEClient


+ (instancetype)sharedInstance {
    static RCBLEClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[RCBLEClient alloc] init];
    });
    return client;
}


- (id)init {
    self = [super init];
    if (self) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            self.status = RCConnect_NoConnected;
            break;
        default:
            self.status = RCConnect_BlueToothIsOff;
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"subscribe");
    self.status = RCConnect_Connected;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"unsubscribe");
    self.status = RCConnect_NoConnected;
}

#pragma mark - public
- (void)startAdvertisement {
    
    if ([self.peripheralManager isAdvertising]) {
        return;
    }
    
    CBUUID *characteristicsUuid = [CBUUID UUIDWithString:@"7E656504-8EDD-46E7-AB82-D9F2CF3916C5"];

    // 被 subscribe 需要持续修改的，初始值需要被设为 nil，并且需要被 retain
    CBMutableCharacteristic *charater = [[CBMutableCharacteristic alloc] initWithType:characteristicsUuid properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    self.character = charater;
    
    CBUUID *serviceUuid = [CBUUID UUIDWithString:@"E7B5EC08-1D8E-46BA-A79B-5176C7D4838F"];
    CBMutableService *services = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
    services.characteristics = @[charater];
    
    [self.peripheralManager addService:services];
    
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[serviceUuid], CBAdvertisementDataLocalNameKey: @"RCClient"}];
    
}

- (void)stopAdvertisement {
    if ([self.peripheralManager isAdvertising]) {
        [self.peripheralManager stopAdvertising];
    }
}

- (BOOL)sendData:(NSData *)data {
    return [self.peripheralManager updateValue:data forCharacteristic:self.character onSubscribedCentrals:nil];
}





@end
