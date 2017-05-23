//
//  AppDelegate.m
//  AppKeFuDemo7
//
//  Created by hl95 on 16-5-18.
//  Copyright (c) 2016年 im.95ykf.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "KFNavigationController.h"
#import "AppKeFuLib.h"

#import <AudioToolbox/AudioToolbox.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/*
 此appkey为演示所用，请确保应用在上线之前，到http://im.95ykf.com/AppKeFu/admin/index.php，申请自己的appkey
 */
#define APP_KEY @"615001b9e30cc882ded7ba18f5c06095"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //自定义UINavigationBar
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Uncomment to change the background color of navigation bar
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x0B8579)];//0x067AB5
        // Uncomment to change the color of back button
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    // Override point for customization after application launch.
    ViewController *sampleViewController = [[ViewController alloc] init];
    self.navigationController = [[KFNavigationController alloc] initWithRootViewController:sampleViewController];
    
    //适用于全屏App，需要隐藏导航条的情况，比如：游戏类
    //[self.navigationController setNavigationBarHidden:TRUE animated:FALSE];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    
    /*
     注意：如果您曾经运行过上一版Demo，请首先删除，然后再运行此Demo.
     
     微客服 初始化，请到官方网站申请appkey，网址：http://im.95ykf.com/AppKeFu/admin/index.php
     开发指南：http://im.95ykf.com/AppKeFu/doc/ios.html
     */
    
//如果要启用ip服务器，请设置为TRUE,否则请设置为FALSE, 注意如果设置为TRUE,则客服端登录的时候也需要选择IP服务器
    [[AppKeFuLib sharedInstance] enableIPServerMode:FALSE];//务必在调用login接口之前调用
    [[AppKeFuLib sharedInstance] loginWithAppkey:APP_KEY];
    
    //注册离线消息推送
    //xcode 6
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    //xcode 5
#else
    // iOS < 8 Notifications
    [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#endif
    
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 离线消息推送
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //同步deviceToken便于离线消息推送, 同时必须在管理后台上传 .pem文件才能生效
    [[AppKeFuLib sharedInstance] uploadDeviceToken:deviceToken];
    NSLog(@"%@",deviceToken);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"收到推送消息。%@", userInfo);
    /*
     {
        aps =     {
            alert = "客服消息:555";
            badge = 1;
            sound = default;
        };
        channel = appkefu;
        message = 555;
        workgroup = wgdemo;
     }
     */
    
    AudioServicesPlaySystemSound(1321);
    AudioServicesPlaySystemSound(1106);
    AudioServicesPlaySystemSound(1007);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"注册推送失败，原因：%@",error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //苹果官方规定除特定应用类型，如：音乐、VOIP类可以在后台运行，其他类型应用均不得在后台运行，所以在程序退到后台要执行logout登出，
    //离线消息通过服务器推送可接收到
    //在程序切换到前台时，执行重新登录，见applicationWillEnterForeground函数中
    [[AppKeFuLib sharedInstance] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%@",@"WillEnterForeGround");
    //切换到前台重新登录
//如果要启用ip服务器，请设置为TRUE,否则请设置为FALSE, 注意如果设置为TRUE,则客服端登录的时候也需要选择IP服务器
  [[AppKeFuLib sharedInstance] enableIPServerMode:FALSE];//务必在调用login接口之前调用
  [[AppKeFuLib sharedInstance] loginWithAppkey:APP_KEY];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

@end







