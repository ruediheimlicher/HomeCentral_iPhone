//
//  rViewController.h
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 28.November.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rEingabeController : UIViewController <UIAlertViewDelegate>
{
   IBOutlet UIButton* LoginTaste;
   IBOutlet UITextField* Datumfeld;
   IBOutlet UITextField* PickerDatumfeld;
   IBOutlet UIDatePicker *DatumPicker;
   
}

@property (strong, nonatomic) UIDatePicker *DatumPicker;
@property (strong, nonatomic) UITextField *monat;
@property (strong, nonatomic) NSString *wochentag;
@property (strong, nonatomic) NSString *stunde;
@property (strong, nonatomic) UILabel *Datumfeld;
@property (strong, nonatomic) UILabel *PickerDatumfeld;
@property (weak, nonatomic) IBOutlet UITabBarItem *HomeButton;
@property (weak, nonatomic) IBOutlet UITextField *Benutzernamefeld;
@property (weak, nonatomic) IBOutlet UITextField *BenutzerPasswortfeld;

- (IBAction)reportHeute:(id)sender;
- (IBAction)reportDatumPicker:(id)sender;


- (IBAction)reportLogin:(id)sender;
- (IBAction)reportAktualisieren:(id)sender;
- (void)changeDateInLabel:(id)sender;
@end
