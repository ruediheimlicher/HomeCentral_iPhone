//
//  rEingabeViewController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 03.Dezember.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface rHomeController : UIViewController
{
   MKMapView *mapView;
   IBOutlet MKMapView*  Karte;
}
@end
