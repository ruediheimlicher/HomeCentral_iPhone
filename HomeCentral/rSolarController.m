//
//  rSolarController.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 04.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import "rSolarController.h"

@interface rSolarController ()

@end

@implementation rSolarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       isDownloading = 0;
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   float kttemp=100.1;
   self.kt.text = [NSString stringWithFormat:@"%.1f°C",kttemp];;
   float botemp=60.5;
   self.bo.text = [NSString stringWithFormat:@"%.1f°C",botemp];
	// Do any additional setup after loading the view.
   NSURL* stromURL = [NSURL URLWithString:@"http://www.ruediheimlicher.ch"];
//   int erfolg = [[UIApplication sharedApplication] openURL:stromURL];
 //  NSLog(@"erfolg: %d",erfolg);
   //[self.webfenster loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ruediheimlicher.ch/"]]];
   ServerPfad =@"http://www.ruediheimlicher.ch/Data";
   
   //self.solardata.text = [[self SolarDataDicVonHeute] objectForKey:@"lastsolardata"];
   NSString* lastsolardataString = [[self lastSolarDataDic] objectForKey:@"lastsolardata"];
   self.solardata.text = lastsolardataString;
   NSLog(@"lastsolardata: %@",lastsolardataString);
   NSArray* lastDataArray = [lastsolardataString componentsSeparatedByString:@"\t"];
   float kv_temp = [[lastDataArray objectAtIndex:1]floatValue]/2;
   self.kv.text = [NSString stringWithFormat:@"%.1f°C",kv_temp];
   
   float kr_temp = [[lastDataArray objectAtIndex:2]floatValue]/2;
   self.kr.text = [NSString stringWithFormat:@"%.1f°C",kr_temp];

   float bu_temp = [[lastDataArray objectAtIndex:3]floatValue]/2;
   self.bu.text = [NSString stringWithFormat:@"%.1f°C",bu_temp];
   
   float bm_temp = [[lastDataArray objectAtIndex:4]floatValue]/2;
   self.bm.text = [NSString stringWithFormat:@"%.1f°C",bm_temp];

   float bo_temp = [[lastDataArray objectAtIndex:5]floatValue]/2;
   self.bo.text = [NSString stringWithFormat:@"%.1f°C",bo_temp];

   float kt_temp = [[lastDataArray objectAtIndex:6]floatValue]/2;
   self.kt.text = [NSString stringWithFormat:@"%.1f°C",kt_temp];
   
   //int test=16;
   //bool testON = (test & 0x10);
   //NSLog(@"testON: %d",testON);
   bool pumpeON = ([[lastDataArray objectAtIndex:7]intValue] & 0x08);
   NSLog(@"pumpeON: %d",pumpeON);
   //[Pumpe setHidden:pumpeON];
   if (pumpeON)
   {
      self.pumpe.highlighted = YES;
   }
   else
   {
      self.pumpe.highlighted = NO;
   
   }
   
   bool elektroON = ([[lastDataArray objectAtIndex:7]intValue] & 0x10);
   NSLog(@"elektroON: %d",elektroON);
   if (elektroON)
   {
      [self.heizung setEnabled:YES];
   }
   else
   {
      [self.heizung setEnabled:NO];
      
   }
   /*
   UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
   [self.backtaste setBackBarButtonItem:backButton];
*/
 //[self.navbar setBackBarButtonItem:self.backtaste];
   self.webfenster.delegate = self;
	self.webfenster.scalesPageToFit = YES;

	
   //self.webfenster.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
   //[self.webfenster loadHTMLString:@"<h1>Visit <a href='http://www.fourtentech.com'>FourTen</a> for mobile application development!</h1>" baseURL:nil];
   // UIWebView *callWebview = [[UIWebView alloc] init];
   // NSURL *telURL = [NSURL URLWithString:@"tel://0552407844"];
   //[self.webfenster loadRequest:[NSURLRequest requestWithURL:telURL]];
   //[self produceHTMLForPage:1];
   // Diagramm vorbereiten
   
   
}



-(void)produceHTMLForPage:(NSInteger)pageNumber{
   
   //init a mutable string, initial capacity is not a problem, it is flexible
   NSMutableString* string =[[NSMutableString alloc]initWithCapacity:10];
   [string appendString:
    @"<html>"
    "<head>"
    "<meta name=\"viewport\" content=\"width=320\"/>"
    "</head>"
    "<body>"
    ];
   [string appendString:@"</body>"
    "</html>"
    ];
 
   [self.webfenster loadHTMLString:string baseURL:nil];        //load the HTML String on UIWebView
   
}

