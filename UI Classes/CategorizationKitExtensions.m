//
//  CategorizationKitExtensions.m
//  Transmission Remote
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "CategorizationKitExtensions.h"

@implementation Label (TorrentLabel)

-(NSImage*)image {
    
    if ([self.title isEqualToString:TR_GL_TITLE_DOWN])
        return [NSImage imageNamed:TR_STATUS_IMAGE_DOWNLOAD];
    else if([self.title isEqualToString:TR_GL_TITLE_COMPL])
        return [NSImage imageNamed:TR_STATUS_IMAGE_COMPLETED];
    else if([self.title isEqualToString:TR_GL_TITLE_SEED])
        return [NSImage imageNamed:TR_STATUS_IMAGE_UPLOAD];
    else if([self.title isEqualToString:TR_GL_TITLE_ERROR])
        return [NSImage imageNamed:TR_STATUS_IMAGE_ERROR];
    else if([self.title isEqualToString:TR_GL_TITLE_STOP])
        return [NSImage imageNamed:TR_STATUS_IMAGE_STOP];
    else if([self.title isEqualToString:TR_GL_TITLE_WAIT])
        return [NSImage imageNamed:TR_STATUS_IMAGE_WAIT];
    else if([self.title isEqualToString:TR_GL_TITLE_CHECK])
        return [NSImage imageNamed:TR_STATUS_IMAGE_VERIFY];
    else if([self.title isEqualToString:TR_GL_TITLE_ACTIVE])
        return [NSImage imageNamed:TR_STATUS_IMAGE_ACTIVE];
    return [NSImage imageNamed:TR_STATUS_IMAGE_ALL];
}

@end

@implementation GroupLabel (TorrentLabel)


+(GroupLabel*)torrentLabels {
    
    NSMutableArray *labels = [NSMutableArray array];
    Label *c;
    NSPredicate *p;
    
    // Fill labels
    p = [NSPredicate predicateWithValue:YES];
    c = [Label label:TR_GL_TITLE_ALL withPredicate:p andSortIndex:999 isAlwaysVisible:YES];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isFinished == YES"];
    c = [Label label:TR_GL_TITLE_COMPL withPredicate:p andSortIndex:6 isAlwaysVisible:YES];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isDownloading == YES"];
    c = [Label label:TR_GL_TITLE_DOWN withPredicate:p andSortIndex:0 isAlwaysVisible:YES];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isWaiting == YES"];
    c = [Label label:TR_GL_TITLE_WAIT withPredicate:p andSortIndex:1 isAlwaysVisible:NO];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"downloadRate > 0 OR uploadRate > 0"];
    c = [Label label:TR_GL_TITLE_ACTIVE withPredicate:p andSortIndex:999 isAlwaysVisible:YES];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isSeeding == YES"];
    c = [Label label:TR_GL_TITLE_SEED withPredicate:p andSortIndex:5 isAlwaysVisible:YES];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isStopped == YES"];
    c = [Label label:TR_GL_TITLE_STOP withPredicate:p andSortIndex:2 isAlwaysVisible:NO];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isChecking == YES"];
    c = [Label label:TR_GL_TITLE_CHECK withPredicate:p andSortIndex:4 isAlwaysVisible:NO];
    [labels addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isError == YES"];
    c = [Label label:TR_GL_TITLE_ERROR withPredicate:p andSortIndex:3 isAlwaysVisible:NO];
    [labels addObject:c];
    
    GroupLabel *groupLabel = [GroupLabel groupwithLabels:labels];
    
    [groupLabel setVisibleLabelsPredicate:[NSPredicate predicateWithFormat:@"isVisible == YES"]];
    return groupLabel;
}

@end

