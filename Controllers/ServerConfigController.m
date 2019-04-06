//
//  ServerConfigController.m
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "ServerConfigController.h"
#import "MainViewController.h"
#import "PreferencesController.h"
#import <CloudKit/CloudKit.h>
#import <objc/runtime.h>

@interface ServerConfigController () <RPCConnectorDelegate>

@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSUbiquitousKeyValueStore *store;
@property (nonatomic) NSMutableString *errorMessage;
@property (nonatomic) NSInteger refreshTimeOut;
@property (nonatomic) NSInteger requestTimeOut;

@end


@implementation ServerConfigController

- (void)viewDidLoad {
    [super viewDidLoad];
    _store = [NSUbiquitousKeyValueStore defaultStore];
    _defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
    _errorMessage = [NSMutableString alloc];
    _urlConfigList = [NSMutableArray array];
    NSDictionary *appDefaults = @{TR_URL_CONFIG_REFRESH:@(10),TR_URL_CONFIG_REQUEST:@(10)};
    _userDefaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_defaults initialValues:appDefaults];
    
     [self setUrlConfigList:[NSMutableArray arrayWithArray:[_store arrayForKey:TR_URL_CONFIG_KEY]]];
    if(!_urlConfigList)
        _urlConfigList = [NSMutableArray arrayWithArray:[_defaults arrayForKey:TR_URL_CONFIG_KEY]];
    //store return only immutable Objects, we need to change it to mutable Dictionary
    [_urlConfigList enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
        [self.urlConfigList setObject:dict atIndexedSubscript:idx];
    }];
    [self setRefreshTimeOut:[_store longLongForKey:TR_URL_CONFIG_REFRESH]];
    if(!_refreshTimeOut)
        [self setRefreshTimeOut: [_defaults integerForKey:TR_URL_CONFIG_REFRESH]];
    [self setRequestTimeOut:[_store longLongForKey:TR_URL_CONFIG_REQUEST]];
    if(!_requestTimeOut)
        [self setRequestTimeOut: [_defaults integerForKey:TR_URL_CONFIG_REQUEST]];
    
}


-(void) viewWillAppear {
    [super viewWillAppear];
    
    [self.view.window setContentSize:NSMakeSize(700, 400)];
}


-(IBAction)saveConfig:(id)sender {
    [_store setArray:_urlConfigList forKey:TR_URL_CONFIG_KEY];
    [_store setLongLong:_refreshTimeOut forKey:TR_URL_CONFIG_REFRESH];
    [_store setLongLong:_requestTimeOut forKey:TR_URL_CONFIG_REQUEST];
    [_store synchronize];
    [_defaults setObject:_urlConfigList forKey:TR_URL_CONFIG_KEY];
    [_defaults setInteger:_refreshTimeOut forKey:TR_URL_CONFIG_REFRESH];
    [_defaults setInteger:_requestTimeOut forKey:TR_URL_CONFIG_REQUEST];
    [_defaults synchronize];

    NSURL *url = ((MainViewController*)((PreferencesController*)self.parentViewController).mainViewController).urlConfig;
[(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController stopRefreshing];
[(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController startRefreshingWithURL:url refreshTime:(int)_refreshTimeOut andRequestTime:(int)_requestTimeOut];
    if(sender != self)
        [self dismissViewController:self.parentViewController];
}


-(IBAction)setDefaultServer:(id)sender {
    NSButton *button = sender;
    if ([button state] == NSControlStateValueOn) {
        NSInteger index = [_urlConfigList indexOfObjectPassingTest:^BOOL(id  obj, NSUInteger idx, BOOL * stop) {
            if (idx !=  [self.serverConfigArrayController selectionIndex] && [obj[TR_URL_CONFIG_SVR] boolValue])
                return YES;
            return NO;
        }];
        if(index != NSNotFound)
            [_urlConfigList[index] setValue:@(NO) forKey:TR_URL_CONFIG_SVR];
    }
}

-(IBAction)verifyAuthentication:(id)sender {
    NSButton *button = sender;
    if ([button state] == NSControlStateValueOff) {
        NSArray *url = [self.serverConfigArrayController selectedObjects];
        [url enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setObject:@"" forKey:TR_URL_CONFIG_USER];
            [obj setObject:@"" forKey:TR_URL_CONFIG_PASS];
        }];
    }
}


-(IBAction)reloadConnection:(id)sender {
    //stop connecting to actual Server

    [self saveConfig:self];
    [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController stopRefreshing];
    NSMutableDictionary *config = [_urlConfigList objectAtIndex:[_serverConfigArrayController selectionIndex]];
    NSURL* url = urlFromConfig(config);
    [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController startRefreshingWithURL:url refreshTime:(int)_refreshTimeOut andRequestTime:(int)_requestTimeOut];
    [self dismissViewController:self.parentViewController];
}

@end
