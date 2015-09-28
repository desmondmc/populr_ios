//
//  SPPhoneValidation.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-24.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPPhoneValidation.h"
#import "NBPhoneNumberUtil.h"

#define kCountryCode @"SPCountryCode"

@implementation SPPhoneValidation

+ (BOOL)checkValidPhoneNumber:(NSString *)phoneNumber
                  countryCode:(NSString *)countryCode {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *error = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phoneNumber
                                 defaultRegion:countryCode error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    return [phoneUtil isValidNumber:myNumber];
}

+ (NSString *)getInternationalNumberFromPhoneNumber:(NSString *)phoneNumber
                                   countryCode:(NSString *)countryCode {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error = nil;
    
    NBPhoneNumber *myNumber = [phoneUtil parse:phoneNumber
                                 defaultRegion:countryCode error:&error];
    
    NSString *numberWithFormatting =  [phoneUtil format:myNumber
                numberFormat:NBEPhoneNumberFormatE164
                       error:&error];
    
    
    return [phoneUtil normalizeDigitsOnly:numberWithFormatting];
}

+ (NSString *)getUserCountryCodeNeverNil {
    NSString *countryCode = [SPPhoneValidation getUserCountryCode];
    if (!countryCode) {
        [SPPhoneValidation setDefaultUserCountryCode];
        countryCode = [SPPhoneValidation getUserCountryCode];
    }
    return countryCode;
}

+ (NSString *)getUserCountryCode {
    NSString *savedCountryCode = [[NSUserDefaults standardUserDefaults]
                            stringForKey:kCountryCode];
    
    return savedCountryCode;
}

+ (void)setUserCountryCode:(NSString *)countryCode {
    [[NSUserDefaults standardUserDefaults] setObject:countryCode forKey:kCountryCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setDefaultUserCountryCode {
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    [[NSUserDefaults standardUserDefaults] setObject:countryCode forKey:kCountryCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
