//
//  rAppDelegate.m
//  HomeCentral
//
//  Created by Ruedi Heimlicher on 28.November.12.
//  Copyright (c) 2012 Ruedi Heimlicher. All rights reserved.
//

#import "rAppDelegate.h"

@implementation rAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
   [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0], NSFontAttributeName, nil]];

   //NSLog(@"didFinishLaunchingWithOptions: %@",[launchOptions description]);
    // Override point for customization after application launch.
   NSString* DataSuffix=@"ip.txt";
   //NSLog(@"StromDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,DataSuffix);
   NSString* ServerPfad =@"https://www.ruediheimlicher.ch/Data";
   NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
   //NSLog(@"StromDataVonHeute URL: %@",URL);
   NSStringEncoding *  enc=0;
   NSError* WebFehler=NULL;
   NSString* IPString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
   
   NSLog(@"IP: %@",IPString);
   if (IPString)
   {

   NSArray* IPArray = [IPString componentsSeparatedByString:@"\r\n"];
   NSLog(@"IPArray: %@",[IPArray description]);
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"IP" object:self userInfo:[NSDictionary dictionaryWithObject:IPString forKey:@"ip"]];
      [[rVariableStore sharedInstance] setIP:IPString];
   
      
   // 
      NSLog(@"alertController appdel IPStatus");
 //     UIAlertController* alert_IP = [UIAlertController alertControllerWithTitle:@"IP-Status"
  //                                                                      message:@"IPString ist vorhanden?"
  //                                                               preferredStyle:UIAlertControllerStyleAlert];
      
      /*
      UIAlertAction* NOAction = [UIAlertAction actionWithTitle:@"NEIN" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                    NSLog(@"TWI nicht ausschalten.");
                                    //self.twitaste.on=YES;
                                    // Nichts tun
                                    
                                    
                                 }];
      
      
      [alert_IP addAction:NOAction];
      */
      UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                    NSLog(@"IP-String OK");
                                    //[self setTWIState:NO]; // TWI ausschalten
                                    
                                 }];
      /*
      [alert_IP addAction:OKAction];
      
      UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
      alertWindow.rootViewController = [[UIViewController alloc] init];
      alertWindow.windowLevel = UIWindowLevelAlert + 1;
      [alertWindow makeKeyAndVisible];
      [alertWindow.rootViewController presentViewController:alert_IP animated:YES completion:nil];
*/
      
      //
      
      
      
   
   }
   else
   {
      NSLog(@"alertController AppDel IP Status nicht vorhanden");
      UIAlertController* alert_IP = [UIAlertController alertControllerWithTitle:@"IP-Status"
                                                                        message:@"IPString nicht vorhanden?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
      /*
      UIAlertAction* NOAction = [UIAlertAction actionWithTitle:@"NEIN" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                    NSLog(@"TWI nicht ausschalten.");
                                    //self.twitaste.on=YES;
                                    // Nichts tun
                                    
                                    
                                 }];
      
      
      [alert_IP addAction:NOAction];
      */
      UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                    NSLog(@"Quit");
                                    //[self setTWIState:NO]; // TWI ausschalten
                                    NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
                                    [nc postNotificationName:@"Beenden" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1]forKey:@"status"]];

                                 }];
      
      [alert_IP addAction:OKAction];
      
      // https://stackoverflow.com/questions/27807104/how-to-present-uialertview-from-appdelegate
      UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
      alertWindow.rootViewController = [[UIViewController alloc] init];
      alertWindow.windowLevel = UIWindowLevelAlert + 1;
      [alertWindow makeKeyAndVisible];
      [alertWindow.rootViewController presentViewController:alert_IP animated:YES completion:nil];
 //     [self presentViewController:alert_IP animated:YES completion:nil];
      
   }
   
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
   //NSLog(@"applicationWillResignActive: ");

   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   NSLog(@"applicationDidEnterBackground: ");
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"EnterBackground" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1]forKey:@"status"]];
   

   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   NSLog(@"applicationWillEnterForeground: ");
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   NSLog(@"applicationDidBecomeActive: ");
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   //NSArray* Kontroller = [self rootViewController];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   NSLog(@"applicationWillTerminate: ");
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"Beenden" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1]forKey:@"status"]];

   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
