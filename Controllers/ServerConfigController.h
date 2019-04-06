//
//  ServerConfigController.h
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>
#import "URLConfig.h"

NS_ASSUME_NONNULL_BEGIN


@interface ServerConfigController : NSViewController

@property (nonatomic) NSMutableArray *urlConfigList;
@property (nonatomic) IBOutlet NSTableView *serverConfigView;
@property (nonatomic) IBOutlet NSArrayController *serverConfigArrayController;
@property (strong) IBOutlet NSUserDefaultsController *userDefaultsController;

-(IBAction)saveConfig:(id)sender;

@end

NS_ASSUME_NONNULL_END
