//
//  ciBLEApp.h
//  ble
//
//  Created by Joshua Noble on 8/5/14.
//
//

#ifndef cibleapp
#define cibleapp


#include "ciBLE.h"

class ciBLEApp
{
public:
    
    virtual void didDiscoverBLE(ciBLE *ble) = 0;
    virtual void didUpdateDiscoveredBLE(ciBLE *ble) = 0;
    virtual void didConnectBLE(ciBLE *ble) = 0;
    virtual void didLoadServiceBLE(ciBLE *ble) = 0;
    virtual void didDisconnectBLE(ciBLE *ble) = 0;
    
    virtual void receivedData( const char *data) = 0;
    virtual void foundServices( std::string *services) = 0;
    virtual void foundCharacteristics( std::string *services) = 0;
    
    virtual void subscribedCharacteristic( std::string characteristic ) = 0;
    virtual void unsubscribedCharacteristic( std::string characteristic ) = 0;

};
#endif
