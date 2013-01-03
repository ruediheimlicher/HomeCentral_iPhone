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

#define TAGPLANBREITE		0x40	// 64 Bytes, 2 page im EEPROM

#define RAUMPLANBREITE		0x200	// 512 Bytes


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
   //[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
   self.ipfeld.text = [[rVariableStore sharedInstance] IP];

   self.WochentagArray = [NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA", @"SO",nil];
   self.aktuellerRaum =0;
   NSString *WochenplanString = [self readWochenplan];
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
   
   UIColor* hintergrund = self.tagplanfeld.backgroundColor;
   int stundenabstand = 70;
   
   CGRect tagplanframe = self.tagplanfeld.frame;
   tagplanframe.size.width = 24*stundenabstand + 100;
   self.tagplanfeld.frame = tagplanframe;
   self.tagplanscroller.contentSize = self.tagplanfeld.frame.size;
   
   
   // Felder fuer die Stunden aufbauen
   for (int stunde=0;stunde<24;stunde++)
   {
      CGRect stundefeld = CGRectMake(6+stundenabstand*stunde, 50, 20, 20);
      UILabel* std = [[UILabel alloc]initWithFrame:stundefeld];
      std.text=[NSString stringWithFormat:@"%d",stunde];
      std.textAlignment = NSTextAlignmentCenter;
      std.backgroundColor = hintergrund;
      [self.tagplanfeld addSubview:std];
      
      // Tasten fuer halbe Stunden
      
      CGRect tastenfeld = CGRectMake(20+stundenabstand*stunde, 10, 30, 40);
      UIButton* hstdtaste0=[[UIButton alloc]initWithFrame:tastenfeld];
      [hstdtaste0 setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
      [hstdtaste0 setBackgroundImage:defButtonImage forState:UIControlStateNormal];
      [hstdtaste0 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [hstdtaste0 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
      [hstdtaste0 setTag:100 +10*stunde];
      [hstdtaste0 addTarget:self
                   action:@selector(reportStundenTaste:)
         forControlEvents:UIControlEventTouchUpInside];
      [self.tagplanfeld addSubview:hstdtaste0];
      
      
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
      [self.tagplanfeld addSubview:hstdtaste1];
      
      // Tasten fuer ganze Stunden
      
      CGRect gtastenfeld = CGRectMake(20+stundenabstand*stunde, 10, 60, 40);
      UIButton* gstdtaste=[[UIButton alloc]initWithFrame:gtastenfeld];
      [gstdtaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
      [gstdtaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
      [gstdtaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [gstdtaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
      [gstdtaste setTag:500 +10*stunde];
      [gstdtaste addTarget:self
                     action:@selector(reportStundenTaste:)
           forControlEvents:UIControlEventTouchUpInside];
      gstdtaste.hidden=YES;
      [self.tagplanfeld addSubview:gstdtaste];

   
   }
   
   // Tagplananzeige: typ angegen
   //self.tagplananzeige.typ=0;
   //self.ganzstundetagplananzeige.typ=1;
   
   
   [self.onofftaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];
   [self.onofftaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
   
   [self.onofftaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.onofftaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
   
   [self.stundentaste setBackgroundImage:defButtonImage forState:UIControlStateNormal];
   [self.stundentaste setBackgroundImage:blueButtonImage forState:UIControlStateSelected];

   [self.stundentaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.stundentaste setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
   
   self.oldstundencodearray  = self.aktuellerstundencodearray;
   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];
   //[self.tagplananzeige setNeedsDisplay];
   
   
   HomeCentralAdresseString = @"http://ruediheimlicher.dyndns.org";
   HomeServerAdresseString = @"http://www.ruediheimlicher.ch";

   self.webfenster.delegate = self;
   maxAnzahl = 12;
   [self.sendtaste setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   [self.sendtaste setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

   
   // Datum
   NSDate *currDate = [NSDate date];   //Current Date
   
   NSDateFormatter *df = [[NSDateFormatter alloc] init];
   
   //Day
   [df setDateFormat:@"dd"];
   NSString* myDayString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   self.aktuellertag = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   
   //Month
   [df setDateFormat:@"MM"]; //MM will give you numeric "03", MMM will give you "Mar"
   NSString* myMonthString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   self.aktuellermonat = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   
   //Year
   [df setDateFormat:@"yy"];
   NSString* myYearString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   self.aktuellesjahr = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   //Hour
   [df setDateFormat:@"hh"];
   NSString* myHourString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   
   //Minute
   [df setDateFormat:@"mm"];
   NSString* myMinuteString = [NSString stringWithFormat:@"%@",[df stringFromDate:currDate]];
   
   //Second
   [df setDateFormat:@"ss"];
   NSString* mySecondString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
   
   //NSLog(@"Year: %@, Month: %@, Day: %@, Hour: %@, Minute: %@, Second: %@", myYearString, myMonthString, myDayString, myHourString, myMinuteString, mySecondString);
   
}

- (NSMutableArray*)setTagplanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag
{
   // eventuell TWI-Timer reseten
   if ([TWIStatusTimer isValid])
   {
      NSMutableDictionary* TWITimerDic=(NSMutableDictionary*) [TWIStatusTimer userInfo];
      [TWITimerDic setObject:[NSNumber numberWithInt:maxAnzahl] forKey:@"twitimeoutanzahl"];
   }
   int zeile = 56* raum + 7*objekt + wochentag;
   
   NSArray* ZeilenArray = [[self.wochenplanarray objectAtIndex:zeile]componentsSeparatedByString:@"\t"];
   //NSLog(@"setTagplanInRaum ZeilenArray: %@",[ZeilenArray description]);
   if ([ZeilenArray count]>4)
   {
      // Array mit 6 Bytes fuer je 4 Tasten. Int-Werte
      NSArray* ZeilenDataArray = [ZeilenArray subarrayWithRange:NSMakeRange(4, 6)];
      
      
      // Array mit 24 int 0..3 mit den Angaben fuer jede Stunde
      //NSMutableArray* StundenByteArray = [self StundenCodeArrayVonByteArray:ZeilenDataArray];
      
      self.aktuellerstundencodearray  = [self StundenCodeArrayVonByteArray:ZeilenDataArray];
      self.tagplananzeige.datenarray = self.aktuellerstundencodearray;
//      self.ganzstundetagplananzeige.datenarray = self.aktuellerstundencodearray;
//      [self.ganzstundetagplananzeige setNeedsDisplay];
      [self.tagplananzeige setNeedsDisplay];
      
      //[self.tagplandic setObject:self.aktuellerstundencodearray forKey:@"stundencodearray"];
      
      
      //NSLog(@"StundenByteArray: %@",[self.aktuellerstundencodearray description]);
      
      if ([ZeilenArray count]>13)
      {
         self.aktuellerObjektname = [ZeilenArray objectAtIndex:13];
         //NSLog(@"aktuellerObjektname: %@",self.aktuellerObjektname);
         self.objektname.text = [ZeilenArray objectAtIndex:13];
      }
      else
      {
         self.aktuellerObjektname =  @"Kein_Name";
         self.objektname.text = @"Kein_Name";
      }
      //[self.tagplandic setObject:self.objektname.text forKey:@"objektname"];

      
      
      if ([ZeilenArray count]>14)
      {
         
         self.aktuellerObjekttyp = [[ZeilenArray objectAtIndex:14]intValue];
      }
      else
      {
         self.aktuellerObjekttyp=0;
      }
      //NSLog(@"setTagplan aktuellerObjekttyp: %d",self.aktuellerObjekttyp);
      
      self.tagplananzeige.typ = self.aktuellerObjekttyp;
       
      [self setTagPlanInRaum:raum fuerObjekt:objekt anWochentag:wochentag mitDaten:self.aktuellerstundencodearray];
      
      return nil;
   }
   else
   {
      self.objektname.text = @"Keine Daten";
      [self clearTagplan];
      
   }
   return nil;
}


- (void)setTagPlanInRaum:(int)raum fuerObjekt:(int)objekt anWochentag:(int)wochentag mitDaten:(NSArray*)stundencodearray
{
   //int bytezeile = 56*raum + 7*objekt + wochentag;// zeile: 56*$raum + 7*$objekt + $wochentag // aus eeprom.pl
   
   
   for (int stunde=0;stunde<24;stunde++)
   {
      int stundenwert = [[stundencodearray objectAtIndex:stunde]intValue];
      
      // tags fuer halbe stunden
      int htaste0tag = 100 + 10*stunde;
      int htaste1tag = htaste0tag +1;
      
      // tags fuer ganze stunden
      int gtastetag = 500 + 10*stunde;
      //NSLog(@"stunde: %d htaste0tag: %d htaste1tag: %d gtastetag: %d aktuellerObjekttyp: %d",stunde,htaste0tag,htaste1tag,gtastetag,self.aktuellerObjekttyp);
      //
      {
         switch (self.aktuellerObjekttyp)
         {
            case 0: // halbe Stunden
            {
               //NSLog(@"stundenwert: %d htaste0tag: %d",stundenwert,htaste0tag);
               //NSLog(@"w0: %d w1: %d",(stundenwert & 0x02),(stundenwert & 0x01));
               
               [[self.tagplanfeld viewWithTag:gtastetag]setHidden:YES];
               [[self.tagplanfeld viewWithTag:htaste0tag]setHidden:NO];
               [[self.tagplanfeld viewWithTag:htaste1tag]setHidden:NO];
               
               [(UIButton*)[self.tagplanfeld viewWithTag:htaste0tag]setSelected:((stundenwert & 0x02)>0)];
              
               [(UIButton*)[self.tagplanfeld viewWithTag:htaste1tag]setSelected:((stundenwert & 0x01)>0)];
               
            }break;
               
            case 1: // nur ganze Stunden
            {
               [[self.tagplanfeld viewWithTag:htaste0tag]setHidden:YES];
               [[self.tagplanfeld viewWithTag:htaste1tag]setHidden:YES];
               [[self.tagplanfeld viewWithTag:gtastetag]setHidden:NO];
               
               [(UIButton*)[self.tagplanfeld viewWithTag:gtastetag]setSelected:((stundenwert )>0)];
            }break;
               
         } // switch ObjektTyp
      }
      
   }
   [self.tagplanfeld setNeedsDisplay];
}

- (NSString*)readWochenplan
{
   NSString* ServerPfad =@"http://www.ruediheimlicher.ch/Data/eepromdaten/";
   NSString* DataSuffix=@"eepromdaten.txt";
   //NSLog(@"readWochenplan  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
   NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
   //NSLog(@"readWochenplan URL: %@",URL);
   NSStringEncoding *  enc=0;
   NSError* WebFehler=NULL;
   NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
   if (WebFehler)
   {
      NSLog(@"readWochenplan WebFehler: :%@",[[WebFehler userInfo]description]);
   }
   //NSLog(@"readWochenplan DataString: %@",DataString);
   
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
      [(UIButton*)[self.tagplanfeld viewWithTag:100+10*stunde]setSelected:NO];
      [(UIButton*)[self.tagplanfeld viewWithTag:100+10*stunde+1]setSelected:NO];
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
   NSLog(@"reportWochentagSeg aktuellerWochentag: %d",self.aktuellerWochentag
         );
}

- (IBAction)reportResetTaste:(id)sender
{
   
   [self.aktuellerstundencodearray setArray: self.oldstundencodearray];

   [self setTagplanInRaum:self.aktuellerRaum fuerObjekt:self.aktuellesObjekt anWochentag:self.aktuellerWochentag];

}

- (IBAction)reportSendTaste:(UIButton *)sender
{
   NSLog(@"reportSendTaste");
   
   int permanent=3;
   NSLog(@"reportSendTaste aktuellerstundencodearray: %@",[self.aktuellerstundencodearray description]);
   NSArray* StundenByteArray = [self StundenByteArrayVonStundenCodeArray:[self aktuellerstundencodearray]];
   //NSLog(@"reportSendTaste StundenByteArray: %@",[StundenByteArray description]);
   /*
   // Webserver:
    
    HomeClientWriteStandardAktion HomeClientURLString: http://192.168.1.210/twi?pw=ideur00&wadr=0&lbyte=00&hbyte=00&data=0+f+fb+33+ff+75+ff+ff
    
   sendEEPROM URL: http://www.ruediheimlicher.ch/cgi-bin/eeprom.pl?pw=ideur00&perm=1&hbyte=00&lbyte=00&data=0+15+251+51+255+117+255+255&titel=Brenner&typ=0
   */
   
   // URL fuer HomeCentral aufbauen:
   NSString* HomeCentralPfad = [NSString stringWithFormat:@"%@/twi?pw=ideur00&wadr=0&",HomeCentralAdresseString];
   //NSLog(@"send raum: %d objekt: %d wochentag: %d",self.aktuellerRaum,self.aktuellesObjekt,self.aktuellerWochentag);
   uint16_t i2cStartadresse=self.aktuellerRaum*RAUMPLANBREITE + self.aktuellesObjekt*TAGPLANBREITE+ self.aktuellerWochentag*0x08;
   
   uint8_t lb = i2cStartadresse & 0x00FF;
   uint8_t hb = i2cStartadresse >> 8;
   
   // lbyte, hbyte werden als dez eingesetzt, nicht als hex. Aus Webinterface uebernommen.
   
   NSString* lbyte = [NSString stringWithFormat:@"%02d",lb];
   NSString* hbyte = [NSString stringWithFormat:@"%02d",hb];
   
   
   NSLog(@"wochentag: %d lbyte: %@ hbyte: %@ i2cStartadresse: %04X %d",self.aktuellerWochentag,lbyte,hbyte,i2cStartadresse,i2cStartadresse);
   /*
    // in WebInterface:
   NSString* lbyte=[[[note userInfo]objectForKey:@"lbyte"]stringValue];
	NSString* hbyte=[[[note userInfo]objectForKey:@"hbyte"]stringValue];
   if ([lbyte length]==1)
   {
      lbyte = [@"0" stringByAppendingString:lbyte];
   }
   if ([hbyte length]==1)
   {
      hbyte = [@"0" stringByAppendingString:hbyte];
   }
*/
   
   NSString* DataString=@"data=";
   for (int i=0;i<8;i++)
   {
      if (i<[StundenByteArray count])
      {
         DataString= [NSString stringWithFormat:@"%@%x",DataString,[[StundenByteArray objectAtIndex:i]intValue]];
      }
      else
      {
         DataString= [NSString stringWithFormat:@"%@%x",DataString,0xFF];
      }
      if (i< (8-1))
      {
         DataString = [DataString stringByAppendingString:@"+"];
      }
   }

   NSString* HomeCentralString = [HomeCentralPfad stringByAppendingFormat:@"lbyte=%@&hbyte=%@&%@",lbyte,hbyte,DataString];
   NSLog(@"HomeCentralString: %@",HomeCentralString);
    HomeCentralURL = [NSURL URLWithString:HomeCentralString];
   NSLog(@"HomeCentralURL: %@",HomeCentralURL);
   
  
   // URL fuer Homeserver aufbauen
   
   // http://www.ruediheimlicher.ch/cgi-bin/eeprom.pl?pw=ideur00&perm=1&hbyte=00&lbyte=00&data=0+15+251+51+255+117+255+255&titel=Brenner&typ=0
   
   NSString* EEPROMDataString = [StundenByteArray componentsJoinedByString:@"+"];
   //NSString* aktuellerWochentagString = [NSString stringWithFormat:@"%02d",self.aktuellerWochentag];
   EEPROMDataString = [EEPROMDataString stringByAppendingFormat:@"+255+255"];
   
   
   
   //NSString* Datumzusatz = [NSString stringWithFormat:@"%@%@%@",self.aktuellesjahr, self.aktuellermonat, self.aktuellerWochentagString];
   
   NSString* HomeServerString = [HomeServerAdresseString stringByAppendingFormat:@"/cgi-bin/eeprom.pl?pw=ideur00&perm=%d&lbyte=%@&hbyte=%@&data=%@&titel=%@&typ=%d",permanent,lbyte,hbyte,EEPROMDataString,self.aktuellerObjektname,self.aktuellerObjekttyp];

   
// ohne perm
//   NSString* HomeServerString = [HomeServerAdresseString stringByAppendingFormat:@"/cgi-bin/eeprom.pl?pw=ideur00&lbyte=%@&hbyte=%@&data=%@&titel=%@&typ=%d",lbyte,hbyte,EEPROMDataString,self.aktuellerObjektname,self.aktuellerObjekttyp];
   NSLog(@"HomeServerString: %@",HomeServerString);
   HomeServerURL = [NSURL URLWithString:HomeServerString];
    NSLog(@"HomeServerURL: %@",HomeServerURL);
   [self loadURL:HomeCentralURL];
 
   
}

- (void)sendEEPROMDataAnHomeServer
{
   [self loadURL:HomeServerURL];
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
      self.twitimer.hidden=YES;
      self.twitimer.text = @"";

      self.sendtaste.enabled= NO;
      NSString* TWIStatusSuffix = [NSString stringWithFormat:@"pw=%s&status=%@",PW,@"1"];
      NSString* TWIStatusURLString =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralAdresseString, TWIStatusSuffix];
      
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
      NSString* TWIStatusURLString =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralAdresseString, TWIStatusSuffix];
      
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
      int twiresetdelay = 10.0;
      //NSLog(@"EEPROMReadDataAktion  confirmTimerDic: %@",[confirmTimerDic description]);
      
      confirmStatusTimer=[NSTimer scheduledTimerWithTimeInterval:sendResetDelay
                                                           target:self
                                                         selector:@selector(statusTimerFunktion:)
                                                         userInfo:confirmTimerDic
                                                          repeats:YES];
      
      NSMutableDictionary* TWITimerDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"twitimeoutanzahl", nil];

      TWIStatusTimer = [NSTimer scheduledTimerWithTimeInterval:twiresetdelay
                                                      target:self
                                                    selector:@selector(TWITimerFunktion:)
                                                    userInfo:TWITimerDic
                                                     repeats:YES];
      self.twitimer.hidden=NO;
      self.twitimer.text = [NSString stringWithFormat:@"%d",maxAnzahl];
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
            
            TWIStatus0URL =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralAdresseString, TWIStatus0URLSuffix];
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
			
			//NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			//[nc postNotificationName:@"StatusWait" object:self userInfo:tempDataDic];
			
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

- (void)TWITimerFunktion:(NSTimer*) derTimer
{
	NSMutableDictionary* statusTimerDic=(NSMutableDictionary*) [derTimer userInfo];
	//NSLog(@"statusTimerFunktion  maxAnzahl: %d  statusTimerDic: %@",maxAnzahl,[statusTimerDic description]);
   
	if ([statusTimerDic objectForKey:@"twitimeoutanzahl"])
	{
		int anz=[[statusTimerDic objectForKey:@"twitimeoutanzahl"] intValue];
      
		if (anz < maxAnzahl)
		{
			anz++;
			self.twitimer.text = [NSString stringWithFormat:@"%d",(maxAnzahl - anz)];
			[statusTimerDic setObject:[NSNumber numberWithInt:anz] forKey:@"twitimeoutanzahl"];
         
         
			
		}
		else
		{
			
			NSLog(@"TWITimerFunktion statusTimer invalidate");
			// Misserfolg an AVRClient senden
         [self setTWIState:YES];
			self.twitimer.hidden=NO;
			[derTimer invalidate];
			self.twitimer.hidden=YES;
			self.twitaste.on=YES;
		}
		
	}
}

- (IBAction)reportStundenTaste:(rToggleTaste*)sender
{
   
   //NSLog(@"reportStundenTaste: selected vor: %d tag: %d",sender.selected,sender.tag);
   sender.selected = !sender.selected;
   int tastenON = sender.selected;
   int tastenstunde =0;
   switch(self.aktuellerObjekttyp)
   {
      case 0:
      {
         tastenstunde = (int)(sender.tag-100)/10;
      }break;
      case 1:
      {
         tastenstunde = (int)(sender.tag-500)/10;
      }break;
   }
   
   int ON = [[self.aktuellerstundencodearray objectAtIndex:tastenstunde]intValue];
   //NSLog(@"reportStundenTaste: ON vor: %d",[[self.aktuellerstundencodearray objectAtIndex:tastenstunde]intValue]);
   //NSLog(@"reportStundenTaste: ON vor: %d",ON);
   switch (sender.tag%2)
   {
      case 0:// Taste links
      {
         //NSLog(@"reportStundenTaste: links");
         if (sender.selected==YES)
         {
            ON |= 0x02;
         }
         else
         {
            ON &= ~0x02;
         }
      }
         break;
      case 1:// Taste rechts
      {
         NSLog(@"reportStundenTaste: rechts");
         if (sender.selected==YES)
         {
            ON |= 0x01;
         }
         else
         {
            ON &= ~0x01;
         }
      }
         break;
    }
   //NSLog(@"reportStundenTaste: ON nach: %d",ON);
   NSLog(@"reportStundenTaste aktuellerstundencodearray vor: %@",[self.aktuellerstundencodearray description]);
   [self.aktuellerstundencodearray replaceObjectAtIndex:tastenstunde withObject: [NSNumber numberWithInt:ON]];
   NSLog(@"reportStundenTaste aktuellerstundencodearray nach: %@",[self.aktuellerstundencodearray description]);

  //NSLog(@"reportStundenTaste: ON nach: %d",[[self.aktuellerstundencodearray objectAtIndex:tastenstunde]intValue]);
   self.tagplananzeige.datenarray = self.aktuellerstundencodearray;
   [self.tagplananzeige setNeedsDisplay];

}

- (NSMutableArray*)StundenCodeArrayVonByteArray:(NSArray*)bytearray
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
   return StundenByteArray;
}

- (NSArray*)StundenByteArrayVonStundenCodeArray:(NSArray*)stundencodearray
{
	NSMutableArray* tempByteArray=[[NSMutableArray alloc]initWithCapacity:0];
	int i, k=3;
	uint8_t Stundenbyte=0;
	NSString* StundenbyteString=[NSString string];
	for (i=0;i<[stundencodearray count];i++)
	{
		uint8_t Stundencode=[[stundencodearray objectAtIndex:i] intValue];
		//NSLog(@"StundenByteArray i: %d Tag: %d Objekt: %d Stundencode: %02X",i,Wochentag, Objekt, Stundencode);
		Stundencode=(Stundencode << 2*k);
		//NSLog(@"Stundencode <<: %02X",Stundencode);
		Stundenbyte |=Stundencode;
		//NSLog(@"i: %d      Stundenbyte: %02X",i,Stundenbyte);
		if (k==0)
		{
			
			NSString* ByteString=[NSString stringWithFormat:@"%02X ",Stundenbyte];
			//NSLog(@"      Stundenbyte: %02X ByteString: %@",Stundenbyte , ByteString);
			StundenbyteString=[StundenbyteString stringByAppendingString:ByteString] ;
			[tempByteArray addObject:[NSNumber numberWithInt:Stundenbyte]];
			Stundenbyte=0;
			k=3;
		}
		else
		{
			k--;
		}
		
	}// for i
	//NSLog(@"raum: %d Tag: %d objekt: %d StundenbyteString: %@ tempByteArray: %@",Raum,Wochentag, Objekt,StundenbyteString,[tempByteArray description]);
   //NSLog(@"StundenbyteString: %@ tempByteArray: %@",StundenbyteString,[tempByteArray description]);
	return tempByteArray;
}


- (void)EEPROMisWriteOKRequest
{
   //NSLog(@"EEPROMisWriteOKRequest ");
   // Zaehler fuer Anzahl Versuche einsetzen
   NSMutableDictionary* confirmTimerDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [confirmTimerDic setObject:[NSNumber numberWithInt:0]forKey:@"anzahl"];
   int sendResetDelay=4.0;
   //NSLog(@"EEPROMReadDataAktion  confirmTimerDic: %@",[confirmTimerDic description]);
   confirmTimer=[NSTimer scheduledTimerWithTimeInterval:sendResetDelay
                                                  target:self
                                                selector:@selector(confirmTimerFunktion:)
                                                userInfo:confirmTimerDic
                                                 repeats:YES];
   
	
}

- (void)confirmTimerFunktion:(NSTimer*) derTimer
{
	NSMutableDictionary* confirmTimerDic=(NSMutableDictionary*) [derTimer userInfo];
	//NSLog(@"confirmTimerFunktion  confirmTimerDic: %@",[confirmTimerDic description]);
   
	if ([confirmTimerDic objectForKey:@"anzahl"])
	{
		
		int anz=[[confirmTimerDic objectForKey:@"anzahl"] intValue];
		if (anz < maxAnzahl)
		{
         NSString* TWIReadDataURLSuffix = [NSString stringWithFormat:@"pw=%s&iswriteok=1",PW];
         NSString* TWIReadDataURL =[NSString stringWithFormat:@"%@/twi?%@",HomeCentralAdresseString, TWIReadDataURLSuffix];
         NSURL *URL = [NSURL URLWithString:TWIReadDataURL];
         NSLog(@"confirmTimerFunktion  URL: %@",URL);
         [self loadURL:URL];
         anz++;
         [confirmTimerDic setObject:[NSNumber numberWithInt:anz] forKey:@"anzahl"];
		}
		else
		{
			NSLog(@"confirmTimerFunktion confirmTimer invalidate");
			
         // Misserfolg an AVRClient senden
			NSMutableDictionary* tempDataDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"iswriteok"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"FinishLoad" object:self userInfo:tempDataDic];
			
			[derTimer invalidate]; // Anfragen stop
		}
		
		
	}
}



- (void)loadURL:(NSURL *)URL
{
	//NSLog(@"loadURL: %@",URL);
	NSMutableURLRequest *HCRequest = [[NSMutableURLRequest alloc] initWithURL: URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4.0];
   //NSMutableURLRequest *HCRequest= [NSMutableURLRequest requestWithURL:URL];
   [HCRequest setHTTPMethod:@"GET"];
   //[HCRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
   [[NSURLCache sharedURLCache] removeAllCachedResponses];
   //	NSLog(@"Cache mem: %d",[[NSURLCache sharedURLCache]memoryCapacity]);
   [[NSURLCache sharedURLCache] removeCachedResponseForRequest:HCRequest];
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

- (void)status0Aktion
{
   self.sendtaste.enabled= YES;
   self.sendtaste.hidden=NO;

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   //NSLog(@"webViewDidFinishLoad");
   NSRange CheckRange;
	NSString* Code_String= @"okcode=";
	//NSString* Status0_String= @"status0";
   NSString* Status0_String= @"status0+";             // Status 0 ist bestaetigt

	NSString* Status1_String= @"status1";              // Status 1 ein
   NSString* EEPROM1_String= @"eeprom+";              // EEPROM laden bestaetigt
   NSString* EEPROM0_String= @"eeprom-";              // EEPROM laden misslungen
   
   NSString* EEPROM_Write_Adresse_String= @"wadr";    // Write-Adresse ist angekommen
   NSString* EEPROM_Write_OK_String= @"write+";       // schreiben auf HomeCentral ist gelungen
   NSString* EEPROM_Write_NOT_OK_String= @"write-";   // EEPROm schreiben ist nicht gelungen

   NSString* EEPROM_Write_HomeServer_OK_String= @"homeserver+";   // EEPROM auf Homeserver schreiben ist gelungen
   
   NSString *HTML_Inhalt = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
   NSLog(@"HTML_Inhalt: %@",HTML_Inhalt);
   
   // Test, ob Webseite eine okcode-Antwort ist
	CheckRange = [HTML_Inhalt rangeOfString:Code_String];
	if (CheckRange.location < NSNotFound) // es ist eine OK-Antwort
	{
      // Status0+ erhalten?
		CheckRange = [HTML_Inhalt rangeOfString:Status0_String];
		if (CheckRange.location < NSNotFound)
		{
			//NSLog(@"didFinishLoadForFrame: status0+ ist da");
         [self performSelector:@selector(status0Aktion) withObject:nil afterDelay:2];
         //self.sendtaste.enabled= YES;
         //self.sendtaste.hidden=NO;
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
      
      // eeprom+ erhalten?
		CheckRange = [HTML_Inhalt rangeOfString:EEPROM1_String];
		if (CheckRange.location < NSNotFound)
		{
         NSLog(@"webViewDidFinishLoad: eeprom+ ist da ");
      
      }
      
      // eeprom laden nicht gelungen
		CheckRange = [HTML_Inhalt rangeOfString:EEPROM0_String];
		if (CheckRange.location < NSNotFound)
		{
			NSLog(@"webViewDidFinishLoad: eeprom- ist da ");
			//[tempDataDic setObject:[NSNumber numberWithInt:1] forKey:@"eeprom-"];
		}
      
      // wadr da?
		CheckRange = [HTML_Inhalt rangeOfString:EEPROM_Write_Adresse_String];
		if (CheckRange.location < NSNotFound)
		{
			NSLog(@"webViewDidFinishLoad: wadr ist da");
			//[tempDataDic setObject:[NSNumber numberWithInt:1] forKey:@"wadrok"];
         [self performSelector:@selector(EEPROMisWriteOKRequest) withObject:nil afterDelay:1.0];
         //[self EEPROMisWriteOKRequest]; // EEPROM write starten
		}
      
      // eeprom+ da?
      CheckRange = [HTML_Inhalt rangeOfString:EEPROM_Write_OK_String];
		if (CheckRange.location < NSNotFound)
		{
			NSLog(@"webViewDidFinishLoad: write+ ist da");
			//[tempDataDic setObject:[NSNumber numberWithInt:1] forKey:@"writeok"];
			[confirmTimer invalidate]; // Schreiben OK, Ladeversuche stop
         [self performSelector:@selector(sendEEPROMDataAnHomeServer) withObject:nil afterDelay:1.0];
         //[self sendEEPROMDataAnHomeServer];
      }
      
      CheckRange = [HTML_Inhalt rangeOfString:EEPROM_Write_NOT_OK_String];
		if (CheckRange.location < NSNotFound)
		{
			NSLog(@"webViewDidFinishLoad: write- ist da");
			//[tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"writeok"];
		}
      
      // end isstatus0ok
   } // if okcode
   
   CheckRange = [HTML_Inhalt rangeOfString:EEPROM_Write_HomeServer_OK_String];
   if (CheckRange.location < NSNotFound)
   {
      NSLog(@"webViewDidFinishLoad: homeserver+ ist da");
      //[tempDataDic setObject:[NSNumber numberWithInt:0] forKey:@"writeok"];
   }
   
   //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
   NSLog(@"didFailLoadWithError: error: %@",[error description]);

}

@end