- (IBAction)reportTextFieldGo:(id)sender
{
   NSLog(@"reportTextFieldReturn eingabe: %@",[self.urlfeld text]);
   [sender resignFirstResponder];
   NSString* url = self.urlfeld.text;
   if (url == @"home")
   {
      NSLog(@"reportTextFieldGo NO");
      [super dismissModalViewControllerAnimated:YES];
      //do close window magic here!!
      return ;
   }

   url = [NSString stringWithFormat:@"http://%@",url];
    NSLog(@"reportTextFieldReturn url: %@",url);
   //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunesconnect.apple.com"]];

   //[self produceHTMLForPage:1];
	[self.webfenster loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

}

- (NSDictionary*)lastSolarDataDic
{
   /*
    lastdatenarray =     (
    48849,	Laufzeit
    47,		Kollektor Vorlauf
    46,		Kollektor Ruecklauf
    40,		Boiler unten
    128,	Boiler mitte
    136,	Boiler oben
    82,		Kollektortemperatur
    0,
    255
    );
    Alle Temperaturerte mit doppeltem Wert
	 */
   
   NSMutableDictionary* SolarDataDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
   
	NSString* returnString=[NSString string];
	if (isDownloading)
	{
		return nil;//[self cancel];
	}
	else
	{
      NSString* AussentempSuffix = @"/TemperaturDaten.txt";
      NSURL *AussentempURL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:AussentempSuffix]];
		//NSLog(@"SolarDataVonHeute URL: %@",URL);
		NSStringEncoding *  Aussentempenc=0;
		NSError* AussentempWebFehler=NULL;
		NSString* AussentempDataString=[NSString stringWithContentsOfURL:AussentempURL usedEncoding: Aussentempenc error:&AussentempWebFehler];
      //NSLog(@"SolarDataVonHeute AussentempDataString: %@",AussentempDataString);
      NSString* AussentemperaturString = [[AussentempDataString componentsSeparatedByString:@"\n"]objectAtIndex:5];
      NSLog(@"SolarDataVonHeute AussentemperaturString: %@",AussentemperaturString);
      AussentemperaturString = [[AussentemperaturString componentsSeparatedByString:@" "]lastObject];
		AussentemperaturString = [NSString stringWithFormat:@"%@°C",AussentemperaturString];
      self.AussentempFeld.text = AussentemperaturString;
      
      
      NSString* DataSuffix=@"LastSolarData.txt";
		//NSLog(@"SolarDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSLog(@"SolarDataVonHeute URL: %@",URL);
		NSStringEncoding *  enc=0;
		NSError* WebFehler=NULL;
		NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
			
			NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
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
				NSLog(@"DataVonHeute: String korrigieren");
				DataString=[DataString substringFromIndex:1];
			}
			NSLog(@"LastSolarData DataString: \n%@",DataString);
			//lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"SolarDataVonHeute lastDataZeit: %d",lastDataZeit);
			[SolarDataDic setObject:DataString forKey:@"datastring"];
			//NSLog(@"solardatenarray: %@",[[DataString componentsSeparatedByString:@"\n"]description]);
         NSArray* SolarDataArray = [DataString componentsSeparatedByString:@"\n"];
         //NSLog(@"SolarDataArray vor: %@",[SolarDataArray description]);
         if ([[SolarDataArray lastObject]length] ==0)
         {
            NSLog(@"DataVonHeute: SolarDataArray korrigieren");
            SolarDataArray = [SolarDataArray subarrayWithRange:NSMakeRange(0, [SolarDataArray count]-1)];
         }
         NSLog(@"SolarDataArray nach: %@",[[SolarDataArray lastObject]description]);
         [SolarDataDic setObject:[SolarDataArray lastObject] forKey:@"lastsolardata"];
         
         return SolarDataDic;
		}
		else
		{
			NSLog(@"Keine Daten");
			//[self setErrString:@"DataVonHeute: keine Daten"];
		}
		
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
	return SolarDataDic;
}

