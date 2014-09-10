//
//  ciBLEDelegate.h
//  bleDevice
//
//  Created by Joshua Noble on 8/5/14.
//
//

#pragma once

#import "BLEManagerDelegate.h"
#import "BLEManager.h"
#import "ciBLEApp.h"

//@class ciBLEApp;
@class BLEManager;
@class ciBLE;

@interface ciBLEDelegate : UIResponder<BLEManagerDelegate, BLEDelegate>
{
    ciBLEApp *application;
    
    @public
    BLEManager *bleManager;
}

@property(strong, nonatomic) ciBLE *connectedBLE;

- (id) init;

- (void)setApplication:(ciBLEApp *)app;
- (void)didDiscoverBLE:(ciBLE *)bleDevice;
- (void)didUpdateDiscoveredBLE:(ciBLE *)bleDevice;
- (void)didConnectBLE:(ciBLE *)bleDevice;
- (void)didLoadServiceBLE:(ciBLE *)bleDevice;
- (void)didDisconnectBLE:(ciBLE *)bleDevice;

- (void) foundServicesBLE:(NSArray *)ids;
- (void) foundCharacteristicsBLE:(NSArray *)ids;

- (void)sendData:(NSData*) data;

- (NSString *)representativeString:(CBUUID* )cbid;

@end

