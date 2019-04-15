//
//  RPCServerConfig.m
//  Holds transmission remote rpc settings

#import "RPCServerConfig.h"
#import "URLConfig.h"

static NSString * const CODER_NAME = TR_URL_CONFIG_NAME;
static NSString * const CODER_RPC_PATH = TR_URL_CONFIG_PATH;
static NSString * const CODER_REQ_AUTH = TR_URL_CONFIG_AUTH;
static NSString * const CODER_USER_NAME = TR_URL_CONFIG_USER;
static NSString * const CODER_USER_PASSWORD =TR_URL_CONFIG_PASS;
static NSString * const CODER_PORT = TR_URL_CONFIG_PORT;
static NSString * const CODER_HOST = TR_URL_CONFIG_HOST;
static NSString * const CODER_USE_SSL = TR_URL_CONFIG_SSL;
static NSString * const CODER_DEFAULT_SERVER = TR_URL_CONFIG_SVR;
static NSString * const CODER_REFRESH_TIMEOUT = TR_URL_CONFIG_REFRESH;
static NSString * const CODER_REQUEST_TIMEOUT = TR_URL_CONFIG_REQUEST;
static NSString * const CODER_SHOW_FREESPACE =TR_URL_CONFIG_FREE;

@implementation RPCServerConfig

+(RPCServerConfig*)initFromPList:(NSDictionary *)plist {
    RPCServerConfig *serverConfig;
    serverConfig = [RPCServerConfig alloc];
    return [serverConfig initFromPList:plist];
}

// init with default params
- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _name = RPC_DEFAULT_NAME;
        _host = RPC_DEFAULT_HOST;
        _port = RPC_DEFAULT_PORT;
        _useSSL = RPC_DEFAULT_USE_SSL;
        _rpcPath = RPC_DEFAULT_PATH;
        _refreshTimeout = RPC_DEFAULT_REFRESH_TIME;
        _requestTimeout = RPC_DEFAULT_REQUEST_TIMEOUT;
        _showFreeSpace = RPC_DEFAULT_SHOWFREESPACE;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"RPCServerConfig[%@://%@:%i%@, refresh:%is, request timeout: %is]",
            _useSSL ? @"https" : @"http",
            _host,
            _port,
            _rpcPath,
            _refreshTimeout,
            _requestTimeout ];
}

- (NSString *)urlString
{
    if( ![_rpcPath hasPrefix:@"/"] )
        _rpcPath = [NSString stringWithFormat:@"/%@", _rpcPath];
    
    return [NSString stringWithFormat:@"%@://%@:%i%@", _useSSL ? @"https" : @"http", _host, _port, _rpcPath];
}

#pragma mark - NSCoding protocol imp

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if( self )
    {
        _name = [aDecoder decodeObjectForKey:CODER_NAME];
        _rpcPath = [aDecoder decodeObjectForKey:CODER_RPC_PATH];
        _userName = [aDecoder decodeObjectForKey:CODER_USER_NAME];
        _userPassword = [aDecoder decodeObjectForKey:CODER_USER_PASSWORD];
        _port = [aDecoder decodeIntForKey:CODER_PORT];
        _host = [aDecoder decodeObjectForKey:CODER_HOST];
        _useSSL = [aDecoder decodeBoolForKey:CODER_USE_SSL];
        _defaultServer =  [aDecoder decodeBoolForKey:CODER_DEFAULT_SERVER];
        _refreshTimeout = [aDecoder decodeIntForKey:CODER_REFRESH_TIMEOUT];
        _requestTimeout = [aDecoder decodeIntForKey:CODER_REQUEST_TIMEOUT];
        _showFreeSpace = [aDecoder decodeBoolForKey:CODER_SHOW_FREESPACE];
        _requireAuth = [aDecoder decodeBoolForKey:CODER_REQ_AUTH];
    }
    
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:CODER_NAME];
    [coder encodeObject:self.rpcPath forKey:CODER_RPC_PATH];
    [coder encodeObject:self.host forKey:CODER_HOST];
    [coder encodeObject:self.userName forKey:CODER_USER_NAME];
    [coder encodeObject:self.userPassword forKey: CODER_USER_PASSWORD];
    [coder encodeInt:self.port forKey:CODER_PORT];
    [coder encodeInt:self.refreshTimeout forKey: CODER_REFRESH_TIMEOUT];
    [coder encodeInt:self.requestTimeout forKey:CODER_REQUEST_TIMEOUT];
    [coder encodeBool:self.requireAuth forKey:CODER_REQ_AUTH];
    [coder encodeBool:self.useSSL forKey:CODER_USE_SSL];
    [coder encodeBool:self.showFreeSpace forKey:CODER_SHOW_FREESPACE];
    [coder encodeBool:self.defaultServer forKey:CODER_DEFAULT_SERVER];
}

- (NSDictionary *)plist
{
    NSDictionary *pList = @{
                            CODER_NAME : _name,
                            CODER_RPC_PATH : _rpcPath,
                            CODER_HOST : _host,
                            CODER_PORT : @(_port),
                            CODER_USE_SSL : @(_useSSL),
                            CODER_USER_NAME : _userName,
                            CODER_USER_PASSWORD : _userPassword,
                            CODER_REQ_AUTH : @(_requireAuth),
                            CODER_REFRESH_TIMEOUT : @(_refreshTimeout),
                            CODER_REQUEST_TIMEOUT : @(_refreshTimeout),
                            CODER_SHOW_FREESPACE : @(_showFreeSpace),
                            CODER_DEFAULT_SERVER : @(_defaultServer)
                            };
    
    return pList;
}

- (instancetype)initFromPList:(NSDictionary *)plist
{
    self = [super init];
    if( self )
    {
        if(plist[CODER_NAME])
            _name = plist[CODER_NAME];
        if(plist[CODER_RPC_PATH])
            _rpcPath = plist[CODER_RPC_PATH];
        if(plist[CODER_HOST])
            _host = plist[CODER_HOST];
        if(plist[CODER_PORT])
            _port = [plist[CODER_PORT] intValue];
        if(plist[CODER_USE_SSL])
            _useSSL = [plist[CODER_USE_SSL] boolValue];
        if(plist[CODER_REQ_AUTH])
            _requireAuth = [plist[CODER_REQ_AUTH] boolValue];
        if(plist[CODER_USER_NAME])
            _userName = plist[CODER_USER_NAME];
        if(plist[CODER_USER_PASSWORD])
            _userPassword = plist[CODER_USER_PASSWORD];
        if(plist[CODER_REFRESH_TIMEOUT])
            _refreshTimeout = [plist[CODER_REFRESH_TIMEOUT] intValue];
        else
            _refreshTimeout = 10;
        if(plist[CODER_REQUEST_TIMEOUT])
            _requestTimeout = [plist[CODER_REQUEST_TIMEOUT] intValue];
        else
            _requestTimeout = 60;
        if(plist[CODER_DEFAULT_SERVER])
            _defaultServer = [plist[CODER_DEFAULT_SERVER] boolValue];
        if(plist[CODER_SHOW_FREESPACE])
            _showFreeSpace = [plist[CODER_SHOW_FREESPACE] boolValue];
        else
            _showFreeSpace = YES;
    }
    
    return self;
}

-(NSURL*)configURL {
    NSString *url = [NSString stringWithFormat:@"%@://%@:%@@%@:%d%@",
                    _useSSL ? @"https" : @"http",
                    _userName,
                    _userPassword,
                    _host,
                    _port,
                    _rpcPath];
    return [NSURL URLWithString:url];
}
@end
