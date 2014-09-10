//
//  cibleDelegateCpp.h
//  ble
//
//  Created by Joshua Noble on 8/6/14.
//
//

#ifndef ciBLEDelegateCpp_h
#define ciBLEDelegateCpp_h

bool ciBLEisScanning();
void ciBLEStartScan();
void ciBLEStopScan();

void ciBLEConnect(ciBLE *bleDevice);
void ciBLEDisconnect(ciBLE *bleDevice);
void ciBLELoadedService(ciBLE *bleDevice);

// yeah, I know
void ciBLESendData(void * delegate, unsigned char *data, int length );

void ciBLESubscribeCharacteristics( void * delegate, std::vector<std::string> ids );
void ciBLEUnsubscribeCharacteristics( void * delegate, std::vector<std::string> ids );

#endif
