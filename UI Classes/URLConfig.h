//
//  URLConfig.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 4/3/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TR_URL_DEFAULTS     @"TransmissionRemote"

#define TR_URL_CONFIG_KEY   @"URLConfigList"
#define TR_URL_ACTUAL_KEY   @"ActualURL"

#define TR_URL_CONFIG_NAME  @"name"
#define TR_URL_CONFIG_HOST  @"host"
#define TR_URL_CONFIG_PORT  @"port"
#define TR_URL_CONFIG_USER  @"userName"
#define TR_URL_CONFIG_PASS  @"userPassword"
#define TR_URL_CONFIG_SSL   @"useSSL"
#define TR_URL_CONFIG_AUTH  @"requireAuth"
#define TR_URL_CONFIG_SVR   @"defaultServer"
#define TR_URL_CONFIG_PATH  @"rpcPath"
#define TR_URL_CONFIG_FREE  @"showFreeSpace"
#define TR_URL_CONFIG_REFRESH   @"refreshTimeOut"
#define TR_URL_CONFIG_REQUEST   @"requestTimeOut"



#define DEFAULT_CONFIG defaultConfig()


NSURL* urlFromConfig(NSDictionary* config);

NSURL* defaultConfig(void);

