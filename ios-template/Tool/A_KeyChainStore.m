//
//  KeyChainStore.m
//  500070
//
//  Created by 叶建辉 on 2022/7/23.
//  Copyright © 2022 egret. All rights reserved.
//

#import "A_KeyChainStore.h"
#import <AdSupport/AdSupport.h>
@implementation A_KeyChainStore
+ (NSMutableDictionary*)getKeychainQuery:(NSString*)C_service {
    return[NSMutableDictionary dictionaryWithObjectsAndKeys:
           (id)kSecClassGenericPassword,(id)kSecClass,
           C_service,(id)kSecAttrService,
           C_service,(id)kSecAttrAccount,
           (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
           nil];
}
 
+ (void)B_save:(NSString*)C_service data:(id)C_data{
    //Get search dictionary
    NSMutableDictionary*keychainQuery = [self getKeychainQuery:C_service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to searchdictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:C_data]forKey:(id)kSecValueData];
    //Add item to keychain with the searchdictionary
    SecItemAdd((CFDictionaryRef)keychainQuery,NULL);
}
 
+ (id)B_load:(NSString*)C_service {
    id C_ret =nil;
    NSMutableDictionary*C_keychainQuery = [self getKeychainQuery:C_service];
    //Configure the search setting
    //Since in our simple case we areexpecting only a single attribute to be returned (the password) wecan set the attribute kSecReturnData to kCFBooleanTrue
    [C_keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [C_keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef C_keyData =NULL;
    if(SecItemCopyMatching((CFDictionaryRef)C_keychainQuery,(CFTypeRef*)&C_keyData) ==noErr){
        @try{
            C_ret =[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)C_keyData];
        }@catch(NSException *e) {
            NSLog(@"Unarchiveof %@ failed: %@",C_service, e);
        }@finally{
        }
    }
    if(C_keyData)
        CFRelease(C_keyData);
    return C_ret;
}
 
+ (void)B_deleteKeyData:(NSString*)C_service {
    NSMutableDictionary*C_keychainQuery = [self getKeychainQuery:C_service];
    SecItemDelete((CFDictionaryRef)C_keychainQuery);
}


+ (NSString *)B_getUUIDByKeyChain{
    // 这个key的前缀最好是你的BundleID
    
    NSString *C_identifier = [NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSString*C_strUUID = (NSString*)[A_KeyChainStore B_load:C_identifier];
    //首次执行该方法时，uuid为空
    if([C_strUUID isEqualToString:@""]|| !C_strUUID)
    {
        // 获取UUID 这个是要引入<AdSupport/AdSupport.h>的
        C_strUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        
        if(C_strUUID.length ==0 || [C_strUUID isEqualToString:@"00000000-0000-0000-0000-000000000000"])
        {
            //生成一个uuid的方法
            CFUUIDRef C_uuidRef= CFUUIDCreate(kCFAllocatorDefault);
            C_strUUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault,C_uuidRef));
            CFRelease(C_uuidRef);
        }
        
        //将该uuid保存到keychain
        [A_KeyChainStore B_save:C_identifier data:C_strUUID];
    }
    return C_strUUID;
}


@end
