//
//  RCBLEServer.m
//  RemoteController_OXServer
//
//  Created by heqichang on 12/17/15.
//  Copyright © 2015 heqichang. All rights reserved.
//

#import "RCBLEServer.h"
@import CoreBluetooth;

static NSString * const kRCServiceUUID = @"E7B5EC08-1D8E-46BA-A79B-5176C7D4838F";


@interface RCBLEServer ()<CBCentralManagerDelegate, CBPeripheralDelegate>


@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end


@implementation RCBLEServer

- (id)init {
    self = [super init];
    if (self) {
        self.status = RCConnect_BlueToothIsOff;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state){
        case CBCentralManagerStatePoweredOn:
            self.status = RCConnect_NoConnected;
            break;
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStatePoweredOff:
            self.status = RCConnect_BlueToothIsOff;
            break;
        default:
            break;
    }
}

// TODO: 有两台设备时怎么区分？使用 name 来区分!?
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([peripheral.name isEqualToString:@"RCClient"]) {
        NSLog(@"try connect");
        // 成功蓝牙链接，peripheral 需要被 retain
        self.peripheral = peripheral;
        [self.peripheral setDelegate:self];
        
        // 停止扫描，尝试链接
        [self.centralManager stopScan];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // TODO: 链接失败处理
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    // 更改状态
    self.status = RCConnect_Connected;
    
    // 寻找 service
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kRCServiceUUID];
    [self.peripheral discoverServices:@[serviceUUID]];
    
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // 蓝牙有时会自动断开，也可能是手动关闭手机蓝牙
    self.status = RCConnect_NoConnected;
    [self startScan];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        // 目前该 service 上只有一个 character，所以不用特指
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        // 找到 character 后，选择接收通知，一旦有值改变就会触发 - (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data = characteristic.value;
    NSString *commandString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([self.delegate respondsToSelector:@selector(ServerDidReadCommandString:)]) {
        [self.delegate ServerDidReadCommandString:commandString];
    }
}


#pragma mark - public
- (void)startScan {
    
    // 设备蓝牙不处于可用状态
    if (self.status != RCConnect_NoConnected) {
        return;
    }
    
    self.status = RCConnect_Scanning;
    
    // 搜索指定有该 service 的客户端
    CBUUID *serviceUuid = [CBUUID UUIDWithString:kRCServiceUUID];
    [self.centralManager scanForPeripheralsWithServices:@[serviceUuid] options:nil];
}

- (void)stopScan {
    self.status = RCConnect_NoConnected;
    [self.centralManager stopScan];
	
}



@end
