//
//  rStromController.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 04.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import "rStromController.h"

@interface rStromController ()

@end

@implementation rStromController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.diagrammscroller.contentSize = self.diagrammview.frame.size;
   
	// Do any additional setup after loading the view.
   ServerPfad =@"http://www.ruediheimlicher.ch/Data/StromDaten";
   
   StromDicVonHeute = [self StromDataDicVonHeute];
   
   NSArray* lastDataArray = [[StromDicVonHeute objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   //NSArray* lastDataArray = [[[self StromDataDicVonHeute]objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   //NSLog(@"Strom lastDataArray: %@",[lastDataArray description]);
   NSLog(@"Strom leistungaktuell: %@",[lastDataArray lastObject]);
   self.leistungaktuell.text = [NSString stringWithFormat:@"%d kW",[[lastDataArray lastObject]intValue]];
   self.datum.text = [NSString stringWithFormat:@"%2d.%02d.20%d",[[lastDataArray objectAtIndex:2]intValue],[[lastDataArray objectAtIndex:1]intValue],[[lastDataArray objectAtIndex:0]intValue]];
   self.zeit.text = [NSString stringWithFormat:@"%d:%02d:%02d",[[lastDataArray objectAtIndex:3]intValue],[[lastDataArray objectAtIndex:4]intValue],[[lastDataArray objectAtIndex:5]intValue]];
   self.data.text = [StromDicVonHeute objectForKey:@"laststromdata"];
   
   self.lastminute = 60*[[lastDataArray objectAtIndex:3]intValue]+[[lastDataArray objectAtIndex:4]intValue];
   // Stromdaten von heute
   //NSArray* StromArray = [StromDicVonHeute objectForKey:@"stromdata"];
   NSLog(@"Strom anzeigeseg: %d",self.anzeigeseg.selectedSegmentIndex);
   //NSLog(@"Strom StromArray: %@",[[StromArray objectAtIndex:0] description]);
   int startsegment = 1;
   self.anzeigeseg.selectedSegmentIndex = startsegment;
   [self switchAnzeigeSeg:startsegment];
 }

- (NSDictionary*)DiagrammDatenDicVon:(NSArray*)DatenArray mitAnzahlDaten:(int)anz mitIndex:(NSArray*)index
{
   //NSLog(@"DiagrammDatenDicVon anz: %d %d",anz,[DatenArray count]);
   NSMutableDictionary*  DiagrammdatenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSMutableArray* LineArray = [[NSMutableArray alloc]initWithCapacity:0];
   // Array: dataarray mit datadics
   NSMutableArray* tempDataArray = [[NSMutableArray alloc]initWithCapacity:0];
   
   int lastminute=0;
   
   int std = [[index objectAtIndex:0]intValue]; // Lage der Daten im DatenArray
   int min = [[index objectAtIndex:1]intValue];
   int data = [[index objectAtIndex:2]intValue];
   int art = [[index lastObject]intValue];
   
   int offsetstd = [[[[DatenArray objectAtIndex:0]componentsSeparatedByString:@"\t" ]objectAtIndex:std]intValue];
   int offsetmin = [[[[DatenArray objectAtIndex:0]componentsSeparatedByString:@"\t" ]objectAtIndex:min]intValue];
   int offsetx = 60*offsetstd + offsetmin;
   
   int endstd =  [[[[DatenArray lastObject]componentsSeparatedByString:@"\t" ]objectAtIndex:std]intValue];
   int endmin =  [[[[DatenArray lastObject]componentsSeparatedByString:@"\t" ]objectAtIndex:min]intValue];
   int endx = 60*endstd + endmin;
   int diffx = endx - offsetx;
   
   //NSLog(@"art: %d endx: %d diffx: %d",art,endx,diffx);
   float zoomfaktorx=1;
   switch (art)
   {
      case 0: // ganzer Tag
      {
         zoomfaktorx = self.diagrammview.bounds.size.width/1440;   // Minuten des Tage
      }break;
      case 1: // Monitor 2 Stunden
      {
         zoomfaktorx = self.diagrammview.bounds.size.width/diffx;
      }break;
   }
   self.lastzoomfaktorx = zoomfaktorx;
   float zoomfaktory = self.diagrammview.bounds.size.height/8000;  // max Leistung
   //NSLog(@"DiagrammDatenDicVon zoomfaktorx: %.2f",zoomfaktorx);

   
   
   //zoomfaktorx=1;
   //NSLog(@"DiagrammDatenDicVon std: %d min: %d data: %d offsetstd: %d offsetmin: %d offsetx: %d",std,min,data,offsetstd,offsetmin,offsetx);
   for (int k=0;k<[DatenArray count];k++)// Datenarray
   {
      
      // Datadic mit Koordinaten
      NSArray* tempZeilenArray = [[DatenArray objectAtIndex:k]componentsSeparatedByString:@"\t"];
      //NSLog(@"i: %d Strom tempZeilenArray: %@",k,[tempZeilenArray description]);
      // if (([[tempZeilenArray objectAtIndex:4]intValue]-lastminute)>1)
      {
         float x =  (60.0*[[tempZeilenArray objectAtIndex:std]intValue]+[[tempZeilenArray objectAtIndex:min]intValue]-offsetx);
         if (k == [DatenArray count]-1)
         {
            //NSLog(@"last Data k: %d x vor: %.2f",k,x);
         }
         x *= zoomfaktorx;
         float y = [[tempZeilenArray objectAtIndex:data]intValue]*zoomfaktory;
         NSDictionary* tempDataDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x],@"x",[NSNumber numberWithFloat:y],@"y", nil];
         
         [tempDataArray addObject:tempDataDic];
         lastminute = [[tempZeilenArray objectAtIndex:min]intValue];
      }
   }
   
   UIColor* tempColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0];
   NSDictionary* tempLineDic = [NSDictionary dictionaryWithObjectsAndKeys:tempDataArray,@"dataarray",tempColor,@"linecolor", nil];
   [LineArray addObject:tempLineDic];
   
   //NSLog(@"LineArray: %@",[LineArray description]);
   [DiagrammdatenDic setObject:LineArray forKey:@"linearray"];
   //NSLog(@"DiagrammdatenDic: %@",[DiagrammdatenDic description]);
   
   return (NSDictionary*)DiagrammdatenDic;
}