- (NSDictionary*)SolarDataDicVonHeute
{
   /*
    lastdatenarray =     (
    48849,	Laufzeit
    47,		Kollektor Vorlauf
    46,		Kollektor Ruecklauf
    40,		Boiler unten
    128,	Boiler mitte
    136,	Boiler oben
    82,		Kollektortemperatur
    0,
    255
    );
    Alle Temperaturerte mit doppeltem Wert
	 */

   NSMutableDictionary* SolarDataDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
  
	NSString* returnString=[NSString string];
	if (isDownloading)
	{
		return nil;//[self cancel];
	}
	else
	{
      
      
		
		NSString* SolarDataSuffix=@"SolarDaten.txt";
		//NSLog(@"SolarDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,SolarDataSuffix);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
		//NSLog(@"SolarDataVonHeute URL: %@",URL);
		NSStringEncoding *  enc=0;
		NSError* WebFehler=NULL;
		NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		//NSLog(@"SolarDataVonHeute DataString: \n%@",DataString);
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
			
			NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
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
			lastDataZeit=[self lastDataZeitVon:DataString];
			NSLog(@"SolarDataVonHeute lastDataZeit: %d",lastDataZeit);
			[SolarDataDic setObject:DataString forKey:@"datastring"];
			//NSLog(@"solardatenarray: %@",[[DataString componentsSeparatedByString:@"\n"]description]);
         NSArray* SolarDataArray = [DataString componentsSeparatedByString:@"\n"];
         int n= [SolarDataArray count];
         SolarDataArray = [SolarDataArray subarrayWithRange:NSMakeRange(6, n-6)];

         //NSLog(@"SolarDataArray sub: %@",[SolarDataArray description]);
         if ([[SolarDataArray lastObject]length] ==0)
         {
            SolarDataArray = [SolarDataArray subarrayWithRange:NSMakeRange(0, [SolarDataArray count]-1)];
         }
         //NSLog(@"SolarDataArray nach: %@",[[SolarDataArray lastObject]description]);
         NSLog(@"SolarDataArray count: %d",[SolarDataArray count]);
         NSMutableArray* redSolarDataArray = [[NSMutableArray alloc]initWithCapacity:0];
         int lastZeit=0;
         int anzData=0;
         for (int k=0;k<[SolarDataArray count];k++)
         {
            NSArray* tempZeilenArray = [[SolarDataArray objectAtIndex:k]componentsSeparatedByString:@"\t"];
            int t = [[tempZeilenArray objectAtIndex:0]intValue];
            t/=60;
            
            if (t> (lastZeit+2))
            {
               //NSLog(@"*   SolarDataArray k: %d t: %d",k,t);
               lastZeit = t;
               anzData++;
               [redSolarDataArray addObject:tempZeilenArray];
            }
            else
            {
            //NSLog(@"SolarDataArray k: %d t: %d",k,t);
            }
         }
         NSLog(@"anz: %d redSolarDataArray : %@",anzData,[redSolarDataArray description]);
         [SolarDataDic setObject:redSolarDataArray forKey:@"solardata"];
         [SolarDataDic setObject:[SolarDataArray lastObject] forKey:@"lastsolardata"];
         
         return SolarDataDic;
			
		}
		else
		{
			NSLog(@"Keine Daten");
			//[self setErrString:@"DataVonHeute: keine Daten"];
		}
		
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
	return SolarDataDic;
}

- (NSDictionary*)DiagrammDatenDicVon:(NSArray*)DatenArray mitAnzahlDaten:(int)anz mitIndex:(NSArray*)index
{
   NSLog(@"Solar DiagrammDatenDicVon anz: %d %d",anz,[DatenArray count]);
   NSMutableDictionary*  DiagrammdatenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   NSMutableArray* LineArray = [[NSMutableArray alloc]initWithCapacity:0];
   // Array: dataarray mit datadics
   NSMutableArray* tempDataArray = [[NSMutableArray alloc]initWithCapacity:0];

   int art =0;
   int std=0;
   int min=1;
   int data=2;

   NSArray* IndexArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:std],[NSNumber numberWithInt:min],[NSNumber numberWithInt:data],[NSNumber numberWithInt:0], nil]; // letztes Element: art

   int offsetstd = [[[[DatenArray objectAtIndex:0]componentsSeparatedByString:@"\t" ]objectAtIndex:std]intValue];
   int offsetmin = [[[[DatenArray objectAtIndex:0]componentsSeparatedByString:@"\t" ]objectAtIndex:min]intValue];
   int offsetx = 60*offsetstd + offsetmin;
   
   int endstd =  [[[[DatenArray lastObject]componentsSeparatedByString:@"\t" ]objectAtIndex:std]intValue];
   int endmin =  [[[[DatenArray lastObject]componentsSeparatedByString:@"\t" ]objectAtIndex:min]intValue];
   int endx = 60*endstd + endmin;
   int diffx = endx - offsetx;
   
   NSLog(@"art: %d endx: %d diffx: %d",art,endx,diffx);

   for (int i=0;i<[DatenArray count];i++)
   {
      int tempzeit = [[[DatenArray objectAtIndex:i]objectAtIndex:0]intValue]/60;
      int tempmin = tempzeit%60;
      int tempstd = tempzeit/60;
      int minute = tempzeit%1440; // minute des Tages
      //NSLog(@"i: %d tempstd: %d tempmin: %d minute: %d",i,tempstd,tempmin,minute);
      NSNumber* stundeNumber = [NSNumber numberWithInt:tempstd];
      NSNumber* minuteNumber = [NSNumber numberWithInt:tempmin];
      // Linien konfig
      // KV
      float x = (float)minute/2; // Werte sind doppelt
      
      float zoomfaktory = self.diagrammview.bounds.size.height/8000;  // max Leistung
      float y = [[tempZeilenArray objectAtIndex:data]intValue]*zoomfaktory;
      
      NSDictionary* tempDataDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x],@"x",[NSNumber numberWithFloat:y],@"y", nil];
      NSLog(@"i: %d tempDataDic%@",i,[tempDataDic description]);
      [tempDataArray addObject:tempDataDic];
   }
   
   
   
   return (NSDictionary*)DiagrammdatenDic;;
}

