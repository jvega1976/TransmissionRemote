//
//  TorrentActivityController.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#define CONTROLLER_ID_ACTIVITY   @"TorrentActivityController"

@interface TorrentActivityController: NSViewController

@property( nonatomic ) NSInteger  piecesCount;
@property( nonatomic ) long long  pieceSize;
@property( nonatomic ) NSData*    piecesBitmap;
@property( nonatomic ) int        torrentId;
@property( nonatomic ) BOOL       viewAppeared;

@end
