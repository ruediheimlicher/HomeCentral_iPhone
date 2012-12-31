//
//  rEingabeViewController.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 03.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import "rHomeController.h"
#import "rEingabeController.h"

#define PW "ideur00"



@interface rHomeController ()

@end

@implementation rHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   HomeCentralURL = @"http://ruediheimlicher.dyndns.org";
   //[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
   self.ipfeld.text = [[rVariableStore sharedInstance] IP];

   self.WochentagArray = [NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA", @"SO",nil];
   self.aktuellerRaum =0;
   NSString *WochenplanString = [self Wochenplan];
   self.wochenplanarray = [WochenplanString componentsSeparatedByString:@"\n"];
   //NSLog(@"wochenplanarray: %@",[self.wochenplanarray description]);
  
   
    NSCalendar* heutekalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
   [heutekalender setFirstWeekday:2];
   int wochentagindex = [heutekalender ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]]-1;
   //NSLog(@"wochentagindex: %d",wochentagindex);
   
   /*
   NSDateComponents *weekdayComponents =[heutekalender components:( NSWeekdayCalendarUnit) fromDate:[NSDate date]];
   int wochentagint = [weekdayComponents weekday]; // Wochentag mit Sonntag=1
   NSLog(@"wochentagint: %d",wochentagint);
   */
   self.aktuellesObjekt=0;
   self.objektstepper.value = self.aktuellesObjekt;
   self.aktuellerWochentag= wochentagindex;
   self.wochentagseg.selectedSegmentIndex = wochentagindex;
   
   self.raumseg.selectedSegmentIndex=self.aktuellerRaum;
   
   
   UIImage *blueImage = [UIImage imageNamed:@"blauetaste.jpg"];
   UIImage *blueButtonImage = [blueImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
   
   UIImage *defButtonImage = [[UIImage imageNamed:@"helletaste.jpg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
   
   UIColor* hintergrund = self.halbstundetagplanfeld.backgroundColor;
   int stundenabstand = 70;
   
   CGRect tagplanframe = self.halbstundetagplanfeld.frame;
   tagplanframe.size.width = 24*stundenabstand + 100;
   self.halbstundetagplanfeld.frame = tagplanframe;
   
   tagplanframe = self.ganzstundetagplanfeld.frame;
   tagplanframe.size.width = 24*stundenabstand + 100;
   self.ganzstundetagplanfeld.frame = tagplanframe;
   
   self.tagplanscroller.contentSize = self.halbstundetagplanfeld.frame.size;
   
   
   // Felder fuer die Stunden aufbauen
   for (int stunde=0;stunde<24;stunde++)
   {
      CGRect stundefeld = CGRectMake(6+stundenabstand*stunde, 60, 20, 20);
      UILabel* std = [[UILabel alloc]initWithFrame:stundefeld];
      std.text=[NSString stringWithFormat:@"%d",stunde];
      std.textAlignment = NSTextAlignmentCenter;
      std.backgroundColor = hintergrund;
      [self.halbstundetagplanfeld addSubview:std];
      
      // Tasten fuer halbe Stunden
      
      CGRect tastenfeld = CGRectMake(20+stundenabstand*stunde, 10, 30, 40);
      rToggleTaste* hstdtaste0=[[rToggleTaste alloc]initWithFrame:tastenfeld];
      [hstdtaste0 setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
      [hstdtaste0 setBackgroundImage:defButtonImage forState:UIControlStateNormal];
      [hstdtaste0 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [hstdtaste0 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
      [hstdtaste0 setTag:100 +10*stunde];
      [hstdtaste0 addTarget:self
                   action:@selector(reportStundenTaste:)
         forControlEvents:UIControlEventTouchUpInside];
      [self.halbstundetagplanfeld addSubview:hstdtaste0];
      
      
      tastenfeld.origin.x += 32;
      UIButton* hstdtaste1=[[UIButton alloc]initWithFrame:tastenfeld];
      [hstdtaste1 setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
      [hstdtaste1 setBackgroundImage:defButtonImage forState:UIControlStateNormal];
      [hstdtaste1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [hstdtaste1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
      [hstdtaste1 setTag:100 +10*stunde+1];
      [hstdtaste1 addTarget:self
                    action:@selector(reportStundenTaste:)
          forControlEvents:UIControlEventTouchUpInside];
      [self.halbstundetagplanfeld addSubview:hstdtaste1];
      
      // Tasten fuer ganze Stunden
      
      CGRect gtastenfeld = CGRectMake(20+stundenabstand*stunde, 10, 60, 40);
      rToggleTaste* gstdtaste=[[rToggleTaste alloc]initWithFrame:gtastenfeld];
      [gstdtaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
      [gstdtaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
      [gstdtaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [gstdtaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
      [gstdtaste setTag:200 +10*stunde];
      [gstdtaste addTarget:self
                     action:@selector(reportStundenTaste:)
           forControlEvents:UIControlEventTouchUpInside];
      gstdtaste.hidden=NO;
      [self.ganzstundetagplanfeld addSubview:gstdtaste];

   
   }
   
   // Tagplananzeige: typ angegen
   self.halbstundetagplananzeige.typ=0;
   self.ganzstundetagplananzeige.typ=1;
   
   
   [self.onofftaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
   [self.onofftaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
   
   [self.onofftaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.onofftaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
   
   [self.stundentaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
   [self.stundentaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];

   [self.stundentaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.stundentaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
   
   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];
   self.webfenster.delegate = self;
   maxAnzahl = 12;
   [self.sendtaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.sendtaste setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

}

- (void)setTagplanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag
{
   int zeile = 56* raum + 7*objekt + wochentag;
   
   NSArray* ZeilenArray = [[self.wochenplanarray objectAtIndex:zeile]componentsSeparatedByString:@"\t"];
   //NSLog(@"setTagplanInRaum ZeilenArray: %@",[ZeilenArray description]);
   if ([ZeilenArray count]>4)
   {
      NSArray* ZeilenDataArray = [ZeilenArray subarrayWithRange:NSMakeRange(4, 6)];
      NSArray* StundenByteArray = [self StundenByteArrayVonByteArray:ZeilenDataArray];
      self.halbstundetagplananzeige.datenarray = StundenByteArray;
      self.ganzstundetagplananzeige.datenarray = StundenByteArray;
      [self.ganzstundetagplananzeige setNeedsDisplay];
      [self.halbstundetagplananzeige setNeedsDisplay];
      //NSLog(@"StundenByteArray: %@",[StundenByteArray description]);
      
      if ([ZeilenArray count]>13)
      {
         self.aktuellerObjektname = [ZeilenArray objectAtIndex:13];
         //NSLog(@"aktuellerObjektname: %@",self.aktuellerObjektname);
         self.objektname.text = [ZeilenArray objectAtIndex:13];
      }
      else
      {
         self.aktuellerObjektname =  @"Kein  Name";
         self.objektname.text = @"Kein  Name";
      }
      
      
      if ([ZeilenArray count]>14)
      {
         
         self.aktuellerObjekttyp = [[ZeilenArray objectAtIndex:14]intValue];
      }
      else
      {
         self.aktuellerObjekttyp=0;
      }
      //NSLog(@"aktuellerObjekttyp: %d",self.aktuellerObjekttyp);

      
      
      [self setTagPlanInRaum:raum fuerObjekt:objekt anWochentag:wochentag mitDaten:StundenByteArray];

   }
   else
   {
      self.objektname.text = @"Keine Daten";
      [self clearTagplan];
   }
}



- (void)setTagPlanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag mitDaten:(NSArray*)stundenbytearray
{
   //int bytezeile = 56*raum + 7*objekt + wochentag;// zeile: 56*$raum + 7*$objekt + $wochentag // aus eeprom.pl
   
   
   for (int stunde=0;stunde<24;stunde++)
   {
      int stundenwert = [[stundenbytearray objectAtIndex:stunde]intValue];
      
      /*
      int taste0tag = 100 + 10*stunde;
      //NSLog(@"stundenwert: %d taste0tag: %d",stundenwert,taste0tag);
      //NSLog(@"w0: %d w1: %d",(stundenwert & 0x02),(stundenwert & 0x01));
      [(UIButton*)[self.halbstundetagplanfeld viewWithTag:taste0tag]setSelected:((stundenwert & 0x02)>0)];

      
      int taste1tag = taste0tag +1;
      [(UIButton*)[self.halbstundetagplanfeld viewWithTag:taste1tag]setSelected:((stundenwert & 0x01)>0)];
      */
      // tags fuer halbe stunden
      int htaste0tag = 100 + 10*stunde;
      int htaste1tag = htaste0tag +1;
      
      // tags fuer ganze stunden
      int gtastetag = 200 + 10*stunde;
      
      switch (self.aktuellerObjekttyp)
      {
         case 0: // halbe Stunden
         {
            self.ganzstundetagplananzeige.hidden=YES;
            self.halbstundetagplananzeige.hidden=NO;
            self.ganzstundetagplanfeld.hidden=YES;
            self.halbstundetagplanfeld.hidden=NO;
            [self.halbstundetagplanfeld setNeedsDisplay];
            //NSLog(@"stundenwert: %d htaste0tag: %d",stundenwert,htaste0tag);
            //NSLog(@"w0: %d w1: %d",(stundenwert & 0x02),(stundenwert & 0x01));
            [(UIButton*)[self.halbstundetagplanfeld viewWithTag:htaste0tag]setSelected:((stundenwert & 0x02)>0)];
            [(UIButton*)[self.halbstundetagplanfeld viewWithTag:htaste1tag]setSelected:((stundenwert & 0x01)>0)];
            
         }break;
            
         case 1: // nur ganze Stunden
         {
            self.ganzstundetagplananzeige.hidden=NO;
            self.halbstundetagplananzeige.hidden=YES;
            self.halbstundetagplanfeld.hidden=YES;
            self.ganzstundetagplanfeld.hidden=NO;
            [self.ganzstundetagplanfeld setNeedsDisplay];

            [(UIButton*)[self.ganzstundetagplanfeld viewWithTag:gtastetag]setSelected:((stundenwert )>0)];
                     }break;
            
      } // switch ObjektTyp
      
      
   }
}

- (NSString*)Wochenplan
{
   NSString* ServerPfad =@"http://www.ruediheimlicher.ch/Data/eepromdaten/";
   NSString* DataSuffix=@"eepromdaten.txt";
   //NSLog(@"Wochenplan  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
   NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
   //NSLog(@"Wochenplan URL: %@",URL);
   NSStringEncoding *  enc=0;
   NSError* WebFehler=NULL;
   NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
   if (WebFehler)
   {
      NSLog(@"Wochenplan WebFehler: :%@",[[WebFehler userInfo]description]);
   }
   //NSLog(@"Wochenplan DataString: %@",DataString);
   
   return DataString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   //Scene2ViewController *destination =
   NSLog(@"prepareForSegue: %@",[segue description]);
   
   //destination.labelText = @"Arrived from Scene 1";
}

-(void)IPAktion:(NSNotification*)note
{
   NSString* IP = [[rVariableStore sharedInstance] IP];
   NSLog(@"IPAktion IP: %@",[[note userInfo]description]);
   //self.ipfeld.text = @"*";
}


- (IBAction)reportOnOff:(UIButton*)sender
{
   NSLog(@"reportOnOff");
   BOOL toggleIsOn = sender.selected;
   sender.selected = !sender.selected;
      if(toggleIsOn){
         NSLog(@"reportOnOff ON");
         //do anything else you want to do.
      }
      else {
         NSLog(@"reportOnOff OFF");
         //do anything you want to do.
      }
      //toggleIsOn = !toggleIsOn;
      //[self.onofftaste setImage:[UIImage imageNamed:toggleIsOn ? @"on.png" :@"off.png"] forState:UIControlStateNormal];
   
}

- (IBAction)reportClear:(id)sender
{
   NSLog(@"reportClear");
   // Felder fuer die Stunden aufbauen
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear" message:@"Tagplan löschen??" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:@"Ja",nil];
   [alert show];

}


- (void)clearTagplan
{
   NSLog(@"clearWochenplan");
   // Felder fuer die Stunden aufbauen
   for (int stunde=0;stunde<24;stunde++)
   {
      [(UIButton*)[self.halbstundetagplanfeld viewWithTag:100+10*stunde]setSelected:NO];
      [(UIButton*)[self.halbstundetagplanfeld viewWithTag:100+10*stunde+1]setSelected:NO];
   }

}



- (IBAction)reportRaumSeg:(UISegmentedControl*)sender
{
   self.aktuellesObjekt = 0;
   self.objektstepper.value = 0;
   self.aktuellerRaum = sender.selectedSegmentIndex;
   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];
}


- (IBAction)reportObjektStepper:(UIStepper*)sender
{
   self.aktuellesObjekt = (int)sender.value;
   NSLog(@"reportObjektStepper %d",(int)sender.value);
   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];

}


- (IBAction)reportWochentagSeg:(UISegmentedControl*)sender
{
   
   self.aktuellerWochentag = sender.selectedSegmentIndex;
   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];

}

- (IBAction)reportSendTaste:(UIButton *)sender
{
   NSLog(@"reportSendTaste");
}

- (IBAction)reportTWITaste:(UISwitch *)sender
{
   //NSLog(@"reportTWITaste state: %d",sender.state);
   if (sender.on)
   {
      [self setTWIState:YES];// TWI einschalten
   }
   else
   {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TWI-Status" message:@"TWI ausschalten?" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:@"Ja",nil];
                            [alert show];

   }
}

// Antworten auf Login-Button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if ([[alertView title]isEqualToString:@"TWI-Status"])
   {
      NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
      if([title isEqualToString:@"Ja"])
      {
         //NSLog(@"Button Ja was selected.");
         [self setTWIState:NO]; // TWI ausschalten
      }
      else if([title isEqualToString:@"Nein"])
      {
         //NSLog(@"TWI nicht ausschalten.");
         self.twitaste.on=YES;
         // Nichts tun
      }
      return;
   }
   if ([[alertView title]isEqualToString:@"Clear"])
   {
      NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
      if([title isEqualToString:@"Ja"])
      {
         NSLog(@"Clear: Button Ja was selected.");
         [self clearTagplan]; // Tagplan löschen
      }
      else
      {
         return;
      }
      return;
   }
}

- (void)setTWIState:(int)status
{
    //NSLog(@"setTWIstate status: %d",status);
   if (status)
   {
      //NSLog(@"setTWIstate TWI einschalten");
      self.sendtaste.enabled= NO;
      NSString* TWIStatusSuffix = [NSString stringWithFormat:@"pw=%s&status=%@",PW,@"1"];
      NSString* TWIStatusURLString =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralURL, TWIStatusSuffix];
      
      //NSLog(@"TWIStatusAktion TWIStatusURL: %@",TWIStatusURLString);
      
      NSURL *URL = [NSURL URLWithString:TWIStatusURLString];
      //NSLog(@"TWI ein URL: %@",URL);
     
      //NSError* err=0;
      //NSString *html = [NSString stringWithContentsOfURL:URL encoding:NSASCIIStringEncoding error:&err];
      //NSLog(@"TWI ON html: %@\nerr: %@",html,err);
      
      [self loadURL:URL];

   }
   else
   {
      NSLog(@"setTWIstate TWI ausschalten");
      
      NSString* TWIStatusSuffix = [NSString stringWithFormat:@"pw=%s&status=%@",PW,@"0"];
      NSString* TWIStatusURLString =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralURL, TWIStatusSuffix];
      
      //NSLog(@"TWIStatusAktion TWIStatusURL: %@",TWIStatusURLString);
      
      NSURL *URL = [NSURL URLWithString:TWIStatusURLString];
      NSLog(@"TWI aus URL: %@",URL);
      
      //NSError* err=0;
     // NSString *html = [NSString stringWithContentsOfURL:URL encoding:NSASCIIStringEncoding error:&err];
     // NSLog(@"TWI OFF html: %@\nerr: %@",html,err);
       [self loadURL:URL];
      NSMutableDictionary* confirmTimerDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      [confirmTimerDic setObject:[NSNumber numberWithInt:0]forKey:@"anzahl"];
      int sendResetDelay=1.0;
      //NSLog(@"EEPROMReadDataAktion  confirmTimerDic: %@",[confirmTimerDic description]);
      
      confirmStatusTimer=[NSTimer scheduledTimerWithTimeInterval:sendResetDelay
                                                           target:self
                                                         selector:@selector(statusTimerFunktion:)
                                                         userInfo:confirmTimerDic
                                                          repeats:YES];

      
   }
}

- (void)statusTimerFunktion:(NSTimer*) derTimer
{
	NSMutableDictionary* statusTimerDic=(NSMutableDictionary*) [derTimer userInfo];
	//NSLog(@"statusTimerFunktion  maxAnzahl: %d  statusTimerDic: %@",maxAnzahl,[statusTimerDic description]);
   
	if ([statusTimerDic objectForKey:@"anzahl"])
	{
		int anz=[[statusTimerDic objectForKey:@"anzahl"] intValue];
      NSString* TWIStatus0URL;
		if (anz < maxAnzahl)
		{
			anz++;
			if (anz>1)
			{
            NSString* pw = [NSString stringWithUTF8String: PW];
            NSString* TWIStatus0URLSuffix = [NSString stringWithFormat:@"pw=%@&isstat0ok=1",pw];
            
            TWIStatus0URL =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralURL, TWIStatus0URLSuffix];
            [statusTimerDic setObject:[NSNumber numberWithInt:0] forKey:@"local"];
            
            NSURL *URL = [NSURL URLWithString:TWIStatus0URL];
            //NSLog(@"statusTimerFunktion  URL: %@",URL);
            [self loadURL:URL];
			}
			
			[statusTimerDic setObject:[NSNumber numberWithInt:anz] forKey:@"anzahl"];
         
         
			// Blinkanzeige im PW-Feld
			NSMutableDictionary* tempDataDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			if (anz%2==0)// gerade
			{
            //[self loadURL:URL];
            self.sendtaste.hidden=NO;
				[tempDataDic setObject:@"*" forKey:@"wait"];
			}
			else
			{
            self.sendtaste.hidden=YES;
				[tempDataDic setObject:@" " forKey:@"wait"];
			}
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"StatusWait" object:self userInfo:tempDataDic];
			
		}
		else
		{
			
			NSLog(@"statusTimerFunktion statusTimer invalidate");
			// Misserfolg an AVRClient senden
			NSMutableDictionary* tempDataDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"isstatusok"];
         if ([statusTimerDic objectForKey:@"local"] && [[statusTimerDic objectForKey:@"local"]intValue]==1 )
         {
            [tempDataDic setObject:[NSNumber numberWithInt:1] forKey:@"local"];
         }
         else
         {
            [tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"local"];
            
         }
			self.sendtaste.hidden=NO;
			[derTimer invalidate];
			
			
		}
		
	}
}



- (IBAction)reportStundenTaste:(rToggleTaste*)sender
{
   
   NSLog(@"reportStundenTaste: selected vor: %d tag: %d",sender.selected,sender.tag);
   sender.selected = !sender.selected;
}

- (NSArray*)StundenByteArrayVonByteArray:(NSArray*)bytearray
{
   /*
    Codierung:
    Typ Heizung
    24 Stunden
    Wert Bedeutung
    0       --    ganze Stunde aus
    1       -X    zweite halbe Stunde ein
    2       X-    erste halbe Stunde ein
    3       XX    ganze Stunde ein
    
    Daten:
    6 Bytes
    pro Byte 4 Stunden, Bit's von links nach rechts
    Wert: 207 Bitfolge: II -- II II
    Belegung fuer erste Stunde: Wert & 0xC0
    
    
    */
   //NSLog(@"ZeilenDataArray: %@",[ZeilenDataArray description]);
   
   // Array fuer Stundenwerte:
   NSMutableArray* StundenByteArray = [[NSMutableArray alloc]initWithCapacity:0];
   for (int byte=0;byte<6;byte++)
   {
      //NSLog(@"***byte: %d stundenwert: %d",byte,[[ZeilenDataArray objectAtIndex:byte]intValue]);
      int stundenwert = [[bytearray objectAtIndex:byte]intValue];
      int byte0 = stundenwert & 0xC0;
      //NSLog(@"byte0: %d",byte0);
      byte0 >>= 6;
      //NSLog(@"byte0 shift: %d",byte0);
      [StundenByteArray addObject:[NSNumber numberWithInt:byte0]];
      
      int byte1 = stundenwert & 0x30;
      //NSLog(@"byte1: %d",byte1);
      byte1 >>= 4;
      //NSLog(@"byte1 shift: %d",byte1);
      [StundenByteArray addObject:[NSNumber numberWithInt:byte1]];
      
      int byte2 = stundenwert & 0x0C;
      //NSLog(@"byte2: %d",byte2);
      byte2 >>= 2;
      //NSLog(@"byte2 shift: %d",byte2);
      [StundenByteArray addObject:[NSNumber numberWithInt:byte2]];
      
      int byte3 = stundenwert & 0x03;
      //NSLog(@"byte3: %d",byte3);
      [StundenByteArray addObject:[NSNumber numberWithInt:byte3]];
      
   }
   //NSLog(@"StundenByteArray: %@",[StundenByteArray description]);
   return (NSArray*)StundenByteArray;
}


- (void)loadURL:(NSURL *)URL
{
	//NSLog(@"loadURL: %@",URL);
	NSURLRequest *HCRequest = [ [NSURLRequest alloc] initWithURL: URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
   //	[[NSURLCache sharedURLCache] removeAllCachedResponses];
   //	NSLog(@"Cache mem: %d",[[NSURLCache sharedURLCache]memoryCapacity]);
   //	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:HCRequest];
   //	NSLog(@"loadURL:Vor loadRequest");
	if (HCRequest)
	{
      //NSLog(@"loadURL:Request OK");
      [self.webfenster  loadRequest:HCRequest];
	}
	
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
   //NSLog(@"webViewDidStartLoad");
   //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   //NSLog(@"webViewDidFinishLoad");
   NSRange CheckRange;
	NSString* Code_String= @"okcode=";
	//NSString* Status0_String= @"status0";
   NSString* Status0_String= @"status0+"; // Status 0 ist bestaetigt

	NSString* Status1_String= @"status1";

   NSString *HTML_Inhalt = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
   NSLog(@"HTML_Inhalt: %@",HTML_Inhalt);
   // Test, ob Webseite eine okcode-Antwort ist
	CheckRange = [HTML_Inhalt rangeOfString:Code_String];
	if (CheckRange.location < NSNotFound)
	{
		//NSLog(@"didFinishLoadForFrame: okcode= ist da");
      // isstatus0ok vorhanden??
		
		//NSString* status0_String= @"status0+";
		CheckRange = [HTML_Inhalt rangeOfString:Status0_String];
		if (CheckRange.location < NSNotFound)
		{
			//NSLog(@"didFinishLoadForFrame: status0+ ist da");
         self.sendtaste.enabled= YES;
         self.sendtaste.hidden=NO;
		//	[tempDataDic setObject:[NSNumber numberWithInt:1] forKey:@"status0"];
			if ([confirmStatusTimer isValid])
             {
                [confirmStatusTimer invalidate];
             }
		}
		else
		{
		//	[tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"status0"];
		}
      
      // end isstatus0ok

   }
   
   
   //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
