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
	// Do any additional setup after loading the view.
   ServerPfad =@"http://www.ruediheimlicher.ch/Data/StromDaten";
   NSArray* lastDataArray = [[[self StromDataDicVonHeute]objectForKey:@"laststromdata"]componentsSeparatedByString:@"\t"];
   NSLog(@"Strom lastDataArray: %@",[lastDataArray description]);
   NSLog(@"Strom leistungaktuell: %@",[lastDataArray lastObject]);
   self.leistungaktuell.text = [NSString stringWithFormat:@"%d kW",[[lastDataArray lastObject]intValue]];
   self.datum.text = [NSString stringWithFormat:@"%2d.%02d.20%d",[[lastDataArray objectAtIndex:2]intValue],[[lastDataArray objectAtIndex:1]intValue],[[lastDataArray objectAtIndex:0]intValue]];
   self.zeit.text = [NSString stringWithFormat:@"%d:%02d:%02d",[[lastDataArray objectAtIndex:3]intValue],[[lastDataArray objectAtIndex:4]intValue],[[lastDataArray objectAtIndex:5]intValue]];

   self.data.text = [[self StromDataDicVonHeute]objectForKey:@"laststromdata"];
   [self timerFired];
#ifdef MEMORY_TEST
   self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                               selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif

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
		//	lastDataZeit=[self lastDataZeitVon:DataString];
		//	NSLog(@"StromDataVonHeute lastDataZeit: %d",lastDataZeit);
			[StromDataDic setObject:DataString forKey:@"datastring"];
			//NSLog(@"StromDataArray: %@",[[DataString componentsSeparatedByString:@"\n"]description]);
         NSArray* StromDataArray = [DataString componentsSeparatedByString:@"\n"];
         //NSLog(@"StromDataArray vor: %@",[SolarDataArray description]);
         if ([[StromDataArray lastObject]length] ==0)
         {
            StromDataArray = [StromDataArray subarrayWithRange:NSMakeRange(0, [StromDataArray count]-1)];
         }
         NSLog(@"StromDataArray nach: %@",[[StromDataArray lastObject]description]);
         [StromDataDic setObject:[StromDataArray lastObject] forKey:@"laststromdata"];
         
         return StromDataDic;
			
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
	return StromDataDic;

   
}

// plot start
- (void)timerFired
{
#ifdef MEMORY_TEST
   static NSUInteger counter = 0;
   
   NSLog(@"\n----------------------------\ntimerFired: %lu", counter++);
#endif
   
 //  [graph release];
   
   // Create graph from theme
   stromgraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
   CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
   [stromgraph applyTheme:theme];
   //CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
   CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.plotfeld;
   hostingView.hostedGraph = stromgraph;
   
   // Border
   stromgraph.plotAreaFrame.borderLineStyle = nil;
   stromgraph.plotAreaFrame.cornerRadius    = 0.0f;
   
   // Paddings
   stromgraph.paddingLeft   = 0.0f;
   stromgraph.paddingRight  = 0.0f;
   stromgraph.paddingTop    = 0.0f;
   stromgraph.paddingBottom = 0.0f;
   
   stromgraph.plotAreaFrame.paddingLeft   = 70.0;
   stromgraph.plotAreaFrame.paddingTop    = 20.0;
   stromgraph.plotAreaFrame.paddingRight  = 20.0;
   stromgraph.plotAreaFrame.paddingBottom = 80.0;
   
   // Graph title
   stromgraph.title = @"Graph Title\nLine 2";
   CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
   textStyle.color                   = [CPTColor grayColor];
   textStyle.fontSize                = 16.0f;
   textStyle.textAlignment           = CPTTextAlignmentCenter;
   stromgraph.titleTextStyle           = textStyle;
   stromgraph.titleDisplacement        = CGPointMake(0.0f, -20.0f);
   stromgraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
   
   // Add plot space for horizontal bar charts
   CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)stromgraph.defaultPlotSpace;
   plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
   plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];
   
   CPTXYAxisSet *axisSet = (CPTXYAxisSet *)stromgraph.axisSet;
   CPTXYAxis *x          = axisSet.xAxis;
   x.axisLineStyle               = nil;
   x.majorTickLineStyle          = nil;
   x.minorTickLineStyle          = nil;
   x.majorIntervalLength         = CPTDecimalFromString(@"5");
   x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
   x.title                       = @"X Axis";
   x.titleLocation               = CPTDecimalFromFloat(7.5f);
   x.titleOffset                 = 55.0f;
   
   // Define some custom labels for the data elements
   x.labelRotation  = M_PI / 4;
   x.labelingPolicy = CPTAxisLabelingPolicyNone;
   NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:5], [NSDecimalNumber numberWithInt:10], [NSDecimalNumber numberWithInt:15], nil];
   NSArray *xAxisLabels         = [NSArray arrayWithObjects:@"Label A", @"Label B", @"Label C", @"Label D", @"Label E", nil];
   NSUInteger labelLocation     = 0;
   NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
   for ( NSNumber *tickLocation in customTickLocations ) {
      CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
      newLabel.tickLocation = [tickLocation decimalValue];
      newLabel.offset       = x.labelOffset + x.majorTickLength;
      newLabel.rotation     = M_PI / 4;
      [customLabels addObject:newLabel];
  //    [newLabel release];
   }
   
   x.axisLabels = [NSSet setWithArray:customLabels];
   
   CPTXYAxis *y = axisSet.yAxis;
   y.axisLineStyle               = nil;
   y.majorTickLineStyle          = nil;
   y.minorTickLineStyle          = nil;
   y.majorIntervalLength         = CPTDecimalFromString(@"50");
   y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
   y.title                       = @"Y Axis";
   y.titleOffset                 = 45.0f;
   y.titleLocation               = CPTDecimalFromFloat(150.0f);
   
   // First bar plot
   CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor darkGrayColor] horizontalBars:NO];
   barPlot.baseValue  = CPTDecimalFromString(@"0");
   barPlot.dataSource = self;
   barPlot.barOffset  = CPTDecimalFromFloat(-0.25f);
   barPlot.identifier = @"Bar Plot 1";
   [stromgraph addPlot:barPlot toPlotSpace:plotSpace];
   
    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = CPTDecimalFromString(@"0");
    barPlot.barOffset       = CPTDecimalFromFloat(0.25f);
    barPlot.barCornerRadius = 2.0f;
    barPlot.identifier      = @"Bar Plot 2";
    [stromgraph addPlot:barPlot toPlotSpace:plotSpace];
    
}


-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
   return 16;
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
   NSDecimalNumber *num = nil;
   
   if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
      switch ( fieldEnum ) {
         case CPTBarPlotFieldBarLocation:
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
            break;
            
         case CPTBarPlotFieldBarTip:
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:(index + 1) * (index + 1)];
            if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
               num = [num decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
            }
            break;
      }
   }
   
   return num;
}

// plot end

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
   [self setPlotfeld:nil];
   [super viewDidUnload];
}
@end
