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
   
   NSDictionary* StromDicVonHeute = [self StromDataDicVonHeute];

   NSArray* lastDataArray = [[StromDicVonHeute objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   //NSArray* lastDataArray = [[[self StromDataDicVonHeute]objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   NSLog(@"Strom lastDataArray: %@",[lastDataArray description]);
   NSLog(@"Strom leistungaktuell: %@",[lastDataArray lastObject]);
   self.leistungaktuell.text = [NSString stringWithFormat:@"%d kW",[[lastDataArray lastObject]intValue]];
   self.datum.text = [NSString stringWithFormat:@"%2d.%02d.20%d",[[lastDataArray objectAtIndex:2]intValue],[[lastDataArray objectAtIndex:1]intValue],[[lastDataArray objectAtIndex:0]intValue]];
   self.zeit.text = [NSString stringWithFormat:@"%d:%02d:%02d",[[lastDataArray objectAtIndex:3]intValue],[[lastDataArray objectAtIndex:4]intValue],[[lastDataArray objectAtIndex:5]intValue]];
     self.data.text = [StromDicVonHeute objectForKey:@"laststromdata"];
   
   // Stromdaten von heute
   NSArray* StromArray = [StromDicVonHeute objectForKey:@"stromdata"];
   
   NSLog(@"Strom StromArray: %@",[[StromArray objectAtIndex:0] description]);
   float zoomfaktorx = self.diagrammview.bounds.size.width/1440;   // Minuten des Tages
   float zoomfaktory = self.diagrammview.bounds.size.height/8000;                // max Leistung
   NSMutableDictionary*  DiagrammdatenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSMutableArray* LineArray = [[NSMutableArray alloc]initWithCapacity:0];
   //for (int i=0;i<3;i++) // linien
   {
      // Array: dataarray mit datadics
      NSMutableArray* tempDataArray = [[NSMutableArray alloc]initWithCapacity:0];
      int lastminute=0;
      for (int k=0;k<[StromArray count];k++)// Datenarray
      {
         
         // Datadic mit Koordinaten
         NSArray* tempZeilenArray = [[StromArray objectAtIndex:k]componentsSeparatedByString:@"\t"];
         //NSLog(@"i: %d Strom tempZeilenArray: %@",i,[tempZeilenArray description]);
       // if (([[tempZeilenArray objectAtIndex:4]intValue]-lastminute)>1)
        {
         float x =  (60.0*[[tempZeilenArray objectAtIndex:3]intValue]+[[tempZeilenArray objectAtIndex:4]intValue])*zoomfaktorx;
         float y = [[tempZeilenArray objectAtIndex:6]intValue]*zoomfaktory;
         NSDictionary* tempDataDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x],@"x",[NSNumber numberWithFloat:y],@"y", nil];
         
         [tempDataArray addObject:tempDataDic];
           lastminute = [[tempZeilenArray objectAtIndex:4]intValue];
        }
      }
      
      
      
      UIColor* tempColor = [UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0];
      NSDictionary* tempLineDic = [NSDictionary dictionaryWithObjectsAndKeys:tempDataArray,@"dataarray",tempColor,@"linecolor", nil];
      [LineArray addObject:tempLineDic];
   }
   
   //NSLog(@"LineArray: %@",[LineArray description]);
   [DiagrammdatenDic setObject:LineArray forKey:@"linearray"];
   //NSLog(@"DiagrammdatenDic: %@",[DiagrammdatenDic description]);
   [self.diagrammview DiagrammZeichnenMitDic:DiagrammdatenDic];

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
		//NSLog(@"StromDataVonHeute URL: %@",URL);
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
         
         [StromDataDic setObject:StromDataArray  forKey:@"strommonitor"];
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
   [super viewDidUnload];
}
@end
