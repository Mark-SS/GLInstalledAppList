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

@property (nonatomic, strong) NSObject* workspace;

@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic, strong) NSMutableDictionary *dataDics;

@end

@implementation GLMasterViewController

- (NSMutableArray *)desktopAppsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *desktopApps = [NSMutableArray array];
    
    for (NSString *appKey in dictionary)
    {
        [desktopApps addObject:appKey];
    }
    return desktopApps;
}

- (NSArray *)installedApp
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

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keyArray = [NSArray new];
    _dataDics = [NSMutableDictionary dictionary];
    [self installedApp];
    
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    _workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray *array = [_workspace performSelector:@selector(allInstalledApplications)];
    NSMutableSet *set = [NSMutableSet set];
    static NSUInteger i = 0;
    [array enumerateObjectsUsingBlock:^(LSApplicationProxy *obj, NSUInteger idx, BOOL *stop) {
        NSString *string = [obj performSelector:@selector(applicationIdentifier)];
        if (![string hasPrefix:@"com.apple"]) {
            NSString *nameString = phonetic2(obj.localizedName);
            NSString *firstName = [[nameString substringToIndex:1] uppercaseString];
            [set addObject:firstName];
            NSLog(@"nameString = %@", nameString);
            NSMutableArray *objectByfirstNames = _dataDics[firstName];
            if (!objectByfirstNames || objectByfirstNames.count == 0) {
                objectByfirstNames = [NSMutableArray array];
            }
            [objectByfirstNames addObject:obj];
            _dataDics[firstName] = objectByfirstNames;
            i++;
        }
    }];
    
    _keyArray = [set.allObjects sortedArrayUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
    
    //NSString *string = @"/private/var/mobile/Library/Caches/com.apple.IconsCache";
    self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"总数: %ld", i];
}

static NSString *phonetic(NSString *sourceString) {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    return source;
}

static NSString *phonetic2(NSString *sourceString) {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

static NSString *kickNull(NSString *string) {
    if (!string) return @"";
    return string;
}


#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        LSApplicationProxy *proxy = self.dataDics[_keyArray[indexPath.section]][indexPath.row];
        if ([[UIApplication sharedApplication] canOpenURL:[proxy bundleURL]]) {
            [[UIApplication sharedApplication] openURL:[proxy bundleURL]];
        }
        [[segue destinationViewController] setDetailItem:proxy.localizedName];
    }
}

#pragma mark - Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataDics[_keyArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    LSApplicationProxy *proxy = self.dataDics[_keyArray[indexPath.section]][indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
    nameLabel.text = [proxy localizedName];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
    imageView.image = [[AppTimeCounter sharedInstance] getAppIconImageByBundleId:proxy.bundleIdentifier];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSApplicationProxy *proxy = self.dataDics[_keyArray[indexPath.section]][indexPath.row];
    [_workspace performSelector:@selector(openApplicationWithBundleID:)
                     withObject:proxy.bundleIdentifier];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keyArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _keyArray[section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


@end