- (IBAction)reportRefresh:(id)sender
{
   NSLog(@"reportRefresh");
   StromDicVonHeute = [self StromDataDicVonHeute];
   NSArray* lastDataArray = [[StromDicVonHeute objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   self.leistungaktuell.text = [NSString stringWithFormat:@"%d kW",[[lastDataArray lastObject]intValue]];
   self.datum.text = [NSString stringWithFormat:@"%2d.%02d.20%d",[[lastDataArray objectAtIndex:2]intValue],[[lastDataArray objectAtIndex:1]intValue],[[lastDataArray objectAtIndex:0]intValue]];
   self.zeit.text = [NSString stringWithFormat:@"%d:%02d:%02d",[[lastDataArray objectAtIndex:3]intValue],[[lastDataArray objectAtIndex:4]intValue],[[lastDataArray objectAtIndex:5]intValue]];
   
   
}

- (IBAction)reportAnzeigeSeg:(UISegmentedControl *)sender
{
   NSLog(@"\nreportAnzeigeSeg segment: %d",sender.selectedSegmentIndex);
   [self switchAnzeigeSeg:sender.selectedSegmentIndex];
   return;
   
 }

- (void)switchAnzeigeSeg:(int)seg
{
   switch (seg)
   {
      case 0:
         
      {
         int std=3;
         int min=4;
         int data=6;
         NSArray* IndexArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:std],[NSNumber numberWithInt:min],[NSNumber numberWithInt:data],[NSNumber numberWithInt:seg], nil];
         // index wird als letztes Element eingefuegt, um Darstellungsart zu uebertragen
         CGRect b = self.diagrammview.frame;
         b.size.width = 900.0;
         b.origin.x=0;
         self.diagrammview.frame = b;
         
         [self.diagrammview DiagrammZeichnenMitDic:[self DiagrammDatenDicVon:[StromDicVonHeute objectForKey:@"stromdata"] mitAnzahlDaten:1440  mitIndex:IndexArray]];
         NSLog(@"switchAnzeigeSeg 0 lastminute: %d lastzoomfaktorx: %.2f offset: %.2f",self.lastminute,self.lastzoomfaktorx,self.lastminute*self.lastzoomfaktorx);
         //CGPoint rightOffset = CGPointMake(self.diagrammscroller.contentSize.width - self.diagrammscroller.bounds.size.width,0);
         //CGPoint rightOffset = CGPointMake(self.diagrammscroller.contentSize.width - self.lastminute*self.lastzoomfaktorx,0);
         CGPoint rightOffset = CGPointMake(self.lastminute*self.lastzoomfaktorx-0.8*self.diagrammscroller.bounds.size.width,0);

         [self.diagrammscroller setContentOffset:rightOffset animated:YES];

      }break;
         
      case 1:
      {
         //NSLog(@"contentOffset: %.2f",self.diagrammscroller.contentOffset.x);
         CGPoint leftOffset = CGPointMake(0,0);
        [self.diagrammscroller setContentOffset:leftOffset animated:YES];

         int std=1;
         int min=2;
         int data=4;
         
         NSArray* IndexArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:std],[NSNumber numberWithInt:min],[NSNumber numberWithInt:data],[NSNumber numberWithInt:seg], nil];
         
         NSArray* StromArray = [StromDicVonHeute objectForKey:@"strommonitor"];
         CGRect b = self.diagrammview.frame;
         //b.size.width = 1440.0/900.0 * (float)[StromArray count];
         
         b.size.width = self.diagrammscroller.frame.size.width;
         //b.origin.x=0;
         self.diagrammview.frame = b;
         
         [self.diagrammview DiagrammZeichnenMitDic:[self DiagrammDatenDicVon:StromArray mitAnzahlDaten:[StromArray count] mitIndex:IndexArray]];
 
      }break;
         
   }// switch
   [self.diagrammview setNeedsDisplay];

}

