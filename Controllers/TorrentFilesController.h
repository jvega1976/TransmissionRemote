//
//  TorrentsFileController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/10/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSTransmissionRPC/NSTransmissionRPC.h>
#import "TransmissionRPCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSItem (FileEditing)

@property BOOL isNameEditable;

@end;

@interface TorrentFilesController : NSViewController

@property (strong,nonatomic) IBOutlet NSOutlineView *torrentFilesView;

@property RPCConnector  *connector;
@property  FSDirectory  *torrentFiles;
@property BOOL          viewAppeared;
@property int           torrentId;
@property (nonatomic)  NSString *fileName;

@end

NS_ASSUME_NONNULL_END
