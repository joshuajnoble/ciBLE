//
//  BLEManager.mm
//  bleDevice
//
//  Created by Joshua Noble on 9/6/14.
//
//


#include <objc/message.h>

#import "BLEManager.h"

#import "ciBLE.h"

static CBUUID *service_uuid;

@interface BLEManager()
{
    NSTimer *rangeTimer;
    int rangeTimerCount;
    bool didUpdateDiscoveredBLEFlag;
    void (^cancelBlock)(void);
    bool isScanning;
}
@end

@implementation BLEManager

@synthesize delegate;
@synthesize bles;

+ (BLEManager *)sharedBLEManager
{
    static BLEManager *bleManagerInst;
    if (! bleManagerInst) {
        bleManagerInst = [[BLEManager alloc] init];
    }
    return bleManagerInst;
}

- (id)init
{
    
    self = [super init];
    
    if (self) {
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            service_uuid = [CBUUID UUIDWithString:(@"c97433f0-be8f-4dc8-b6f0-5343e6100eb4")];
//        });
//        CBUUID * myid = [CBUUID UUIDWithString:(@"2220")];
//        service_uuid = myid;
        
        bles = [[NSMutableArray alloc] init];
        
        central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}

- (bool)isBluetoothLESupported
{
    if ([central state] == CBCentralManagerStatePoweredOn)
        return YES;
    
    NSString *message;
    
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            message = @"This hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"This app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            message = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStateUnknown:
            // fall through
        default:
            message = @"Bluetooth state is unknown.";
            
    }

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth LE Support"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

#endif

    return NO;
}

- (void)startRangeTimer
{
    rangeTimerCount = 0;
    
    rangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(rangeTick:)
                                                userInfo:nil
                                                 repeats:YES];
    
}

- (void)stopRangeTimer
{
    [rangeTimer invalidate];
}

- (void) rangeTick:(NSTimer*)timer
{
    bool update = false;

    rangeTimerCount++;
    if ((rangeTimerCount % 60) == 0) {
        // NSLog(@"restarting scanning");
        
        [central stopScan];
        
        NSDictionary *options = nil;
        options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                              forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
//        CBUUID * myid = [CBUUID UUIDWithString:(@"2220")];
        //[central scanForPeripheralsWithServices:[NSArray arrayWithObject:service_uuid] options:options];
        [central scanForPeripheralsWithServices:[NSArray arrayWithObject:myid] options:options];
    }
    
    
    NSDate *date = [NSDate date];
    for (ciBLE *ble in bles) {
        if (!ble.outOfRange
            && ble.lastAdvertisement != NULL
            && [date timeIntervalSinceDate:ble.lastAdvertisement] > 2)
        {
            ble.outOfRange = true;
            update = true;
        }
    }
    
    if (update) {
        if (didUpdateDiscoveredBLEFlag) {
            [delegate didUpdateDiscoveredRFduino:nil];
        }
    }
}

- (void) subscribedToCharacteristic:(ciBLE *)ble characteristic:(NSString *)chara
{
    [delegate didSubscribeCharacteristic:ble characteristic:chara];
}

- (void) unsubscribedToCharacteristic:(ciBLE *)ble characteristic:(NSString *)chara
{
    [delegate didUnsubscribeCharacteristic:ble characteristic:chara];
}

#pragma mark - CentralManagerDelegate methods

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");

    ciBLE *ble = [self bleForPeripheral:peripheral];
    if (ble) {
        [ble connected];
        [delegate didConnectBLE:ble];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");

    void (^block)(void) = ^{
        if ([delegate respondsToSelector:@selector(didDisconnectRFduino:)]) {
            ciBLE *bleDevice = [self bleForPeripheral:peripheral];
            if (bleDevice) {
                [delegate didDisconnectBLE:bleDevice];
            }
        }
    };
    
    if (error.code) {
        cancelBlock = block;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Peripheral Disconnected with Error"
                                                        message:error.description
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
#endif
        
    }
    else
        block();
    
    if (peripheral) {
        [peripheral setDelegate:nil];
        peripheral = nil;
    }
}

