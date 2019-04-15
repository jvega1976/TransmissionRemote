//
//  PreferencesController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/23/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>
#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PreferencesControllerDelegate <NSObject>

-(void)getConnector:(id)sender;

@end

@interface PreferencesController : NSTabViewController <RPCConnectorDelegate>

@property(nonatomic,strong)    RPCConnector *connector;
@property(nonatomic,strong)    TRSessionInfo *trSessionInfo;
@property(nonatomic)            MainViewController *mainViewController;
@property (nonatomic,strong) IBOutlet   NSTabView *preferencesViewTab;
@property (nonatomic,weak)     id<PreferencesControllerDelegate> delegate;

-(IBAction)setTorrentSessionInfo:(id)sender;

@end

NS_ASSUME_NONNULL_END
