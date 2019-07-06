//
//  CategorizationKitExtensions.m
//  Transmission Remote
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "CategorizationKitExtensions.h"

@implementation Category (TorrentLabel)

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

@implementation Categories (TorrentLabel)


+(Categories*)torrentCategories {
    
    NSMutableArray *categoryList = [NSMutableArray array];
    Category *c;
    NSPredicate *p;
    
    // Fill Categories
    p = [NSPredicate predicateWithValue:YES];
    c = [Category categoryWithTitle:TR_GL_TITLE_ALL predicate:p andSortIndex:999 isAlwaysVisible:YES];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isFinished == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_COMPL predicate:p andSortIndex:6 isAlwaysVisible:YES];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isDownloading == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_DOWN predicate:p andSortIndex:0 isAlwaysVisible:YES];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isWaiting == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_WAIT predicate:p andSortIndex:1 isAlwaysVisible:NO];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"downloadRate > 0 OR uploadRate > 0"];
    c = [Category categoryWithTitle:TR_GL_TITLE_ACTIVE predicate:p andSortIndex:999 isAlwaysVisible:YES];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isSeeding == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_SEED predicate:p andSortIndex:5 isAlwaysVisible:YES];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isStopped == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_STOP predicate:p andSortIndex:2 isAlwaysVisible:NO];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isChecking == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_CHECK predicate:p andSortIndex:4 isAlwaysVisible:NO];
    [categoryList addObject:c];
    
    p = [NSPredicate predicateWithFormat:@"isError == YES"];
    c = [Category categoryWithTitle:TR_GL_TITLE_ERROR predicate:p andSortIndex:3 isAlwaysVisible:NO];
    [categoryList addObject:c];
    
    Categories *categories = [Categories categoriesWithCategoryArray:categoryList];
    
    [categories setVisibleCategoriesPredicate:[NSPredicate predicateWithFormat:@"isVisible == YES"]];
    return categories;
}

@end