- (void)refreshData
{
   StromDicVonHeute = [self StromDataDicVonHeute];
   NSArray* lastDataArray = [[StromDicVonHeute objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   self.leistungaktuell.text = [NSString stringWithFormat:@"%d kW",[[lastDataArray lastObject]intValue]];
   self.datum.text = [NSString stringWithFormat:@"%2d.%02d.20%d",[[lastDataArray objectAtIndex:2]intValue],[[lastDataArray objectAtIndex:1]intValue],[[lastDataArray objectAtIndex:0]intValue]];
   self.zeit.text = [NSString stringWithFormat:@"%d:%02d:%02d",[[lastDataArray objectAtIndex:3]intValue],[[lastDataArray objectAtIndex:4]intValue],[[lastDataArray objectAtIndex:5]intValue]];
   
   NSLog(@"\refreshData segment: %d",self.anzeigeseg.selectedSegmentIndex);
   
   [self switchAnzeigeSeg:self.anzeigeseg.selectedSegmentIndex];
   return;
   

   
}


- (NSDictionary*)StromDataDicVonHeute
{
   /*
    lastdatenarray =     (
    12,     Jahr
    12,     Monat
    05,     Tag
    12,     Stunde
    06,     Minute
    08,     Sekunde
    "  365" Leistung
    );
    Alle Temperaturerte mit doppeltem Wert
	 */
   
   NSMutableDictionary* StromDataDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
   
	NSString* returnString=[NSString string];
	//if (isDownloading)
	{
      //	return nil;//[self cancel];
	}
	//else
	{
		NSString* DataSuffix=@"StromDaten.txt";
		//NSLog(@"StromDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSLog(@"StromDataVonHeute URL: %@",URL);
		NSStringEncoding *  enc=0;
		NSError* WebFehler=NULL;
		NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
			NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
			//ERROR: 503
			NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@" "];
			NSLog(@"ErrorArray: %@",[ErrorArray description]);
         // Login-Alert zeigen
         UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error in Download",@"Download misslungen")
                                                           message:[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]
                                                          delegate:self
                                                 cancelButtonTitle:@""
                                                 otherButtonTitles:@"OK", nil];
         [message setAlertViewStyle:UIAlertViewStyleDefault];
         [message show];
         return nil;
			NSString* MessageText= NSLocalizedString(@"Error in Download",@"Download misslungen");
			
			NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
			NSString* s2=[ErrorArray objectAtIndex:2];
			int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
			NSString* s3=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
			NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
      }
		if ([DataString length])
		{
			
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				//NSLog(@"DataVonHeute: String korrigieren");
				DataString=[DataString substringFromIndex:1];
			}
         
			//NSLog(@"SolarDataVonHeute DataString: \n%@",DataString);
			[StromDataDic setObject:DataString forKey:@"datastring"];
			//NSLog(@"StromDataArray: %@",[[DataString componentsSeparatedByString:@"\n"]description]);
         NSArray* StromDataArray = [DataString componentsSeparatedByString:@"\n"];
         //NSLog(@"StromDataArray vor: %@",[SolarDataArray description]);
         // Kopfzeilen entfernen
         StromDataArray = [StromDataArray subarrayWithRange:NSMakeRange(7, [StromDataArray count]-8)];
         if ([[StromDataArray lastObject]length] ==0)
         {
            StromDataArray = [StromDataArray subarrayWithRange:NSMakeRange(0, [StromDataArray count]-1)];
         }
         //NSLog(@"StromDataArray nach: %@",[[StromDataArray lastObject]description]);
         //NSLog(@"StromDataArray nach: %@",[StromDataArray description]);
         
         [StromDataDic setObject:StromDataArray  forKey:@"stromdata"];
         
         [StromDataDic setObject:[StromDataArray lastObject] forKey:@"laststromdata"];
         NSLog(@"last: %@",[[StromDataArray lastObject]description]);
         // Strommonitor laden
         //return StromDataDic;
		}
		else
		{
			NSLog(@"Keine Daten");
			//[self setErrString:@"DataVonHeute: keine Daten"];
		}
      
      DataSuffix=@"StromMonitor.txt";
		//NSLog(@"StromDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
		URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSLog(@"StromMonitorDataVonHeute URL: %@",URL);
		//NSStringEncoding *  enc=0;
		WebFehler=NULL;
		DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
			NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
			//ERROR: 503
			NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@" "];
			NSLog(@"ErrorArray: %@",[ErrorArray description]);
         // Login-Alert zeigen
         UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error in Download",@"Download misslungen")
                                                           message:[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]
                                                          delegate:self
                                                 cancelButtonTitle:@""
                                                 otherButtonTitles:@"OK", nil];
         [message setAlertViewStyle:UIAlertViewStyleDefault];
         [message show];
         return nil;
			NSString* MessageText= NSLocalizedString(@"Error in Download",@"Download misslungen");
			
			NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
			NSString* s2=[ErrorArray objectAtIndex:2];
			int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
			NSString* s3=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
			NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
		}
		
      if ([DataString length])
		{
			
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				//NSLog(@"DataVonHeute: String korrigieren");
				DataString=[DataString substringFromIndex:1];
			}
          
			//NSLog(@"SolarDataVonHeute DataString: \n%@",DataString);
			//[StromDataDic setObject:DataString forKey:@"datastring"];
			//NSLog(@"StromDataArray: %@",[[DataString componentsSeparatedByString:@"\n"]description]);
         NSArray* StromDataArray = [DataString componentsSeparatedByString:@"\n"];
         //NSLog(@"StromDataArray vor: %@",[SolarDataArray description]);
         if ([[StromDataArray lastObject]length] ==0)
         {
            StromDataArray = [StromDataArray subarrayWithRange:NSMakeRange(0, [StromDataArray count]-1)];
         }
         //NSLog(@"StromDataArray nach: %@",[[StromDataArray lastObject]description]);
         //NSLog(@"StromMonitorDataArray nach: %@",[StromDataArray description]);
         NSLog(@"StromMonitorDataArray count: %d",[StromDataArray count]);
         [StromDataDic setObject:StromDataArray  forKey:@"strommonitor"];
         
      }
      else
		{
			NSLog(@"Keine Daten");
			//[self setErrString:@"DataVonHeute: keine Daten"];
		}

      
      self.diagrammscroller.contentSize = self.diagrammview.frame.size;
      
		/*
		 NSLog(@"DataVon URL: %@ DataString: %@",URL,DataString);
		 if (URL)
		 {
		 download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
		 downloadFlag=heute;
		 
		 }
		 if (!download)
		 {
		 
		 NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
		 @"The entered URL is either invalid or unsupported.");
		 }
		 */
      
      
	}
	return StromDataDic;
   
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
   [self setData:nil];
   [self setLeistungaktuell:nil];
   [self setZeit:nil];
   [self setDatum:nil];
   //[self setPlotfeld:nil];
   [self setDiagrammview:nil];
   [self setDiagrammscroller:nil];
   [self setDiagrammscroller:nil];
   [self setDiagrammview:nil];
   [self setAnzeigeseg:nil];
   [self setRefreshTaste:nil];
   [super viewDidUnload];
}
@end
