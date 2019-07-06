//
//  SegueMoveTo.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/30/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "SegueMoveTo.h"
#import "MainViewController.h"
#import "MoveTorrentToController.h"

@implementation SegueMoveTo

- (void)perform {
    ((MoveTorrentToController*)self.destinationController).connector = ((MainViewController*)self.sourceController).connector;
     ((MoveTorrentToController*)self.destinationController).trId = ((TRInfo*)[((MainViewController*)self.sourceController).torrentArrayController selectedObjects].firstObject).trId;
    [super perform];
    
}
@end
