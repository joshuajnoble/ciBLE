//
//  ciBLE.m
//  bleDevice
//
//  Created by Joshua Noble on 9/6/14.
//
//


#import "ciBLE.h"
#import "BLEManager.h"

static const int max_data = 12;

// default NULL (NULL = previous fixed RFduino uuid)
NSString *customUUID = NULL;

static CBUUID *service_uuid;
static CBUUID *send_uuid;
static CBUUID *receive_uuid;
static CBUUID *disconnect_uuid;

char data(NSData *data)
{
    return (char)dataByte(data);
}

uint8_t dataByte(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (len ? *p : 0);
}

int dataInt(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (sizeof(int) <= len ? *(int*)p : 0);
}

float dataFloat(NSData *data)
{
    uint8_t *p = (uint8_t*)[data bytes];
    NSUInteger len = [data length];
    return (sizeof(float) <= len ? *(float*)p : 0);
}

// increment the 16-bit uuid inside a 128-bit uuid
static void incrementUuid16(CBUUID *uuid, unsigned char amount)
{
    NSData *data = uuid.data;
    unsigned char *bytes = (unsigned char *)[data bytes];
    unsigned char result = bytes[3] + amount;
    if (result < bytes[3])
        bytes[2]++;
    bytes[3] += amount;
}

@interface ciBLE()
{
    CBCharacteristic *send_characteristic;
    CBCharacteristic *disconnect_characteristic;
    bool loadedService;
}
@end

@implementation ciBLE

@synthesize delegate;
@synthesize bleManagerInst;
@synthesize peripheral;

@synthesize name;
@synthesize UUID;
@synthesize advertisementData;
@synthesize advertisementRSSI;
@synthesize advertisementPackets;
@synthesize outOfRange;

- (id)init
{
    NSLog(@"cible init");
    
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)connected
{
    NSLog(@"cible connected");
    
    service_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
    receive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];
    if (customUUID)
        incrementUuid16(receive_uuid, 1);
    send_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2222")];
    if (customUUID)
        incrementUuid16(send_uuid, 2);
    disconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
    if (customUUID)
        incrementUuid16(disconnect_uuid, 3);
    peripheral.delegate = self;
    
    [peripheral discoverServices:[NSArray arrayWithObject:service_uuid]];
}

// this is slow and isn't super recommended
- (void)findAllCharacteristics
{
    if(loadedService)
    {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service ];
        }
    }
}

// this is faster and is better but you have to know the service ID
- (void)findSelectedCharacteristics: (NSMutableArray*)characteristics forService:(CBUUID*)serviceId
{
    if(loadedService)
    {
        for (CBService *service in peripheral.services) {
            if( service.UUID == serviceId )
            {
                [peripheral discoverCharacteristics:characteristics forService:service];
            }
        }
    }
}

- (void)subscribeToCharacteristics:(NSMutableArray*)characteristics
{
    if(loadedService)
    {
        for (CBService *service in peripheral.services)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                int index = [characteristics indexOfObject:characteristic];
                if(index != -1)
                {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    [bleManagerInst subscribedToCharacteristic:self characteristic:characteristic.UUID];
                }
            }
        }
    }
}

- (void)unsubscribeToCharacteristics:(NSMutableArray*)characteristics
{
    if(loadedService)
    {
        for (CBService *service in peripheral.services)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                int index = [characteristics indexOfObject:characteristic];
                if(index != -1)
                {
                    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
            [bleManagerInst unsubscribedToCharacteristic:self];
        }
    }
}


#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)_peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices");
    NSMutableArray* idArray;
    
    int i = 0;
    
    for (CBService *service in peripheral.services) {
        
        idArray[i] = service.UUID;
        i++;
        
//        CBUUID *tservice_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
//        if ([service.UUID isEqual:tservice_uuid])
//        {
//            
//            CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];
//            CBUUID *tsend_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2222")];
//            CBUUID *tdisconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
//            
//            
//            NSArray *characteristics = [NSArray arrayWithObjects:treceive_uuid, tsend_uuid, tdisconnect_uuid, nil];
//            [peripheral discoverCharacteristics:characteristics forService:service];
//        }
        
        // instead just broadcast that we found services and let users pick what charas
        // they want to subscribe to
    }
    
    [bleManagerInst foundBLEServices:idArray];
}
- (void)peripheral:(CBPeripheral *)_peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService");
    for (CBService *service in peripheral.services) {
        CBUUID *tservice_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
        if ([service.UUID isEqual:tservice_uuid]) {
            
            // just need a way to say what service you want and then subscribe
            
//            for (CBCharacteristic *characteristic in service.characteristics) {
//                
//                CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];
//                CBUUID *tsend_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2222")];
//                CBUUID *tdisconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];
//                
//                if ([characteristic.UUID isEqual:treceive_uuid]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                } else if ([characteristic.UUID isEqual:tsend_uuid]) {
//                    send_characteristic = characteristic;
//                } else if ([characteristic.UUID isEqual:tdisconnect_uuid]) {
//                    disconnect_characteristic = characteristic;
//                }
//            }
//            
            loadedService = true;
            [bleManagerInst loadedServiceBLE:self];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");
    CBUUID *treceive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];
    if ([characteristic.UUID isEqual:treceive_uuid]) {
        SEL didReceive = @selector(didReceive:);
        if ([delegate respondsToSelector:didReceive]) {
            [delegate didReceive:characteristic.value];
        }
    }
}

#pragma mark - RFduino methods

- (void)send:(NSData *)data
{
    if (! loadedService) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"please wait for ready callback" userInfo:nil];
    }
    
    if ([data length] > max_data) {
        @throw [NSException exceptionWithName:@"sendData" reason:@"max data size exceeded" userInfo:nil];
    }
    
    [peripheral writeValue:data forCharacteristic:send_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)disconnect
{
    NSLog(@"cible disconnect");
    
    if (loadedService) {
        NSLog(@"writing to disconnect characteristic");
        // fix for iOS SDK 7.0 - at least one byte must now be transferred
        uint8_t flag = 1;
        NSData *data = [NSData dataWithBytes:(void*)&flag length:1];
        [peripheral writeValue:data forCharacteristic:disconnect_characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    
    [bleManagerInst disconnectBLE:self];
}

@end
