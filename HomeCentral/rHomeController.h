//
//  rEingabeViewController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 03.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "rVariableStore.h"
#import "rToggleTaste.h"
#import "rTagplanAnzeige.h"

@interface rHomeController : UIViewController
{
   rToggleTaste* OnOffTaste;
   rToggleTaste* StundenTaste;
}
@property (weak, nonatomic) IBOutlet UIScrollView *tagplanscroller;
@property (weak, nonatomic) IBOutlet UIView *halbstundetagplanfeld;
@property (weak, nonatomic) IBOutlet UIView *ganzstundetagplanfeld;
@property (weak, nonatomic) IBOutlet rToggleTaste *taste0;
@property (weak, nonatomic) IBOutlet rToggleTaste *stundentaste;
@property (weak, nonatomic) IBOutlet UITextField *ipfeld;
@property (weak, nonatomic) IBOutlet UIStepper *wochentagstepper;
@property (weak, nonatomic) IBOutlet UIStepper *objektstepper;
@property (weak, nonatomic) IBOutlet UITextField *objektname;
@property (weak, nonatomic) IBOutlet UITextField *wochentag;

@property (weak, nonatomic) IBOutlet UISegmentedControl *raumseg;

@property (weak, nonatomic) IBOutlet UIButton *onofftaste;
@property (weak, nonatomic) IBOutlet UISegmentedControl *wochentagseg;
@property (nonatomic, readwrite) NSArray* WochentagArray;
@property (weak, nonatomic) IBOutlet rTagplanAnzeige *halbstundetagplananzeige;
@property (weak, nonatomic) IBOutlet rTagplanAnzeige *ganzstundetagplananzeige;

@property (nonatomic, readwrite) int aktuellerRaum;
@property (nonatomic, readwrite) int aktuellesObjekt;
@property (nonatomic, readwrite) NSString* aktuellerObjektname;
@property (nonatomic, readwrite) int aktuellerWochentag;
@property (nonatomic, readwrite) int aktuellerObjekttyp;

@property (nonatomic, readwrite) NSArray* wochenplanarray;


- (IBAction)reportStundenTaste:(id)sender;

- (IBAction)reportWochentagSeg:(id)sender;
- (IBAction)reportWochentag:(id)sender;

- (IBAction)reportRaumSeg:(id)sender;
- (IBAction)reportOnOff:(id)sender;
- (IBAction)reportClear:(id)sender;
- (IBAction)reportObjektStepper:(id)sender;

- (NSArray*)StundenByteArrayVonByteArray:(NSArray*)bytearray;
- (void)setTagPlanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag mitDaten:(NSArray*)stundenbytearray;
- (void)setTagplanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag;
- (void)clearWochenplan;
@end
