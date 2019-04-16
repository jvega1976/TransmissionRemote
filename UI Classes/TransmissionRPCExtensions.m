//
//  TransmissionRPCExtensions.m
//  Transmission Remote
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TransmissionRPCExtensions.h"
#import "CategorizationKitExtensions.h"
#import <objc/runtime.h>
#import <sqlite3.h>
#import <arpa/inet.h>

@implementation TRInfo (TransmissionRemote)

static char selectedFlag;

-(NSImage*)statusImage {
    if(self.isChecking)
        return [NSImage imageNamed:TR_STATUS_IMAGE_VERIFY];
    else if(self.isError)
        return [NSImage imageNamed:TR_STATUS_IMAGE_ERROR];
    else if(self.isWaiting)
        return [NSImage imageNamed:TR_STATUS_IMAGE_WAIT];
    else if(self.isStopped)
        return [NSImage imageNamed:TR_STATUS_IMAGE_STOP];
    else if(self.isDownloading)
        return [NSImage imageNamed:TR_STATUS_IMAGE_DOWNLOAD];
    else if(self.isSeeding)
        return [NSImage imageNamed:TR_STATUS_IMAGE_UPLOAD];
    else if(self.isFinished)
        return [NSImage imageNamed:TR_STATUS_IMAGE_COMPLETED];
    
    return [NSImage imageNamed:TR_STATUS_IMAGE_ALL];
}

-(NSString*)detailInfo {
    if(self.isError)
        return [NSString stringWithFormat: NSLocalizedString(@"Error: %@", @""), self.errorString];
    else if(self.isSeeding)
       return [NSString stringWithFormat: NSLocalizedString(@"Seeding to %i of %i peers",@""),
                      self.peersGettingFromUs, self.peersConnected ];
    else if(self.isDownloading)
        return [NSString stringWithFormat: NSLocalizedString(@"Downloading from %i of %i peers, ETA: %@", @""),
                self.peersSendingToUs, self.peersConnected, self.etaTimeString ];
    else if (self.isStopped)
        return NSLocalizedString(@"Paused", @"TorrentListController torrent info");
    else if(self.isChecking)
        return  NSLocalizedString(@"Checking data ...", @"");
    else if(self.isFinished)
        return [NSString stringWithFormat:@"Completed"];
    else if(self.isWaiting)
        return self.statusString;
    return [NSString stringWithFormat:@"Unknown"];
}

-(void)setIsSelected:(BOOL)isSelected {
    objc_setAssociatedObject(self, &selectedFlag,[NSNumber numberWithBool:isSelected], OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)isSelected {
    if(((NSNumber*)objc_getAssociatedObject(self, &selectedFlag)).boolValue)
        return YES;
    else
        return NO;
}

-(NSInteger)sortValue {
    if(self.isError)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_ERROR];
    else if(self.isDownloading)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_DOWN];
    else if(self.isSeeding)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_SEED];
    else if(self.isWaiting)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_WAIT];
    else if(self.isStopped)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_STOP];
    else if(self.isChecking)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_CHECK];
    else if(self.isFinished)
        return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_COMPL];
    return [[Categories torrentCategories] sortIndexForCategoryWithTitle:TR_GL_TITLE_ALL];
}

@end

@implementation FSItem (TransmissionRemote)

-(NSImage*)priorityImage {
    switch (self.priority) {
        case TR_PRI_LOW:
            return [NSImage imageNamed:@"NSStatusPartiallyAvailable"];
            break;
        case TR_PRI_HIGH:
            return [NSImage imageNamed:@"NSStatusUnavailable"];
        default:
            return [NSImage imageNamed:@"NSStatusAvailable"];
            break;
    }
}

@end


@implementation TRPeerInfo (TransmissionRemote)

static char flagCode;
static char countryName;

-(NSImage*)clientImage {
    if ([[self.clientName lowercaseString] containsString:@"transmission"])
        return [NSImage imageNamed:TR_PEER_CLIENT_TRANSMISSION];
    else if ([[self.clientName lowercaseString] containsString:@"qbittorrent"])
        return [NSImage imageNamed:TR_PEER_CLIENT_QBITTORRENT];
    else if ([[self.clientName lowercaseString] containsString:@"bittorrent"])
        return [NSImage imageNamed:TR_PEER_CLIENT_BITTORRENT];
    else if ([[self.clientName lowercaseString] containsString:@"vuze"])
        return [NSImage imageNamed:TR_PEER_CLIENT_VUZE];
    else if ([[self.clientName lowercaseString] containsString:@"deluge"])
        return [NSImage imageNamed:TR_PEER_CLIENT_DELUGE];
    else if ([[self.clientName lowercaseString] containsString:@"µtorrent"])
        return [NSImage imageNamed:TR_PEER_CLIENT_UTORRENT];
    else
        return nil;
}

-(NSImage*)flagImage {
    if (self.ipAddress) {
        NSString *geoIPDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"GeoIP.db"];
        sqlite3 *database;
        if (sqlite3_open([geoIPDB UTF8String], &database) == SQLITE_OK) {
            NSString *stmt = [NSString stringWithFormat:@"select country,name from GeoIP,Countries where %u between fromIPInt and toIPInt and country=code",inet_network([self.ipAddress UTF8String])];
            const char *sql = [stmt UTF8String];
            sqlite3_stmt *selectStatement;
            if(sqlite3_prepare_v2(database, sql, -1, &selectStatement, NULL) == SQLITE_OK) {
                while(sqlite3_step(selectStatement) == SQLITE_ROW) {
                    
                    objc_setAssociatedObject(self, &flagCode,[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 0)], OBJC_ASSOCIATION_RETAIN);
                   objc_setAssociatedObject(self, &countryName,[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1)], OBJC_ASSOCIATION_RETAIN);
                    return [NSImage imageNamed:[NSString stringWithFormat:@"%@.png",self.flagCode]];
                }
            }
        }
        sqlite3_close(database);
    }
    return nil;
}

-(NSString*)countryName {
    return objc_getAssociatedObject(self, &countryName);
}

-(NSString*)flagCode {
    return objc_getAssociatedObject(self, &flagCode);
}

@end
