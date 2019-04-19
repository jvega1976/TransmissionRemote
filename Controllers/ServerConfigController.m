//
//  ServerConfigController.m
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "ServerConfigController.h"
#import "PreferencesController.h"
#import <CloudKit/CloudKit.h>
#import <objc/runtime.h>

@interface ServerConfigController () <RPCConnectorDelegate,
                                      NSTextFieldDelegate>

@property (nonatomic) NSMutableString *errorMessage;
@property (strong) IBOutlet NSButton *saveButton;

@end


@implementation ServerConfigController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void) viewWillAppear {
    [super viewWillAppear];
    [RPCServerConfigDB.sharedDB loadDB];
    [self setServerConfigList: RPCServerConfigDB.sharedDB.db];
    _errorMessage = [NSMutableString alloc];
    
    [self.view.window setContentSize:NSMakeSize(700, 400)];
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor windowBackgroundColor].CGColor;
    if(self.wizardMode) {
        self.view.window.title = @"Please enter a Server Configuration";
        _saveButton.title = @"Connect";
        _saveButton.target = self;
        _saveButton.action = @selector(reloadConnection:);
    }
    else
        _saveButton.title = @"Save";
}


-(IBAction)saveConfig:(id)sender {
    RPCServerConfigDB.sharedDB.db = _serverConfigList;
    [RPCServerConfigDB.sharedDB saveDB];
    
    if(!_wizardMode){
        RPCServerConfig *config = RPCServerConfigDB.sharedDB.defaultConfig;
       [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController stopRefreshing];
        [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController startRefreshingWithConfig:config];
        [(PreferencesController*)self.parentViewController setTorrentSessionInfo:self];
        
    }
}


-(IBAction)setDefaultServer:(id)sender {
    NSButton *button = sender;
    if ([button state] == NSControlStateValueOn) {
        NSInteger index = [_serverConfigList indexOfObjectPassingTest:^BOOL(id  obj, NSUInteger idx, BOOL * stop) {
            if (idx !=  [self.serverConfigArrayController selectionIndex] && [(RPCServerConfig*)obj defaultServer])
                return YES;
            return NO;
        }];
        if(index != NSNotFound)
            _serverConfigList[index].defaultServer = NO;
    }
}

-(IBAction)verifyAuthentication:(id)sender {
    NSButton *button = sender;
    if ([button state] == NSControlStateValueOff) {
        NSArray *serverList = [self.serverConfigArrayController selectedObjects];
        [serverList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [(RPCServerConfig*)obj setUserName:@""];
            [(RPCServerConfig*)obj setUserPassword:@""];
        }];
    }
}


-(IBAction)reloadConnection:(id)sender {
    //stop connecting to actual Server

   if(!_wizardMode)
       [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController stopRefreshing];
    RPCServerConfig *config = [_serverConfigList objectAtIndex:[_serverConfigArrayController selectionIndex]];
    if(_wizardMode) {
        [self saveConfig:self];
        [_mainViewController startRefreshingWithConfig:config];
    }
    else
        [(MainViewController*)((PreferencesController*)self.parentViewController).mainViewController startRefreshingWithConfig:config];
    if(_wizardMode)
        [self dismissViewController:self];
    else
        [self dismissViewController:self.parentViewController];
}


#pragma mark - NSControlTextEditingDelegate

- (BOOL)control:(NSControl *)control isValidObject:(id)obj {

    if([control.identifier isEqualToString: @"host"]) {
        if([(NSString*)obj isEqualToString:@""])
                return NO;
    }
    else if([control.identifier isEqualToString: @"rpcPath"]) {
        if([(NSString*)obj isEqualToString:@""])
            return NO;
    }
    return YES;
}
@end
