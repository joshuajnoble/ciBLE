//
//  BLEManager.h
//  bleDevice
//
//  Created by Joshua Noble on 9/6/14.
//
//


#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "ciBLE.h"
#import "BLEManagerDelegate.h"

@interface BLEManager : NSObject <CBCentralManagerDelegate>
{
    CBCentralManager *central;
}

+ (BLEManager *)sharedBLEManager;

@property (nonatomic, assign) id<BLEManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *bles;

- (bool)isScanning;
- (void)startScan:(NSArray*)ids;
- (void)stopScan;

- (void)connectBLE:(ciBLE *)ble;
- (void)disconnectBLE:(ciBLE *)ble;

- (void)loadedServiceBLE:(ciBLE *)ble;
- (void)foundBLEServices:(NSArray *)ids;

- (void) subscribedToCharacteristic:(ciBLE *)ble;
- (void) unsubscribedToCharacteristic:(ciBLE *)ble;

@end
