//
//  rSolarController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 04.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rSolarController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>

{
   
   IBOutlet UILabel*       KT;
   IBOutlet UILabel*       KV;
   IBOutlet UILabel*       KR;
   IBOutlet UILabel*       BO;
   IBOutlet UILabel*       BM;
   IBOutlet UILabel*       BU;
   IBOutlet UIImageView*   Pumpe;
   
   NSString*               ServerPfad;
   int                     isDownloading;
   int                     lastDataZeit;
   NSString*               SolarDataVonHeuteString;
   NSString*               lastSolarDataString;
   
}
@property (weak, nonatomic) IBOutlet UILabel *     kt;
@property (weak, nonatomic) IBOutlet UILabel *     kv;
@property (weak, nonatomic) IBOutlet UILabel *     kr;
@property (weak, nonatomic) IBOutlet UILabel *     bo;
@property (weak, nonatomic) IBOutlet UILabel *     bm;
@property (weak, nonatomic) IBOutlet UILabel *     bu;
@property (weak, nonatomic) IBOutlet UITextField * urlfeld;
@property (weak, nonatomic) IBOutlet UIWebView *   webfenster;
@property (weak, nonatomic) IBOutlet UILabel *     solardata;
@property (weak, nonatomic) IBOutlet UILabel *     heizung;
@property (weak, nonatomic) IBOutlet UIImageView * pumpe;
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;

@property (weak, nonatomic) IBOutlet UINavigationItem *backtaste;



- (IBAction)reportTextFieldGo:(id)sender;
- (NSDictionary*)SolarDataDicVonHeute;
- (int)lastDataZeitVon:(NSString*)derDatenString;

@end
