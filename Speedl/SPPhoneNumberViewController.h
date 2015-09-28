//
//  SPPhoneNumberViewController.h
//  Populr
//
//  Created by Desmond McNamee on 2015-09-24.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SPPhoneNumberViewType) {
    SPPhoneNumberViewTypeModel,
    SPPhoneNumberViewTypeNavigation
};

@interface SPPhoneNumberViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (id)initWithType:(SPPhoneNumberViewType)type;

@end
