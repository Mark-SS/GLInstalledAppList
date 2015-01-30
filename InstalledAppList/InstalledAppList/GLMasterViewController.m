//
//  GLMasterViewController.m
//  InstalledAppList
//
//  Created by gongliang on 14/9/29.
//  Copyright (c) 2014年 GL. All rights reserved.
//

#import "GLMasterViewController.h"
#import "GLDetailViewController.h"
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <dlfcn.h>
#import "AppTimeCounter.h"

#define kPATH_OF_DOCUMENT   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
static NSString* const installedAppListPath = @"/private/var/mobile/Library/Caches/com.apple.IconsCache";

@interface GLMasterViewController ()

@property NSMutableArray *objects;

@property NSMutableArray *images;

@property (nonatomic, strong) NSObject* workspace;

@end

@implementation GLMasterViewController

-(NSMutableArray *)desktopAppsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *desktopApps = [NSMutableArray array];
    
    for (NSString *appKey in dictionary)
    {
        [desktopApps addObject:appKey];
    }
    return desktopApps;
}


-(NSArray *)installedApp
{
    BOOL isDir = NO;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    BOOL aa = [[NSFileManager defaultManager] fileExistsAtPath: installedAppListPath isDirectory: &isDir];
    NSArray *file = [fileManage subpathsOfDirectoryAtPath: installedAppListPath error:nil];
    NSLog(@"%@",file);

    
    if([[NSFileManager defaultManager] fileExistsAtPath: installedAppListPath isDirectory:&isDir])
    {
       BOOL success = [fileManage copyItemAtPath:installedAppListPath toPath:[kPATH_OF_DOCUMENT stringByAppendingString:@"/456"] error:nil];
    
        
        UIImage *image = [UIImage imageWithContentsOfFile:installedAppListPath];
        NSData *data = [NSData dataWithContentsOfFile:installedAppListPath];
        [data writeToFile:[kPATH_OF_DOCUMENT stringByAppendingString:@"/456"] atomically:YES];
        NSMutableDictionary *cacheDict = [NSDictionary dictionaryWithContentsOfFile: installedAppListPath];
        NSDictionary *system = [cacheDict objectForKey: @"System"];
        NSMutableArray *installedApp = [NSMutableArray arrayWithArray:[self desktopAppsFromDictionary:system]];
        
        NSDictionary *user = [cacheDict objectForKey: @"User"];
        [installedApp addObjectsFromArray:[self desktopAppsFromDictionary:user]];
        
        return installedApp;
    }
    
    NSLog(@"can not find installed app plist");
    return nil;
}


//-(mach_port_t)getFrontMostAppPort
//{
//    bool locked;
//    bool passcode;
//    mach_port_t *port;
//    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
//    int (*SBSSpringBoardServerPort)() = dlsym(lib, "SBSSpringBoardServerPort");
//    void* (*SBGetScreenLockStatus)(mach_port_t* port, bool *lockStatus, bool *passcodeEnabled) = dlsym(lib, "SBGetScreenLockStatus");
//    port = (mach_port_t *)SBSSpringBoardServerPort();
//    dlclose(lib);
//    SBGetScreenLockStatus(port, &locked, &passcode);
//    void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
//    char appId[256];
//    memset(appId, 0, sizeof(appId));
//    SBFrontmostApplicationDisplayIdentifier(port, appId);
//    NSString * frontmostApp=[NSString stringWithFormat:@"%s",appId];
//    if([frontmostApp length] == 0 || locked)
//        return GSGetPurpleSystemEventPort();
//    else
//        return GSCopyPurpleNamedPort(appId);
//}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _objects = [NSMutableArray new];
    _images = [NSMutableArray new];
    [self installedApp];
    
//    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/GAIA.framework"];
//    BOOL success = [b load];
//    
//    Class SKTelephonyController = NSClassFromString(@"SKTelephonyController");
//    id tc = [SKTelephonyController performSelector:@selector(sharedInstance)];
//    
//    NSLog(@"-- myPhoneNumber: %@", [tc  performSelector:@selector(myPhoneNumber)]);
//    NSLog(@"-- imei: %@", [tc  performSelector:@selector(imei)]);
    // Do any additional setup after loading the view, typically from a nib.

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    _workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    //@NSLog(@"apps: %@", [workspace performSelector:@selector(allApplications)]);
    NSArray *array = [_workspace performSelector:@selector(allInstalledApplications)];
    [array enumerateObjectsUsingBlock:^(LSApplicationProxy *obj, NSUInteger idx, BOOL *stop) {
        NSString *string = [obj performSelector:@selector(applicationIdentifier)];
        if (![string hasPrefix:@"com.apple"]) {
//            if (obj.localizedName) {
//                [_objects addObject:obj.localizedName];
//            } else {
//                NSLog(@"%@", obj.localizedName);
//            }
            
            [_objects addObject:obj];
            
            
//            UIImage *image = [UIImage imageNamed:[obj boundIconsDictionary][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"][0]];
            
//            NSURL *path = [obj boundResourcesDirectoryURL];
//            if ([[UIApplication sharedApplication] canOpenURL:path]) {
//                
//            }
            
//            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[path absoluteString] stringByAppendingPathComponent:[obj boundIconsDictionary][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"][0]]];
            
            // resourcesDirectoryURL
//            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[[obj resourcesDirectoryURL] absoluteString] stringByAppendingPathComponent:@"icon.png"]]];
//            NSLog(@"data = %@", [NSBundle bundleWithURL:obj.bundleURL]);
    
    //        [data writeToFile:[kPATH_OF_DOCUMENT stringByAppendingString:@"/123"] atomically:YES];
            NSLog(@"%@ = %@", obj.localizedName, obj.boundIconCacheKey);
            _objects = [[_objects sortedArrayUsingComparator:^NSComparisonResult(LSApplicationProxy *obj1, LSApplicationProxy *obj2) {
                NSMutableString *pinyin1 = [NSMutableString string];
                [pinyin1 appendString:phonetic(obj1.localizedName)];
                NSMutableString *pinyin2 = [NSMutableString string];
                [pinyin2 appendString:phonetic(obj2.localizedName)];
                NSComparisonResult result = [pinyin1 compare:pinyin2];
                return result == NSOrderedDescending;
            }] mutableCopy];
        }
    }];
    [self.tableView reloadData];
    
    NSString *string = @"/private/var/mobile/Library/Caches/com.apple.IconsCache";
    
    
    self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"总数: %ld", _objects.count];
    
    
}

static NSString *phonetic(NSString *sourceString) {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    return source;
}

static NSString *kickNull(NSString *string) {
    if (!string) return @"";
    return string;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        LSApplicationProxy *proxy = self.objects[indexPath.row];
        if ([[UIApplication sharedApplication] canOpenURL:[proxy bundleURL]]) {
            [[UIApplication sharedApplication] openURL:[proxy bundleURL]];
        }
        [[segue destinationViewController] setDetailItem:proxy.localizedName];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

//    cell.imageView.image = _images[indexPath.row];
    LSApplicationProxy *proxy = self.objects[indexPath.row];
    cell.textLabel.text = [proxy localizedName];
//    cell.imageView.image = [self]
    cell.imageView.image = [[AppTimeCounter sharedInstance] getAppIconImageByBundleId:proxy.bundleIdentifier];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSApplicationProxy *proxy = self.objects[indexPath.row];
    [_workspace performSelector:@selector(openApplicationWithBundleID:)
                     withObject:proxy.bundleIdentifier];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
