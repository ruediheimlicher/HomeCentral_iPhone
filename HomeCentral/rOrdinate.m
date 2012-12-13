//
//  rOrdinate.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 11.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//


#import "rOrdinate.h"

@implementation rOrdinate

char* itoa(int val, int base)
{
	
	static char buf[32] = {0};
	
	int i = 30;
	
	for(; val && i ; --i, val /= base)
      
		buf[i] = "0123456789abcdef"[val % base];
	
	return &buf[i+1];
	
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       NSLog(@"ordinate init");
        // Initialization code
    }
    return self;
}


-(void)OrdinateZeichnenMitDic:(NSDictionary*)derDataDic;
{
   NSLog(@"OrdinateZeichnenMitDic. %@",[derDataDic description]);
   if ([derDataDic objectForKey:@"offsetx"])
   {
      self.offsetx = [[derDataDic objectForKey:@"offsetx"]floatValue];
   }
   else
   {
      self.offsetx = 2;
   }
   if ([derDataDic objectForKey:@"eckeunteny"])
   {
     
      self.eckeunteny = [[derDataDic objectForKey:@"eckeunteny"]floatValue];
      //NSLog(@"eckeunteny: %.1f",self.eckeunteny);

   }
   else
   {
      self.eckeunteny = self.frame.size.height;
   }
   
    if ([derDataDic objectForKey:@"diagrammhoehe"])
   {
      self.diagrammhoehe = [[derDataDic objectForKey:@"diagrammhoehe"]floatValue];
   }
   else
   {
      self.diagrammhoehe = 200;
   }

   if ([derDataDic objectForKey:@"b"])
   {
      self.b = [[derDataDic objectForKey:@"b"]floatValue];
   }
   else
   {
      self.b = 20;
   }

   if ([derDataDic objectForKey:@"teile"])
   {
      self.teile = [[derDataDic objectForKey:@"teile"]floatValue];
   }
   else
   {
      self.teile = 10;
   }

   if ([derDataDic objectForKey:@"intervall"])
   {
      self.intervall = [[derDataDic objectForKey:@"intervall"]floatValue];
   }
   else
   {
      self.intervall = 10;
   }

   if ([derDataDic objectForKey:@"randunten"])
   {
      self.randunten = [[derDataDic objectForKey:@"randunten"]floatValue];
   }
   else
   {
      self.randunten = 10;
   }


}

- (void)drawRect:(CGRect)rect
{
   /*
   self.offsetx=2;
   self.eckeunteny=2;
   self.teile=12;
   self.intervall = 10;
   //self.h=self.frame.size.height-self.eckeunteny - 2;
   self.b=self.frame.size.width - 2;
    */
   
    // Drawing code
   //NSLog(@"Ordinate drawRect bounds w: %.1f\t h: %.1f" ,self.bounds.size.width,self.bounds.size.height);
    NSLog(@"Ordinate drawRect diagrammhoehe: %.1f\t offsetx: %.1f" ,self.diagrammhoehe,self.offsetx);
   //NSLog(@"Ordinate drawRect teile: %d",self.teile);
   CGContextRef context = UIGraphicsGetCurrentContext();
   //CGContextTranslateCTM (context,8,0);
   CGContextSelectFont(context, "Helvetica", 10, kCGEncodingMacRoman);
   CGContextSetTextDrawingMode(context, kCGTextFill);
   //CGContextTranslateCTM (xcontext,10,0);
   CGContextSetTextMatrix (context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));

   CGContextSetLineWidth(context, 0.4);
   CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
   //NSLog(@"drawRect eckeunteny: %.1f",self.eckeunteny);

   float startx = self.offsetx;
   float starty = self.eckeunteny+2-self.randunten;
   NSLog(@"startx: %.1f starty: %.1f",startx,starty);
      
   CGContextMoveToPoint(context, startx,starty);

    for (int i=0;i<self.teile+1;i++)
   {
      int wert = self.startwert+i*self.intervall;
      //const char* cLegende = [[[NSNumber numberWithInt:wert]stringValue]UTF8String];
      const char* cLegende = malloc(6);
      
      cLegende = [[[NSNumber numberWithInt:wert ]stringValue] UTF8String];
      float x = self.offsetx;
      
      if (wert<10)
      {
         x += 10;
         
      }
      else if (wert<100)
      {
         x += 5;
      }
      
     // NSMutableAttributedString * wertstring = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",wert] attributes:attributes];
      

      //char* c = itoa(wert,10);
      //char* cLegende=
      
      float y = starty - i*(self.diagrammhoehe/(self.teile));
      
      //NSLog(@"i: %d cLegende: %s x: %.2f y: %.2f",i ,cLegende,x,y);
      CGContextBeginPath(context);
      CGContextShowTextAtPoint(context,x ,y,cLegende,strlen(cLegende));
      CGContextStrokePath(context);
   }
   
   
   
}


@end
