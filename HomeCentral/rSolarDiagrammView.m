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
    if (self)
    {
        // Initialization code
    }
    return self;
}


-(void)DiagrammZeichnenMitDic:(NSDictionary*)derDataDic
{
   
   //self.diagrammhoehe = (int)((self.frame.size.height-self.randoben)/10)*10;
  // NSLog(@"DiagrammZeichnenMitDic derDataDic: %@",[derDataDic description]);
   
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
   
   self.diagrammbreite = self.bounds.size.width;
   if ([DataDic objectForKey:@"diagrammbreite"])
       {
          self.diagrammbreite = [[DataDic objectForKey:@"diagrammbreite" ] floatValue];
       }

   self.diagrammhoehe = self.bounds.size.height; // Diagramm fuellt ganzes Feld
   if ([DataDic objectForKey:@"diagrammhoehe"])
   {
      self.diagrammhoehe = [[DataDic objectForKey:@"diagrammhoehe" ] floatValue];
   }
   
   NSLog(@"diagrammhoehe: %.2f diagrammbreite: %.2f",self.diagrammhoehe,self.diagrammbreite);

   float  eckeunteny =  self.frame.size.height; //Startpunkt fuer Diagrammzeichnen

   self.randlinks = kOffsetX;
   if ([DataDic objectForKey:@"randlinks"])
   {
      self.randlinks = [[DataDic objectForKey:@"randlinks"]intValue];
   }
   
   
   float  eckeuntenx = [[DataDic objectForKey:@"eckeuntenx"]floatValue]; // Koordinate x Ecke des DiagrammView
   //float  eckeunteny = [[DataDic objectForKey:@"eckeunteny"]floatValue]; // Koordinate y
   
      
   NSLog(@"randlinks: %d",self.randlinks); // Abstand Diagramm zum View
   
   float intervall = kStepX; //Intervall der x-Achse *zoomfaktor
   
   if ([DataDic objectForKey:@"intervallx"]&& [DataDic objectForKey:@"zoomfaktorx"])
   {
      intervall = [[DataDic objectForKey:@"intervallx"]floatValue]* [[DataDic objectForKey:@"zoomfaktorx"]floatValue];
   }
   
   self.randunten = kGraphBottom; // Abstand Diagramm zum View
   
   if ([DataDic objectForKey:@"randunten"])
   {
      self.randunten = [[DataDic objectForKey:@"randunten"]floatValue];
   }
   
   NSLog(@"randunten: %d",self.randunten); // Abstand Diagramm zum View
   
   CGContextRef context = UIGraphicsGetCurrentContext();
   //CGContextTranslateCTM (context,10,0);
   
   CGContextSetLineWidth(context, 0.4);
   CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
   
   CGContextSelectFont(context, "Helvetica", 10, kCGEncodingMacRoman);
   CGContextSetTextMatrix (context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
   CGContextSetTextDrawingMode(context, kCGTextFill);

   // How many lines?
   int anzsenkrecht = self.diagrammbreite/intervall;
   // Senkrechte Linien
   //eckeunteny = self.frame.size.height;
   float linieoben = eckeunteny - self.diagrammhoehe-self.randunten;
   float linieunten = eckeunteny - self.randunten;
   
   NSLog(@"eckeunteny: %.2f linieoben: %.2f linieunten: %.2f",eckeunteny,linieoben,linieunten);
   
   for (int i = 0; i < anzsenkrecht; i++)
   {
      
      CGContextMoveToPoint(context, self.randlinks + i * intervall,  linieunten);
      CGContextAddLineToPoint(context, self.randlinks + i * intervall,linieoben);

      NSString* Stundestring = [NSString stringWithFormat:@"%d",i];
      const char* cName = [Stundestring UTF8String];
      //NSLog(@"linie: %d linename: %@ %s x: %.2f y: %.2f",linie ,[tempLineDic objectForKey:@"linename"],cName,x,y);
      
      CGContextShowTextAtPoint(context,self.randlinks + i * intervall-5, linieoben-10,cName,strlen(cName));

   }
   float hoehe= (int)(self.bounds.size.height/10)*10;
   
   if ([DataDic objectForKey:@"diagrammhoehe"])
   {
      hoehe = [[DataDic objectForKey:@"diagrammhoehe"]floatValue];
   }
   int startwertx = 0;
   if ([DataDic objectForKey:@"startwertx"])
   {
      startwertx = [[DataDic objectForKey:@"startwertx"]intValue];
   }
   NSLog(@"startwertx: %d",startwertx);
   
   // waagrechte Linien

   float breite = self.bounds.size.width;
   int anzh =12;
   
      for (int i = 0; i <= anzh; i++)
   {
      
      CGContextMoveToPoint(context, self.randlinks, self.bounds.size.height - self.randunten - i * (self.diagrammhoehe/anzh));
      CGContextAddLineToPoint(context, breite, self.bounds.size.height - self.randunten - i * (self.diagrammhoehe/anzh));
      
   }
   
   CGContextStrokePath(context);
   
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
   
   // Linien zeichnen
   
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
         // end Linien fuer Temperaturen

      for (int linie=0;linie< tempLineArray.count-1;linie++)
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
               
               CGContextSetLineWidth(templinecontext, 1.0);
               
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
               if ([tempDataArray count]==0)
               {
                  return;
               }
               // NSLog(@"tempDataArray an Index: %d da: %@",i,[[tempDataArray valueForKey:@"x"] description]);
               float startx = self.randlinks+[[[tempDataArray objectAtIndex:0]objectForKey:@"x"]floatValue];
               
               float starty = self.bounds.size.height-self.randunten-[[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
               //float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
               
               CGContextMoveToPoint(templinecontext,startx,starty);
               
               //
               starty = self.bounds.size.height-starty;
               NSLog(@"startx: %.1f \t starty: %.1f",startx,starty);
               float x=startx;
               float y=starty;
               for (int index=1;index < [tempDataArray count];index++)
               {
                  x = self.randlinks+[[[tempDataArray objectAtIndex:index]objectForKey:@"x"]floatValue];
                  y = self.bounds.size.height-self.randunten-[[[tempDataArray objectAtIndex:index]objectForKey:@"y"]floatValue];
                  
                  //NSLog(@"index: %d\t x: %.1f \t y: %.1f",index,x,y);
                  CGContextAddLineToPoint(templinecontext,x,y);
                  
               }// for index
               CGContextStrokePath(templinecontext);
               
               CGContextBeginPath(templinecontext);
               CGContextSelectFont(templinecontext, "Helvetica", 10, kCGEncodingMacRoman);
               CGContextSetTextMatrix (templinecontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
               CGContextSetTextDrawingMode(templinecontext, kCGTextFill);
               
               CGContextMoveToPoint(templinecontext,x,y);
               
               //char* x_achse = "0 1 2 3\0";
               const char* cName = [[tempLineDic objectForKey:@"linename"] UTF8String];
               //NSLog(@"linie: %d linename: %@ %s x: %.2f y: %.2f",linie ,[tempLineDic objectForKey:@"linename"],cName,x,y);

               CGContextShowTextAtPoint(templinecontext,x +10,y+4,cName,2);
               CGContextStrokePath(templinecontext);

               //UIGraphicsPopContext();
            } //if count
            
         }// for linie
         // end Linien fuer Temperaturen
         
         // Linien fuer Heizung und Pumpe
         
         // Beginn Pumpe
         int pumpecodeindex = 6;
         if ([[tempLineArray objectAtIndex:pumpecodeindex]count]) // linie vorhanden
         {
            NSLog(@"Pumpearray da");
            CGContextSetLineWidth(templinecontext, 3.0);
            
            NSDictionary* tempLineDic = [tempLineArray objectAtIndex:pumpecodeindex];
            if ([tempLineDic objectForKey:@"linecolor"])
            {
               CGContextSetStrokeColorWithColor(templinecontext, [[tempLineDic objectForKey:@"linecolor"] CGColor]);
            }
            else
            {
               CGContextSetStrokeColorWithColor(templinecontext, [[UIColor lightGrayColor] CGColor]);
            }
            
            if ([tempLineDic objectForKey:@"linename"])
            {
               NSLog(@"Linie: %d linename: %@",pumpecodeindex,[tempLineDic objectForKey:@"linename"]);
            }
            NSArray* tempDataArray = [tempLineDic objectForKey:@"dataarray"];
            //NSLog(@"Pumpe tempDataArray an Index: %d da: %@",pumpecodeindex,[[tempDataArray valueForKey:@"y"] description]);
            float startx = self.randlinks+[[[tempDataArray objectAtIndex:0]objectForKey:@"x"]floatValue];
            
            float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
            //float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
            
            CGContextMoveToPoint(templinecontext,startx,starty);
            //NSLog(@"startx: %.1f \t starty: %.1f",startx,starty);
           
            int lastON=0;
            int yON=self.bounds.size.height-200;
            float x=startx;
            float datawert=-100;
            
             if (starty>0) //Wert vorhanden, Linie beginnen
             {
                CGContextBeginPath(templinecontext);
                CGContextMoveToPoint(templinecontext,x,yON);
                lastON=1;
             }
             else
             {
               
             }
            
            for (int index=1;index < [tempDataArray count];index++)
            {
               x = self.randlinks+[[[tempDataArray objectAtIndex:index]objectForKey:@"x"]floatValue];
               datawert=[[[tempDataArray objectAtIndex:index]objectForKey:@"y"]floatValue];
               if (datawert > 0) // Heizung istn ON
               {
                  if (lastON) // Path schon angefangen
                  {
                     CGContextAddLineToPoint(templinecontext,x,yON);
                  }
                  else // neuer Path
                  {
                     CGContextStrokePath(templinecontext); // letzten Path abschliessen
                     CGContextMoveToPoint(templinecontext,x,yON);
                     lastON=1;
                  }
                }
               else // Heizung ist OFF
               {
                  if (lastON) // Path war vorhanden
                  {
                     CGContextStrokePath(templinecontext); // letzten Path abschliessen
                     lastON=0;
                  }
                  else // Heizung war schon OFF
                  {
                     // nichts tun
                  }
               }  // Heizung ist OFF
            }// for index
            CGContextStrokePath(templinecontext);
            
            CGContextBeginPath(templinecontext);
            CGContextSelectFont(templinecontext, "Helvetica", 10, kCGEncodingMacRoman);
            CGContextSetTextDrawingMode(templinecontext, kCGTextFill);
            CGContextMoveToPoint(templinecontext,x,yON);
            CGContextSetTextMatrix (templinecontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
            
            const char* cName = [[tempLineDic objectForKey:@"linename"] UTF8String];
            //NSLog(@"linie: %d linename: %@ %s x: %.2f y: %.2f",linie ,[tempLineDic objectForKey:@"linename"],cName,x,y);
            
            CGContextShowTextAtPoint(templinecontext,x,yON+4,cName,1);
            CGContextStrokePath(templinecontext);
            
            
            
            //UIGraphicsPopContext();
         } //if count
         // End Pumpe
 
         // Beginn Heizung
         int heizungcodeindex = 7;
         if ([[tempLineArray objectAtIndex:heizungcodeindex]count]) // linie vorhanden
         {
            NSLog(@"Heizungarray da");
            CGContextSetLineWidth(templinecontext, 3.0);
            
            NSDictionary* tempLineDic = [tempLineArray objectAtIndex:heizungcodeindex];
            if ([tempLineDic objectForKey:@"linecolor"])
            {
               CGContextSetStrokeColorWithColor(templinecontext, [[tempLineDic objectForKey:@"linecolor"] CGColor]);
            }
            else
            {
               CGContextSetStrokeColorWithColor(templinecontext, [[UIColor lightGrayColor] CGColor]);
            }
            
            if ([tempLineDic objectForKey:@"linename"])
            {
               NSLog(@"Linie: %d linename: %@",heizungcodeindex,[tempLineDic objectForKey:@"linename"]);
            }
            NSArray* tempDataArray = [tempLineDic objectForKey:@"dataarray"];
            //NSLog(@"tempDataArray an Index: %d da: %@",heizungcodeindex,[[tempDataArray valueForKey:@"y"] description]);
            float startx = self.randlinks+[[[tempDataArray objectAtIndex:0]objectForKey:@"x"]floatValue];
            
            float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
            //float starty = [[[tempDataArray objectAtIndex:0]objectForKey:@"y"]floatValue];
            
            CGContextMoveToPoint(templinecontext,startx,starty);
            //NSLog(@"startx: %.1f \t starty: %.1f",startx,starty);
            
            int heizungyoff=-100;
            int lastON=0;
            int yON=self.bounds.size.height-190;
            float x=startx;
            float datawert=-100;
            
            if (starty>0) //Wert vorhanden, Linie beginnen
            {
               CGContextBeginPath(templinecontext);
               CGContextMoveToPoint(templinecontext,x,yON);
               lastON=1;
            }
            else
            {
               
            }
            
            for (int index=1;index < [tempDataArray count];index++)
            {
               x = self.randlinks+[[[tempDataArray objectAtIndex:index]objectForKey:@"x"]floatValue];
               datawert=[[[tempDataArray objectAtIndex:index]objectForKey:@"y"]floatValue];
               if (datawert > 0) // Heizung istn ON
               {
                  if (lastON) // Path schon angefangen
                  {
                     CGContextAddLineToPoint(templinecontext,x,yON);
                  }
                  else // neuer Path
                  {
                     CGContextStrokePath(templinecontext); // letzten Path abschliessen
                     CGContextMoveToPoint(templinecontext,x,yON);
                     lastON=1;
                  }
               }
               else // Heizung ist OFF
               {
                  if (lastON) // Path war vorhanden
                  {
                     CGContextStrokePath(templinecontext); // letzten Path abschliessen
                     lastON=0;
                  }
                  else // Heizung war schon OFF
                  {
                     // nichts tun
                  }
               }  // Heizung ist OFF
            }// for index
            CGContextStrokePath(templinecontext);
            
            CGContextBeginPath(templinecontext);
            CGContextSelectFont(templinecontext, "Helvetica", 10, kCGEncodingMacRoman);
            CGContextSetTextDrawingMode(templinecontext, kCGTextFill);
            CGContextMoveToPoint(templinecontext,x,yON);
            CGContextSetTextMatrix (templinecontext, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
            
            const char* cName = [[tempLineDic objectForKey:@"linename"] UTF8String];
            //NSLog(@"linie: %d linename: %@ %s x: %.2f y: %.2f",linie ,[tempLineDic objectForKey:@"linename"],cName,x,y);
            
            CGContextShowTextAtPoint(templinecontext,x,yON+4,cName,1);
            CGContextStrokePath(templinecontext);
            
            
            
            //UIGraphicsPopContext();
         } //if count
         // End Heizung

         
         
         // end Linien fuer Heizung und Pumpe
      }// if count
      CGContextRestoreGState(templinecontext);
   }// if linearray
}


@end
