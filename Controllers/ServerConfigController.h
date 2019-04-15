//
//  ServerConfigController.h
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>
#import "MainViewController.h"
#import "RPCServerConfigDB.h"

NS_ASSUME_NONNULL_BEGIN


@interface ServerConfigController : NSViewController

@property (nonatomic) NSMutableArray<RPCServerConfig*>* serverConfigList;
@property (nonatomic) IBOutlet NSTableView *serverConfigView;
@property (nonatomic) IBOutlet NSArrayController *serverConfigArrayController;
@property (strong) MainViewController *mainViewController;
@property (nonatomic) BOOL wizardMode;


-(IBAction)saveConfig:(id)sender;

@end

NS_ASSUME_NONNULL_END
