//
//  SPPhoneValidation.h
//  Populr
//
//  Created by Desmond McNamee on 2015-09-24.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPhoneValidation : NSObject

+ (BOOL)checkValidPhoneNumber:(NSString *)phoneNumber
                  countryCode:(NSString *)countryCode;

+ (NSString *)getInternationalNumberFromPhoneNumber:(NSString *)phoneNumber
                                        countryCode:(NSString *)countryCode;

+ (NSString *)getUserCountryCode;

+ (void)setUserCountryCode:(NSString *)countryCode;

+ (void)setDefaultUserCountryCode;

+ (NSString *)getUserCountryCodeNeverNil;

@end
