//
//  AppDelegate.m
//  ToDoLite
//
//  Created by Pasin Suriyentrakorn on 10/11/14.
//  Copyright (c) 2014 Pasin Suriyentrakorn. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "Profile.h"
#import "NSString+Additions.h"

// Sync Gateway:
#define kSyncGatewayUrl @"http://localhost:5984/todolite"
//#define kSyncGatewayUrl @"http://<IP>:4984/todos"

// Enable/disable WebSocket in pull replication:
#define kSyncGatewayWebSocketSupport NO

// Guest DB Name:
#define kGuestDBName @"guest"

// Storage Type: kCBLSQLiteStorage or kCBLForestDBStorage
#define kStorageType kCBLSQLiteStorage

// Enable or disable logging:
#define kLoggingEnabled YES

@interface AppDelegate () <UISplitViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) NSError *lastSyncError;
@property (nonatomic) UIAlertView *facebookLoginAlertView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self enableLogging];
    
    LoginViewController *loginViewController =
        (LoginViewController *)self.window.rootViewController;

    // Guest login:
    if ([self isFirstTimeUsed] || [self isGuestLoggedIn]) {
        loginViewController.skipLogin = YES;
        [self loginAsGuest];
        return YES;
    }

    loginViewController.skipLogin = YES;

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)replaceRootViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UISplitViewController class]]) {
        // Setup SplitViewController
        UISplitViewController *splitViewController = (UISplitViewController *)controller;
        if ([[[UIDevice currentDevice] systemVersion]
             compare:@"8.0"
             options:NSNumericSearch] != NSOrderedAscending) {
            if ([[splitViewController.viewControllers lastObject]
                 isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController =
                    [splitViewController.viewControllers lastObject];
                navigationController.topViewController.navigationItem.leftBarButtonItem =
                    splitViewController.displayModeButtonItem;
            }
        }
        splitViewController.delegate = self;
    }
    self.window.rootViewController = controller;
}

#pragma mark - Properties

- (NSString *)currentUserId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"user_id"];
}

- (void)setCurrentUserId:(NSString *)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:@"user_id"];
    [defaults synchronize];
}

#pragma mark - Message

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Logging
- (void)enableLogging {
    if (kLoggingEnabled) {
        [CBLManager enableLogging:@"CBLDatabase"];
        [CBLManager enableLogging:@"View"];
        [CBLManager enableLogging:@"ViewVerbose"];
        [CBLManager enableLogging:@"Query"];
        [CBLManager enableLogging:@"Sync"];
        [CBLManager enableLogging:@"SyncVerbose"];
        [CBLManager enableLogging:@"ChangeTracker"];
    }
}

#pragma mark - Database

- (void)setCurrentDatabase:(CBLDatabase *)database {
    [self willChangeValueForKey:@"database"];
    _database = database;
    [self didChangeValueForKey:@"database"];
}

- (NSString *)databaseNameForName:(NSString *)name {
    return [NSString stringWithFormat:@"db%@", [[name MD5] lowercaseString]];
}

- (CBLDatabase *)databaseForName:(NSString *)name {
    NSString *dbName = [self databaseNameForName:name];
    NSError *error;

    CBLDatabaseOptions *option = [[CBLDatabaseOptions alloc] init];
    option.create = YES;
    option.storageType = kStorageType;
    CBLDatabase *database = [[CBLManager sharedInstance] openDatabaseNamed:dbName
                                                               withOptions:option
                                                                     error:&error];
    if (error) {
        NSLog(@"Cannot create database with an error : %@", [error description]);
    }
    return database;
}

- (CBLDatabase *)databaseForUser:(NSString *)user {
    if (!user) return nil;
    return [self databaseForName:user];
}

- (CBLDatabase *)databaseForGuest {
    return [self databaseForName:kGuestDBName];
}

#pragma mark - Replication

- (void)startReplication {
    
    if (!_pull) {
        NSURL *syncUrl = [NSURL URLWithString:kSyncGatewayUrl];
        _pull = [self.database createPullReplication:syncUrl];
        _pull.continuous  = YES;
        
        _push = [self.database createPushReplication:syncUrl];
        _push.continuous = YES;
        
        // Observe replication progress changes, in both directions:
        NSNotificationCenter *nctr = [NSNotificationCenter defaultCenter];
        [nctr addObserver:self selector:@selector(replicationProgress:)
                     name:kCBLReplicationChangeNotification object:_pull];
        [nctr addObserver: self selector: @selector(replicationProgress:)
                     name:kCBLReplicationChangeNotification object:_push];
    }
    
    if (_push.running)
        [_push stop];
    [_push start];
    
    if (_pull.running)
        [_pull stop];
    [_pull start];
}

