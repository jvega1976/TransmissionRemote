//
//  URLConfig.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 4/3/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "URLConfig.h"

NSURL* urlFromConfig(NSDictionary* config) {
    NSString *url = [NSString stringWithFormat:@"%@://%@:%@@%@:%d%@",
                     [config[TR_URL_CONFIG_SSL] boolValue] ? @"https" : @"http",
                     config[TR_URL_CONFIG_USER],
                     config[TR_URL_CONFIG_PASS],
                     config[TR_URL_CONFIG_HOST],
                     [config[TR_URL_CONFIG_PORT] intValue],
                     config[TR_URL_CONFIG_PATH]];
    return [NSURL URLWithString:url];
}

NSURL* defaultURL(void) {
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *urlConfigList = [store arrayForKey:TR_URL_CONFIG_KEY];
    if(!urlConfigList) {
        NSUserDefaults *defaults =  [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
        urlConfigList = [defaults arrayForKey:TR_URL_CONFIG_KEY];
    }
    if(urlConfigList) {
        NSInteger index = [urlConfigList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj[TR_URL_CONFIG_SVR] boolValue])
                return YES;
            return NO;
        }];
        if(index != NSNotFound)
            return urlFromConfig([urlConfigList objectAtIndex:index]);
    }
    return nil;
};


