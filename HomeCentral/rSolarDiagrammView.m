//
//  rSolarDiagrammView.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 09.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import "rSolarDiagrammView.h"

@implementation rSolarDiagrammView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)DiagrammZeichnenMitDic:(NSDictionary*)derDataDic
{
   self.diagrammhoehe = (int)(self.frame.size.height/10)*10;
   //NSLog(@"DiagrammZeichnenMitDic derDataDic: %@",[derDataDic description]);
   
   self.datadic = derDataDic;
   //NSLog(@"DiagrammZeichnenMitDic Dataarray count: %d",[[[[self.datadic objectForKey:@"linearray"]objectAtIndex:0]objectForKey:@"dataarray"]count]);
   //NSLog(@"DiagrammZeichnenMitDic Dataarray : %@",[[[[self.datadic objectForKey:@"linearray"]objectAtIndex:0]objectForKey:@"dataarray"]description]);
   //float anz=(float)[[[[self.datadic objectForKey:@"linearray"]objectAtIndex:0]objectForKey:@"dataarray"]count];
   
   //NSLog(@"DiagrammZeichnenMitDic Dataarray count: %.1f zoom: %2.3f",anz,zoom);
   
   //NSLog(@"self.datadic: %@",[self.datadic description]);
   DataDic = derDataDic;
   [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect
{
   // Drawing code
   NSLog(@"Solardiagramm drawRect bounds w: %.1f\t h: %.1f diagrammhoehe: %.1f" ,self.bounds.size.width,self.bounds.size.height,self.diagrammhoehe);
   CGContextRef context = UIGraphicsGetCurrentContext();
   //CGContextTranslateCTM (context,10,0);
   
   CGContextSetLineWidth(context, 0.4);
   CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
   // How many lines?
   int howMany = (kDefaultGraphWidth - kOffsetX) / kStepX;
   // Here the lines go
   for (int i = 0; i < howMany; i++)
   {
      CGContextMoveToPoint(context, kOffsetX + i * kStepX, kGraphTop);
      CGContextAddLineToPoint(context, kOffsetX + i * kStepX, kGraphBottom);
   }
   float hoehe= (int)(self.bounds.size.height/10)*10;
   float breite = self.bounds.size.width;
   int anzh =12;
   
   
   for (int i = 0; i <= anzh; i++)
   {
      CGContextMoveToPoint(context, kOffsetX, hoehe - kOffsetY - i * (hoehe/anzh));
      CGContextAddLineToPoint(context, breite, hoehe - kOffsetY - i * (hoehe/anzh));
   }
   
   CGContextStrokePath(context);
   /*
    void CGContextShowText (
    CGContextRef c,
    const char *string,
    size_t length
    */
   
   CGContextRef xcontext = UIGraphicsGetCurrentContext();
   CGContextSelectFont(xcontext, "Helvetica", 14, kCGEncodingMacRoman);
   CGContextSetTextDrawingMode(xcontext, kCGTextFill);
   //CGContextTranslateCTM (xcontext,10,0);
   CGContextMoveToPoint(xcontext,kOffsetX,kOffsetY);
   //CGContextAddLineToPoint(xcontext, kOffsetX +10, kOffsetY+20);
   CGContextSetTextMatrix (xcontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
   
   //char* x_achse = "0 1 2 3\0";
   //NSLog(@"%s l: %zd",x_achse,strlen(x_achse));
   //CGContextShowTextAtPoint(xcontext,kOffsetX +10,kOffsetY+20,x_achse,strlen(x_achse));
   CGContextStrokePath(xcontext);
   
   CGContextSaveGState(context);
   
   // Draw the path in blue
   CGContextSetRGBStrokeColor(context,0,0,1,1);
   
   //NSLog(@"drawrect self.datadic: %@",[self.datadic description]);
   if ([self.datadic objectForKey:@"linearray"])
   {
      CGContextRef templinecontext = UIGraphicsGetCurrentContext();
      

      CGContextSaveGState(templinecontext);
      //CGContextRef linecontext = UIGraphicsGetCurrentContext();
      
      //CGContextTranslateCTM (context,10,10);
      
      NSArray* tempLineArray = [self.datadic objectForKey:@"linearray"];
      //NSLog(@"tempLineArray da: %@",[[self.datadic objectForKey:@"linearray"] description]);
      NSLog(@"tempLineArray count: %d",[tempLineArray count]);
      if (tempLineArray.count)
      {
      for (int linie=0;linie< tempLineArray.count;linie++)
         {
            //NSLog(@"Linie %d",linie);
            
            if ([[tempLineArray objectAtIndex:linie]count]) // linie vorhanden
            {
               //NSLog(@"tempLineArray objectAtIndex: %d da: %@",linie,[[[[tempLineArray objectAtIndex:linie]objectForKey:@"dataarray"]objectAtIndex:0] description]);
               //NSLog(@"tempLineArray objectAtIndex: %d da: %@",linie,[[[[tempLineArray objectAtIndex:linie]objectForKey:@"dataarray"]objectAtIndex:1] description]);
               //NSLog(@"tempLineArray objectAtIndex: %d da: %@",linie,[[[[tempLineArray objectAtIndex:linie]objectForKey:@"dataarray"]objectAtIndex:2] description]);
               // contextref anlegen
               //UIGraphicsPushContext(templinecontext);
               CGContextBeginPath(templinecontext);
               //CGContextTranslateCTM (templinecontext,10,0);
               //CGContextSetTextMatrix (templinecontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
               
               CGContextSetLineWidth(templinecontext, 2.0);
               
               NSDictionary* tempLineDic = [tempLineArray objectAtIndex:linie];
               if ([tempLineDic objectForKey:@"linecolor"])
               {
                  //CGContextSetStrokeColorWithColor(templinecontext, [[UIColor redColor] CGColor]);
                  CGContextSetStrokeColorWithColor(templinecontext, [[tempLineDic objectForKey:@"linecolor"] CGColor]);
               }
               else
               {
                  CGContextSetStrokeColorWithColor(templinecontext, [[UIColor lightGrayColor] CGColor]);
               }
               
               if ([tempLineDic objectForKey:@"linename"])
               {
                  //NSLog(@"linie: %d linename: %@",linie,[tempLineDic objectForKey:@"linename"]);
               }
               NSArray* tempDataArray = [tempLineDic objectForKey:@"dataarray"];
               // NSLog(@"tempDataArray an Index: %d da: %@",i,[[tempDataArray valueForKey:@"x"] description]);
               float startx = [[[tempDataArray objectAtIndex:0]objectForKey:@"x"]floatValue];
               
               float starty = self.bounds.size.height-[[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
               //float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
               
               CGContextMoveToPoint(templinecontext,startx,starty);
               
               
               
               //NSLog(@"startx: %.1f \t starty: %.1f",startx,starty);
               starty = self.bounds.size.height-starty;
               
               float x=startx;
               float y=starty;
               for (int index=1;index < [tempDataArray count];index++)
               {
                  x = [[[tempDataArray objectAtIndex:index]objectForKey:@"x"]floatValue];
                  y = self.bounds.size.height-[[[tempDataArray objectAtIndex:index]objectForKey:@"y"]floatValue];
                  
                  //NSLog(@"index: %d\t x: %.1f \t y: %.1f",index,x,y);
                  CGContextAddLineToPoint(templinecontext,x,y);
                  
               }// for index
               CGContextStrokePath(templinecontext);
               
               //CGContextRef xcontext = UIGraphicsGetCurrentContext();
               CGContextBeginPath(templinecontext);
               CGContextSelectFont(templinecontext, "Helvetica", 10, kCGEncodingMacRoman);
               CGContextSetTextDrawingMode(templinecontext, kCGTextFill);
               //CGContextTranslateCTM (templinecontext,10,0);
               CGContextMoveToPoint(templinecontext,x,y);
               //CGContextAddLineToPoint(xcontext, kOffsetX +10, kOffsetY+20);
               CGContextSetTextMatrix (templinecontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
               
               //char* x_achse = "0 1 2 3\0";
               const char* cName = [[tempLineDic objectForKey:@"linename"] UTF8String];
               //NSLog(@"linie: %d linename: %@ %s x: %.2f y: %.2f",linie ,[tempLineDic objectForKey:@"linename"],cName,x,y);

               CGContextShowTextAtPoint(templinecontext,x +10,y+4,cName,2);
               //CGContextShowTextAtPoint(templinecontext,x +10,x+20,"*",3);
               CGContextStrokePath(templinecontext);

               

               //UIGraphicsPopContext();
            } //if count
            
         }// for i
      }// if count
      CGContextRestoreGState(templinecontext);
   }// if linearray
}


@end
