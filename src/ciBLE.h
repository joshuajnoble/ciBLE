//
//  ciBLE.h
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

#import "BLEDelegate.h"
#import "BLEManagerDelegate.h"

@class BLEManager;

char data(NSData *data);
uint8_t dataByte(NSData *data);
int dataInt(NSData *data);
float dataFloat(NSData *data);

// default NULL (NULL = previous fixed ble uuid)
extern NSString *customUUID;

@interface ciBLE : NSObject<CBPeripheralDelegate>
{
}

@property(assign, nonatomic) id<BLEManagerDelegate> delegate;
@property(strong, nonatomic) CBPeripheral *peripheral;
@property(strong, nonatomic) BLEManager *bleManagerInst;

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *UUID;
@property(strong, nonatomic) NSData *advertisementData;
@property(strong, nonatomic) NSNumber *advertisementRSSI;
@property(assign, nonatomic) NSInteger advertisementPackets;
@property(strong, nonatomic) NSDate *lastAdvertisement;
@property(assign, nonatomic) NSInteger outOfRange;

- (void)connected;
- (void)disconnect;
- (void)send:(NSData *)data;

// this is slow and isn't super recommended
- (void)findAllCharacteristics;
// this is faster and is better but you have to know the service ID
- (void)findSelectedCharacteristics: (NSMutableArray*)characteristics forService:(CBUUID*)serviceId;
- (void)subscribeToCharacteristics:(NSMutableArray*)characteristics;

@end
