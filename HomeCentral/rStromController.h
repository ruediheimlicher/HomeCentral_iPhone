//
//  rStromController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 04.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "rStromDiagrammView.h"
@interface rStromController : UIViewController //<CPTPlotDataSource>
{
   
   IBOutlet UIWebView* WebFeld;
   NSString* ServerPfad;
   int                  lastDataZeit;
   NSString*            StromDataVonHeuteString;
   NSDictionary*        StromDicVonHeute;
   NSString*            lastStromDataString;
   
}
@property (weak, nonatomic) IBOutlet UILabel *data;
@property (weak, nonatomic) IBOutlet UILabel *zeit;
@property (weak, nonatomic) IBOutlet UILabel *datum;
@property (nonatomic,readwrite) int lastminute;
@property (nonatomic,readwrite) float zoomfaktorx;
@property (nonatomic,readwrite) float lastzoomfaktorx;

@property (weak, nonatomic) IBOutlet UILabel *leistungaktuell;
@property (weak, nonatomic) IBOutlet UIScrollView *diagrammscroller;
@property (weak, nonatomic) IBOutlet rStromDiagrammView *diagrammview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *anzeigeseg;
@property (weak, nonatomic) IBOutlet UIButton *RefreshTaste;


- (IBAction)reportRefresh:(id)sender;


- (IBAction)reportAnzeigeSeg:(UISegmentedControl *)sender;
- (void)switchAnzeigeSeg:(int)seg;
- (void)refreshData;
- (NSDictionary*)StromDataDicVonHeute;
- (NSDictionary*)DiagrammDatenDicVon:(NSArray*)DatenArray mitAnzahlDaten:(int)anz mitIndex:(NSArray*)index;

@end
