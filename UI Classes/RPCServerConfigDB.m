//
//  RPCServerConfigDB.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "RPCServerConfigDB.h"
#import "URLConfig.h"


@interface RPCServerConfigDB()

@property (nonatomic,readonly) NSString *dbFileName;

@end

// singlton for getting rpc data config
@implementation RPCServerConfigDB
{
    NSMutableArray *_configData;
}

// returns shared instance of config
+ (RPCServerConfigDB*)sharedDB
{
    static RPCServerConfigDB* _inst = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[RPCServerConfigDB alloc] initPrivate];
    });
    
    return _inst;
}

// closed init method
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"RPCServerConfigDB singlton" reason:@"RPCServerConfigDB : user singlton methods" userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    if( self )
    {
        _configData = [NSMutableArray array];
    }
    
    return self;
}

- (NSMutableArray *)db
{
    return _configData;
}

- (NSString*)dbFileName
{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[arr firstObject] stringByAppendingPathComponent:@"RPCServerConfigDB"];
}

- (void)loadDB
{   _configData = [NSMutableArray array];
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
    NSArray *configData = [NSMutableArray arrayWithArray:[store arrayForKey:TR_URL_CONFIG_KEY]];
    if(!configData)
        configData = [NSMutableArray arrayWithArray:[defaults arrayForKey:TR_URL_CONFIG_KEY]];
    if(configData)
        [configData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self->_configData addObject:[RPCServerConfig initFromPList:obj]];
        }];
}

- (void)saveDB
{
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
    NSMutableArray *configData = [NSMutableArray array];
    [_configData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [configData addObject:((RPCServerConfig*)obj).plist];
    }];
    [store setArray:configData forKey:TR_URL_CONFIG_KEY];
    [store synchronize];
    [defaults setObject:configData forKey:TR_URL_CONFIG_KEY];
    [defaults synchronize];
}


-(RPCServerConfig*)defaultConfig {
    NSInteger index = [_configData indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([(RPCServerConfig*)obj defaultServer])
           return YES;
        return NO;
    }];
    if(index != NSNotFound)
        return _configData[index];
    return nil;
}

@end
