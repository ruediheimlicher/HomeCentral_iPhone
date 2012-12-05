//
//  rStromController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 04.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface rStromController : UIViewController <CPTPlotDataSource>
{
   
   IBOutlet UIWebView* WebFeld;
   NSString* ServerPfad;
   int                  lastDataZeit;
   NSString*            StromDataVonHeuteString;
   NSString*            lastStromDataString;
   NSTimer *            timer;
   IBOutlet CPTGraphHostingView *stromplotfeld;
   
   CPTXYGraph *         stromgraph;
}
@property (weak, nonatomic) IBOutlet UILabel *data;
@property (weak, nonatomic) IBOutlet UILabel *zeit;
@property (weak, nonatomic) IBOutlet UILabel *datum;

@property (weak, nonatomic) IBOutlet UILabel *leistungaktuell;
@property (readwrite,  nonatomic) IBOutlet CPTGraphHostingView *plotfeld;

- (NSDictionary*)StromDataDicVonHeute;
- (void)plot;
-(void)timerFired;
@end
