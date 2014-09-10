//
//  BLEManagerDelegate.h
//  bleDevice
//
//  Created by Joshua Noble on 9/6/14.
//
//


#import <Foundation/Foundation.h>

@class ciBLE;

@protocol BLEManagerDelegate <NSObject>

- (void)didDiscoverBLE:(ciBLE *)ble;

@optional

- (void)didUpdateDiscoveredBLE:(ciBLE *)ble;
- (void)didConnectBLE:(ciBLE *)ble;
- (void)didLoadServiceBLE:(ciBLE *)ble;

- (void)didSubscribeCharacteristic:(ciBLE *)ble;
- (void)didUnsubscribeCharacteristic:(ciBLE *)ble;

- (void)didDisconnectBLE:(ciBLE *)ble;


@end
