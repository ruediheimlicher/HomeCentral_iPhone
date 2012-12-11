//
//  rSolarDiagrammView.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 09.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "rDiagrammView.h"

@interface rSolarDiagrammView : UIView
{
#define kGraphHeight          300
#define kDefaultGraphWidth    900
#define kOffsetX              1
#define kStepX                20
#define kStepY                20
#define kOffsetY              1


#define kGraphBottom          300
#define kGraphTop             0
NSDictionary*                 DataDic;

}
@property (weak,nonatomic, readwrite) NSDictionary* datadic;
@property (nonatomic, readwrite) int graphheight;
@property (nonatomic, readwrite) int graphwidth;

@property (nonatomic, readwrite) float diagrammhoehe;

-(void)DiagrammZeichnenMitDic:(NSDictionary*)derDataDic;


@end