- (ciBLE *)bleForPeripheral:(CBPeripheral *)peripheral
{
    for (ciBLE *ble in bles) {
        if ([peripheral isEqual:ble.peripheral]) {
            return ble;
        }
    }
    return nil;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // NSLog(@"didDiscoverPeripheral");

    NSString *uuid = NULL;
    if (peripheral.UUID) {
        // only returned if you have connected to the device before
        uuid = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, peripheral.UUID);
    } else {
        uuid = @"";
    }
    
    bool added = false;

    ciBLE *ble = [self bleForPeripheral:peripheral];
    if (! ble) {
        ble = [[ciBLE alloc] init];
        
        ble.bleManagerInst = self;

        ble.name = peripheral.name;
        ble.UUID = uuid;
        
        ble.peripheral = peripheral;
        
        added = true;
        
        [bles addObject:ble];
    }
    
    ble.advertisementData = nil;
    
    id manufacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData) {
        const uint8_t *bytes = (const uint8_t *) [manufacturerData bytes];
        int len = [manufacturerData length];
        // skip manufacturer uuid
        NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
        ble.advertisementData = data;
    }
    
    ble.advertisementRSSI = RSSI;
    ble.advertisementPackets++;
    ble.lastAdvertisement = [NSDate date];
    ble.outOfRange = false;
    
    if (added) {
        [delegate didDiscoverBLE:ble];
    } else {
        if (didUpdateDiscoveredBLEFlag) {
            [delegate didUpdateDiscoveredBLE:ble];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connect Failed"
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

#endif

}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)aCentral
{
    NSLog(@"central manager state = %d", [central state]);
    
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
    
    bool success = [self isBluetoothLESupported];
    if (success) {
        [self startScan];
    }
}

#pragma mark - UIAlertViewDelegate methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0) {
        cancelBlock();
    }
}

#endif

#pragma mark - BLE methods

- (bool)isScanning
{
    return isScanning;
}

- (void)startScan:(NSArray *)ids
{
    NSLog(@"startScan");
    
    isScanning = true;

    NSDictionary *options = nil;
    
    didUpdateDiscoveredBLEFlag = [delegate respondsToSelector:@selector(didUpdateDiscoveredRFduino:)];
    
    if (didUpdateDiscoveredBLEFlag)
    {
        options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    }

    [bles removeAllObjects];
    
    NSMutableArray *uuidArray = [NSMutableArray array];
    for (NSString* idString in ids)
    {
        [uuidArray addObject:[CBUUID UUIDWithString:(idString)]];
    }
    
    //CBUUID * myid = [CBUUID UUIDWithString:(@"2220")];
    //[central scanForPeripheralsWithServices:[NSArray arrayWithObject:service_uuid] options:options];
    
    [central scanForPeripheralsWithServices:uuidArray options:options];
    
    if (didUpdateDiscoveredBLEFlag)
    {
        [self startRangeTimer];
    }
}

- (void)stopScan
{
    NSLog(@"stopScan");
    
    if (didUpdateDiscoveredBLEFlag) {
        [self stopRangeTimer];
    }
    
    [central stopScan];
    isScanning = false;
}

- (void)connectBLE:(ciBLE *)rfduino
{
    NSLog(@"connectRFduino");
    
    [central connectPeripheral:[rfduino peripheral] options:nil];
}

- (void)disconnectBLE:(ciBLE *)ble
{
    NSLog(@"bleManagerInst disconnectPeripheral");
    
    [central cancelPeripheralConnection:ble.peripheral];
}

- (void)loadedServiceBLE:(id)ble
{
    if ([delegate respondsToSelector:@selector(didLoadServiceBLE:)]) {
        [delegate didLoadServiceBLE:ble];
    }
}

- (void)foundBLECharacteristics:(NSArray *)ids
{
    if ([delegate respondsToSelector:@selector(foundCharacteristicsBLE:)]) {
        [delegate foundCharacteristicsBLE:ids];
    }
}


- (void)foundBLEServices:(NSArray *)ids
{
    if ([delegate respondsToSelector:@selector(foundServicesBLE:)]) {
        [delegate foundServicesBLE:ids];
    }
}

@end
