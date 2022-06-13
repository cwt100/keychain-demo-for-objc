//
//  ViewController.m
//  iOSKeychainTest
//
//  Created by wanting_cheng on 2022/6/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *key = @"UUID";
    NSString *UID = @"A123456789";
    BOOL result = [self insert:key :[UID dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"Insert Result: %@", [NSNumber numberWithBool:result]);
    
    NSData *queryResult = [self find:key];
    if (queryResult == nil) {
        return;
    }
    NSLog(@"Query Result: %@", [NSString stringWithUTF8String:[queryResult bytes]]);
    
    result = [self remove:key];
    NSLog(@"Remove Result: %@", [NSNumber numberWithBool:result]);
    
    NSData *query2Result = [self find:key];
    if (query2Result == nil) {
        return;
    }
    NSLog(@"Query Result: %@", [NSString stringWithUTF8String:[query2Result bytes]]);
    
}

- (NSMutableDictionary *)prepareDict: (NSString *)key {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodeKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    [dict setObject:encodeKey forKey:(__bridge id)kSecAttrGeneric];
    [dict setObject:encodeKey forKey:(__bridge id)kSecAttrAccount];
    [dict setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    return dict;
}

- (BOOL)insert: (NSString *)key :(NSData *)data {
    
    NSMutableDictionary *dict = [self prepareDict:key];
    [dict setObject:data forKey:(__bridge  id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
    if (errSecSuccess != status) {
        NSLog(@"Add item failed with key = %@ error: %d", key, (int)status);
    }
    return (status == errSecSuccess);
}

- (NSData *)find: (NSString *)key {
    
    NSMutableDictionary *dict = [self prepareDict:key];
    [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [dict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);
    
    if (status != errSecSuccess) {
        NSLog(@"Query item failed with key = %@, error: %d", key, (int)status);
        return nil;
    }
    
    return (__bridge NSData *)result;
}

- (BOOL)remove: (NSString *)key {
    
    NSMutableDictionary *dict = [self prepareDict:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dict);
    
    if (status != errSecSuccess) {
        NSLog(@"Delete item failed with key: %@, error: %d", key, (int)status);
    }
    
    return (status == errSecSuccess);
}


@end