- (int)lastDataZeitVon:(NSString*)derDatenString
{
	int lastZeit=0;
	//NSLog(@"DataString: %@",derDatenString);
	
	NSArray* DataArray=[derDatenString componentsSeparatedByString:@"\n"];
	if ([[DataArray lastObject]isEqualToString:@""])
	{
		DataArray=[DataArray subarrayWithRange:NSMakeRange(0,[DataArray count]-1)];
	}
	//NSLog(@"DataArray: %@",[DataArray description]);
	
	//NSLog(@"lastDataZeitVon: letzte Zeile: %@",[DataArray lastObject]);
	NSArray* lastZeilenArray=[[DataArray lastObject]componentsSeparatedByString:@"\t"];
	lastZeit = [[lastZeilenArray objectAtIndex:0]intValue];
	
	return lastZeit;
}


- (void)viewWillAppear:(BOOL)animated
{
   NSLog(@"viewWillAppear");
	self.webfenster.delegate = self;	// setup the delegate as the web view is shown
 

}

- (void)viewWillDisappear:(BOOL)animated
{
   [self.webfenster stopLoading];	// in case the web view is still loading its content
	self.webfenster.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   NSLog(@"absoluteString: %@",[[request URL] absoluteString]);
   if ( [@"file:///" isEqualToString:[[request URL] absoluteString]] )
   {
      NSLog(@"shouldStartLoadWithRequest YES");
      return YES;
   }
   if ([[request URL] absoluteString] == @"http://home/")
   {
      NSLog(@"shouldStartLoadWithRequest NO");
      [super dismissModalViewControllerAnimated:YES];
      //do close window magic here!!
      return NO;
   }
   if ([[[request URL] absoluteString] isEqualToString:@"plus.google.com/"])
   { [super dismissModalViewControllerAnimated:YES]; return NO; }
   
   NSLog(@"shouldStartLoadWithRequest YES %@",[request URL]);
   [[UIApplication sharedApplication] openURL:[request URL]];
   return YES;


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
 
   [self setKt:nil];
   [self setKv:nil];
   [self setKr:nil];
   [self setBo:nil];
   [self setBm:nil];
   [self setBu:nil];
  
   [self setUrlfeld:nil];
   [self setWebfenster:nil];
   [self setSolardata:nil];
   [self setHeizung:nil];
   [self setPumpe:nil];
   [self setUrlfeld:nil];
   
   [self setBacktaste:nil];
   [self setBacktaste:nil];
   [self webfenster].delegate=nil;
   [self setRefreshTaste:nil];
   [self setDiagrammTaste:nil];
   [self setAussentempFeld:nil];
   [self setBoilerfeld:nil];
    [super viewDidUnload];
   //[KT setText: @"100"];//
  
   
}

- (IBAction)reportRefresh:(id)sender
{
     NSLog(@"reportRefresh");
   
}

- (IBAction)reportDiagrammTaste:(id)sender
{
   NSDictionary* heuteSolarDic = [self SolarDataDicVonHeute];
   NSDictionary* DiagrammdatenDic =[self DiagrammDatenDicVon:[heuteSolarDic objectForKey:@"solardata"]mitAnzahlDaten:1 mitIndex:NULL];
 
}

- (IBAction)switch2Strom:(id)sender
{
[self performSegueWithIdentifier: @"stromid"
                          sender: self];
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//   [webView.scrollView zoomToRect:CGRectMake(0.0, 0.0, 50.0, 50.0) animated:YES];
//   [webView stringByEvaluatingJavaScriptFromString: @"document.body.style.zoom = 5.0;"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
                            @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
                            error.localizedDescription];
	[self.webfenster loadHTMLString:errorString baseURL:nil];
}

@end
