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
@property (nonatomic, strong) CBMutableCharacteristic *notifyCharacter;
@property (nonatomic, strong) CBMutableCharacteristic *writeCharacter;

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

    // 被订阅后就可以停止广播了，节省用电
    [self stopAdvertisement];
    self.status = RCConnect_Connected;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {

    self.status = RCConnect_NoConnected;
}

// 从 central 发来的信息会响应这个函数
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSData *data = [[requests objectAtIndex:0] value];
    NSString *centralCommand = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // central 主动关闭链接，这边需要自动开始 advertise
    if ([centralCommand isEqualToString:@"[EOM]"]) {
        self.status = RCConnect_NoConnected;
        [self startAdvertisement];
    }
}



#pragma mark - public
- (void)startAdvertisement {
    
    if ([self.peripheralManager isAdvertising]) {
        return;
    }
    
    CBUUID *notifyCharacteristicsUuid = [CBUUID UUIDWithString:@"7E656504-8EDD-46E7-AB82-D9F2CF3916C5"];
    CBUUID *writeCharacteristicsUuid = [CBUUID UUIDWithString:@"D20A441C-8B54-41B6-AD19-8BF4960B68F4"];
    
    // 被 subscribe 或者 write 的需要持续修改的，初始值需要被设为 nil，并且需要被 retain
    CBMutableCharacteristic *notifyCharater = [[CBMutableCharacteristic alloc] initWithType:notifyCharacteristicsUuid properties: CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    self.notifyCharacter = notifyCharater;
    
    CBMutableCharacteristic *writeCharater = [[CBMutableCharacteristic alloc] initWithType:writeCharacteristicsUuid properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    self.writeCharacter = writeCharater;
    
    CBUUID *serviceUuid = [CBUUID UUIDWithString:@"E7B5EC08-1D8E-46BA-A79B-5176C7D4838F"];
    CBMutableService *services = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
    services.characteristics = @[notifyCharater, writeCharater];
    
    [self.peripheralManager removeAllServices];
    [self.peripheralManager addService:services];
    
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[serviceUuid], CBAdvertisementDataLocalNameKey: @"RCClient"}];
}

- (void)stopAdvertisement {
    if ([self.peripheralManager isAdvertising]) {
        [self.peripheralManager stopAdvertising];
    }
}


- (BOOL)sendData:(NSData *)data {
    return [self.peripheralManager updateValue:data forCharacteristic:self.notifyCharacter onSubscribedCentrals:nil];
}


@end
