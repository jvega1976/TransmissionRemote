//
//  AddTorrentController.h
//  TransmissionRemote
//
//  Created by Johnny Vega on 3/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>


NS_ASSUME_NONNULL_BEGIN

@interface AddTorrentController : NSViewController  <RPCConnectorDelegate>

@property (nonatomic,strong) TorrentFile *torrentFile;
@property (nonatomic,strong) IBOutlet NSOutlineView *torrentFilesView;

@end

NS_ASSUME_NONNULL_END
