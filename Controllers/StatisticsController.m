//
//  StatisticsController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/15/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "StatisticsController.h"
#import <NSTransmissionRPC/GlobalConsts.h>
@interface StatisticsController ()

@end

@implementation StatisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewDidDisappear {
    [self dismissViewController:self];
}

-(void)viewWillAppear {
    [self setCurrentTimeActive: formatHoursMinutes(_trSessionStats.currentSecondsActive)];
    [self setCumulativeTimeActive: formatHoursMinutes(_trSessionStats.cumulativeSecondsActive)];
    [self setDownloadSpeed:formatByteRate(_trSessionStats.downloadSpeed)];
    [self setUploadSpeed:formatByteRate(_trSessionStats.uploadSpeed)];
}

@end
