//
//  whatever.m
//  bleDevice
//
//  Created by Joshua Noble on 8/6/14.
//
//

#import "ciBLEDelegate.h"
#import "ciBLEApp.h"

@implementation ciBLEDelegate

@synthesize connectedBLE;

bool ciBLEIsScanning()
{
    return [[BLEManager sharedBLEManager] isScanning];
}

void ciBLEStartScan( NSArray *ids )
{
    [[BLEManager sharedBLEManager] startScan:ids];
}

void ciBLEStopScan()
{
    return [[BLEManager sharedBLEManager] stopScan];
}

void ciBLEConnect(ciBLE *ble)
{
    return [[BLEManager sharedBLEManager] connectBLE:ble];
}

void ciBLEDisconnect(ciBLE *ble)
{
    return [[BLEManager sharedBLEManager] disconnectBLE:ble];
}

void ciBLELoadedServiceBLE(ciBLE *ble)
{
    return [[BLEManager sharedBLEManager] loadedServiceBLE:ble];
}

void ciBLESendData(void * delegate, unsigned char* data, int length)
{
    NSData *nsdata = [NSData dataWithBytes:(void*)data length:length];
    [delegate sendData:nsdata];
}

void ciBLESubscribeCharacteristics( void * delegate, std::vector<std::string> ids )
{
    id nsstrings = [NSMutableArray new];
    std::for_each(ids.begin(), ids.end(), ^(std::string str) {
		id nsstr = [NSString stringWithUTF8String:str.c_str()];
		[nsstrings addObject:nsstr];
	});
    
    [delegate subscribeToCharacteristics:nsstrings];
}

void ciBLEUnsubscribeCharacteristics( void * delegate, std::vector<std::string> ids )
{
    //[(id) delegate subscribeToService: [NSString stringWithCString:service.c_str() encoding:[NSString defaultCStringEncoding]]];
    id nsstrings = [NSMutableArray new];
    std::for_each(ids.begin(), ids.end(), ^(std::string str) {
		id nsstr = [NSString stringWithUTF8String:str.c_str()];
		[nsstrings addObject:nsstr];
	});
    
    [delegate unsubscribeToCharacteristics:nsstrings];
}


- (void)setApplication:(ciBLEApp *)app
{
    application = app;
}


- (void)sendData:(NSData*) data
{
    [connectedBLE send:data];
}

- (void)didReceive:(NSData *)data
{
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    const char *cString = [newStr UTF8String];
    application->receivedData(cString);
}

- (void)didDiscoverBLE:(ciBLE *)bleDevice
{
    application->didDiscoverBLE(bleDevice);
}

- (void)didUpdateDiscoveredBLE:(ciBLE *)bleDevice
{
    application->didUpdateDiscoveredBLE(bleDevice);
}

- (void)didConnectBLE:(ciBLE *)bleDevice
{
    [bleDevice setDelegate:self];
    connectedBLE = bleDevice;
    application->didConnectBLE(bleDevice);
}

- (void)didLoadServiceBLE:(ciBLE *)ble
{
    application->didLoadServiceBLE(ble);
}

- (void)didDisconnectBLE:(ciBLE *)ble
{
    application->didDisconnectBLE(ble);
}

- (void) didSubscribeCharacteristic:(ciBLE *)ble characteristic:(NSString *)charaName
{
    // this needs to take a param
    std::string charaStr([charaName UTF8String]);
    application->subscribedCharacteristic(charaStr);
}


- (void) didUnsubscribeCharacteristic:(ciBLE *)ble characteristic:(NSString *)charaName
{
    std::string charaStr([charaName UTF8String]);
    application->unsubscribedCharacteristic(charaStr);
}

- (void) foundServicesBLE:( NSArray *) ids
{
    
    int count = [ids count];
    std::string *array = new std::string[count];
    int i = 0;
    for(CBUUID *cbid in ids) {
        //std::string str( [cbid.UUIDString UTF8String] );
        std::string str( [[self representativeString:cbid] UTF8String] );
        array[i++] = str;
    }
    
    application->foundServices( array );
}

- (void) foundCharacteristicsBLE:( NSArray *) ids
{
    
    int count = [ids count];
    std::string *array = new std::string[count];
    int i = 0;
    for(CBUUID *cbid in ids) {
        //std::string str( [cbid.UUIDString UTF8String] );
        std::string str( [[self representativeString:cbid] UTF8String] );
        array[i++] = str;
    }
    
    application->foundCharacteristics( array );
}


- (id) init
{
    bleManager = [BLEManager sharedBLEManager];
    bleManager.delegate = self;
    return self;
}

- (NSString *)representativeString:(CBUUID* )cbid
{
    NSData *data = (NSData *) cbid;
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = (const unsigned char *) [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}


@end