- (void)replicationProgress:(NSNotification *)notification {
    if (_pull.status == kCBLReplicationActive || _push.status == kCBLReplicationActive) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    // Check for any change in error status and display new errors:
    NSError* error = _pull.lastError ? _pull.lastError : _push.lastError;
    if (error != _lastSyncError) {
        _lastSyncError = error;
        if (error) {
            // TODO: Handle sync error properly
        }
    }
}

- (void)stopReplication {
    NSNotificationCenter *nctr = [NSNotificationCenter defaultCenter];
    if (_pull) {
        [_pull stop];
        [_pull deleteCookieNamed:@"SyncGatewaySession"];
        [nctr removeObserver:self name:kCBLReplicationChangeNotification object:_pull];
        _pull = nil;
    }
    if (_push) {
        [_push stop];
        [_push deleteCookieNamed:@"SyncGatewaySession"];
        [nctr removeObserver:self name:kCBLReplicationChangeNotification object:_push];
        _pull = nil;
    }
}

#pragma mark - Login & Logout

- (BOOL)isFirstTimeUsed {
    return [[[CBLManager sharedInstance] allDatabaseNames] count] == 0;
}

- (BOOL)isUserLoggedIn {
    return self.currentUserId != nil;
}

- (BOOL)isGuestLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"guest"] boolValue];
}

- (void)setGuestLoggedIn:(BOOL)status {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:status] forKey:@"guest"];
    [defaults synchronize];
}

- (void)loginAsGuest {
    CBLDatabase *database = [self databaseForGuest];
    [self setCurrentDatabase:database];
    [self setGuestLoggedIn:YES];
    [self setCurrentUserId:nil];
}


- (void)logout {


    [self setCurrentUserId:nil];
    [self stopReplication];
    [self setCurrentDatabase:nil];
    
    [self performSelector:@selector(replaceRootViewController:)
               withObject:[self.window.rootViewController.storyboard instantiateInitialViewController]
               afterDelay:0.0];
}

- (void)migrateGuestDataToUser:(Profile *)profile {
    CBLDatabase *guestDB = [self databaseForGuest];
    if (guestDB.lastSequenceNumber > 0) {
        CBLQueryEnumerator *rows = [[guestDB createAllDocumentsQuery] run:nil];
        if (!rows) {
            return;
        }
        
        NSError *error;
        CBLDatabase *userDB = profile.database;
        for (CBLQueryRow *row in rows) {
            CBLDocument *doc = row.document;
            
            CBLDocument *newDoc = [userDB documentWithID:doc.documentID];
            [newDoc putProperties:doc.userProperties error:&error];
            if (error) {
                NSLog(@"Error when saving a new document during migrating guest data : %@",
                      [error description]);
                continue;
            }
            
            NSArray *attachments = doc.currentRevision.attachments;
            if ([attachments count] > 0) {
                CBLUnsavedRevision *rev = [newDoc.currentRevision createRevision];
                for (CBLAttachment *att in attachments) {
                    [rev setAttachmentNamed:att.name withContentType:att.contentType content:att.content];
                }
                
                CBLSavedRevision *saved = [rev save:&error];
                if (!saved) {
                    NSLog(@"Error when saving an attachment during migrating guest data : %@",
                          [error description]);
                }
            }
        }
        
        error = nil;
        [List updateAllListsInDatabase:profile.database withOwner:profile error:&error];
        if (error) {
            NSLog(@"Error when transfering the ownership of the list documents : %@",
                  [error description]);
        }
        
        error = nil;
        if (![guestDB deleteDatabase:&error]) {
            NSLog(@"Error when deleting the guest database during migrating guest data : %@",
                  [error description]);
        }
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.facebookLoginAlertView) {
        [self logout];
    }
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
        [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] &&
        ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] list] == nil)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)splitViewController:(UISplitViewController *)splitViewController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        // For iOS7
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        navigationController.topViewController.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    _popoverController = popoverController;
    _displayModeButtonItem = barButtonItem;
}

@end
