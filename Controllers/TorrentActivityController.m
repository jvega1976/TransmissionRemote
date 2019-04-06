//
//  TorrentActivityController.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 24.09.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TorrentActivityController.h"
#import "GlobalConsts.h"

@interface LegendView : NSView

@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic) NSData    *bits;
@property (nonatomic) NSData    *prevbits;
@property (nonatomic) CGFloat   pw;
@property (nonatomic) CGFloat   ph;

@end

@implementation NSBezierPath (BezierPathQuartzUtilities)
// This method works only in OS X v10.2 and later.
- (CGPathRef)quartzPath
{
    int i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = (int)[self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}
@end



@implementation LegendView

- (void)drawRect:(CGRect)rect
{
    if( !_bits )
        return;
    
    
    NSColor *cFilled = [NSColor systemGreenColor];
    NSColor *cEmpty = [NSColor systemBlueColor];
    [[NSColor whiteColor] setStroke];
    
    uint8_t *pb = (uint8_t*)_bits.bytes;
    uint8_t *prevb =  NULL;//_prevbits ? (uint8_t*)_prevbits.bytes : NULL;
    
    NSInteger maxc = _count;
    NSInteger shift = 0;
    
    for( NSInteger i = 0; i < maxc; i++ )
    {
        NSInteger row = i / _cols;
        NSInteger col = i % _cols;//- row * _cols;
        
        //NSLog(@"[%i,%i] - %i", row, col, i);
        
        uint8_t c = *pb;
        BOOL filled = ( (c >> shift) & 0x1 ) ? YES : NO;
        BOOL needAnimate = NO;
        if( prevb != NULL )
        {
            uint8_t prevc = *prevb;
            BOOL prevfilled = ( (prevc >> shift) & 0x1 ) ? YES : NO;
            needAnimate = prevfilled != filled;
        }
        
        shift++;
        if( shift > 7 )
        {
            shift = 0;
            pb++;
            
            if( prevb != NULL )
                prevb++;
        }
        
        // draw legend block
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:CGRectMake( col * _pw + 1, row * _ph + 1, _pw - 1, _ph - 1 )];
        filled ? [cFilled setFill] : [cEmpty setFill];
        
        if( needAnimate )
        {
            NSLog(@"Need animate piece");
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.path = [path quartzPath];
            layer.fillColor = cEmpty.CGColor;
            layer.lineWidth = 0;
            [self.layer addSublayer:layer];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            anim.duration = 1.0;
            anim.toValue = (__bridge id)(cFilled.CGColor);
            anim.timeOffset = 0.3;
            
            [layer addAnimation:anim forKey:nil];
        }
        else
            [path fill];
    }
}

@end


@interface TorrentActivityController ()

@property (weak, nonatomic) IBOutlet NSTextField *labelPiecesCount;
@property (weak, nonatomic) IBOutlet NSTextField *labelPieceSize;
@property (weak, nonatomic) IBOutlet NSTextField *labelRowsCount;
@property (weak, nonatomic) IBOutlet NSTextField *labelColumnsCount;
@property (nonatomic) IBOutlet NSScrollView *scrollView;



@end

@implementation TorrentActivityController

{
    CGFloat _rows;
    CGFloat _columns;
    
    LegendView *_legendView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _legendView = [[LegendView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height) ];
}


-(void)viewDidAppear {
    _viewAppeared = YES;
    
}


-(void)viewDidDisappear {
    _viewAppeared = NO;
}

- (void)setPiecesBitmap:(NSData *)piecesBitmap
{
    if( _legendView.bits )
        _legendView.prevbits = _legendView.bits;
    _piecesBitmap = piecesBitmap;
    _legendView.bits = piecesBitmap;
    
    [_legendView setNeedsDisplay:YES];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
     _legendView = [[LegendView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height) ];
    if( _legendView.bits )
        _legendView.prevbits = _legendView.bits;
    _legendView.bits = _piecesBitmap;
    self.labelPiecesCount.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Pieces count: %i", nil), _piecesCount];
    self.labelPieceSize.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Piece size: %@", nil), formatByteCount(_pieceSize)];
 
    _columns = 50.0;
    _rows = ceil( _piecesCount / _columns ) ;
    
    self.labelRowsCount.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Rows: %i", nil), (NSInteger)_rows];
    self.labelColumnsCount.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Columns: %i", nil), (NSInteger)_columns];
    
    CGSize  bs = self.scrollView.frame.size;
    CGFloat pw = bs.width/_columns;
    CGFloat ph = pw * 1.4;
    
 //   self.scrollView.contentSize =  CGSizeMake( pw * _columns, ph * _rows );
    

//    _legendView.backgroundColor = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    _legendView.rows = (NSInteger)_rows;
    _legendView.cols = (NSInteger)_columns;
    _legendView.count = _piecesCount;
    _legendView.pw = pw;
    _legendView.ph = ph;
    
    [self.scrollView addSubview:_legendView];
}

@end
