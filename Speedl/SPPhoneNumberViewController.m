//
//  SPPhoneNumberViewController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-24.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPPhoneNumberViewController.h"
#import "CountryPicker.h"
#import "SPPhoneValidation.h"
#import "SPFriendFindingViewController.h"

@interface SPPhoneNumberViewController ()

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) NSArray * codeData;
@property (strong, nonatomic) NSArray * countryNameData;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel1;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel2;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel3;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel4;
@property (strong, nonatomic) IBOutlet UIButton *countryLabelButton;
@property (strong, nonatomic) IBOutlet UILabel *skipLabel;
@property (strong, nonatomic) IBOutlet UILabel *nextLabel;
@property (nonatomic) SPPhoneNumberViewType type;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIImageView *backImage;
@property (strong, nonatomic) IBOutlet UIView *skipView;

@end

@implementation SPPhoneNumberViewController

- (id)initWithType:(SPPhoneNumberViewType)type {
    self = [SPPhoneNumberViewController new];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)setupAppearance {
    [self.view setBackgroundColor:[SPAppearance globalBackgroundColour]];
    [self.phoneNumberField styleAsMainSpeedlTextField];
    
    // Connect data
    self.countryPicker.dataSource = self;
    self.countryPicker.delegate = self;
    [self.countryPicker setBackgroundColor:[UIColor whiteColor]];
    
    self.countryLabelButton.titleLabel.font = [SPAppearance mainTextFieldFont];
    self.countryLabelButton.titleLabel.textColor = [SPAppearance seeThroughColour];
    
    self.helpLabel1.textColor = [SPAppearance seeThroughColour];
    self.helpLabel2.textColor = [SPAppearance seeThroughColour];
    self.helpLabel3.textColor = [SPAppearance seeThroughColour];
    self.helpLabel4.textColor = [SPAppearance seeThroughColour];
    
    [self.skipLabel styleAsSendLabel];
    self.skipLabel.textColor = [UIColor whiteColor];
    [self.nextLabel styleAsSendLabel];
    
    
    switch (_type) {
        case SPPhoneNumberViewTypeNavigation:
            _nextLabel.text = @"Save";
            _skipView.hidden = YES;
            break;
        case SPPhoneNumberViewTypeModel:
            _backButton.hidden = YES;
            _backImage.hidden = YES;
            break;
        default:
            break;
    }
    
}

- (void)setupPickerData {
    NSString *countryCode = [SPPhoneValidation getUserCountryCodeNeverNil];
    
    NSUInteger index = [[self codeData] indexOfObject: countryCode];
    [self.countryPicker selectRow:index inComponent:0 animated:YES];
    
    [self.countryLabelButton setTitle:[self countryNameData][index] forState:UIControlStateNormal];
}

#pragma mark UIPickerView

- (NSArray *)codeData {
    if (!_codeData) {
        _codeData = [CountryPicker countryCodes];
    }
    return _codeData;
}

- (NSArray *)countryNameData {
    if (!_countryNameData) {
        _countryNameData = [CountryPicker countryNames];
    }
    return _countryNameData;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%@ - %@", [self countryNameData][row], [self codeData][row]];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[SPAppearance globalBackgroundColour]}];
    
    return attString;
    
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self codeData].count;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *chosenStatusCode = [self codeData][row];
    NSString *chosenCountry = [self countryNameData][row];
    [SPPhoneValidation setUserCountryCode:chosenStatusCode];
    [self.countryLabelButton setTitle:chosenCountry forState:UIControlStateNormal];
}

#pragma mark Buttons

- (IBAction)onSkipPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBackPress:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onGoPress:(id)sender {
    NSString *phoneNumber = self.phoneNumberField.text;
    NSString *countryCode = [SPPhoneValidation getUserCountryCode];
    
    BOOL isValid = [SPPhoneValidation checkValidPhoneNumber:phoneNumber
                                                countryCode:countryCode];
    
    if (!isValid) {
        [SPNotification showErrorNotificationWithMessage:@"Invalid phone number" inViewController:self];
        return;
    }
    
    NSString *internationalNumber = [SPPhoneValidation getInternationalNumberFromPhoneNumber:phoneNumber
                                                                                 countryCode:countryCode];
    
    // Send backend nation number + CC
    [[SPUser currentUser] postPhoneNumberInBackground:internationalNumber countryCode:countryCode block:^(BOOL success, NSString *serverMessage) {
        if (success) {
            [SPNotification showSuccessNotificationWithMessage:@"Phone number saved!" inViewController:self];
            switch (_type) {
                case SPPhoneNumberViewTypeModel:
                    [self dismissViewControllerAnimated:YES completion:nil];
                    break;
                    
                default:
                    break;
            }
        }
        else {
            [SPNotification showErrorNotificationWithMessage:@"Error saving number" inViewController:self];
        }
    }];

}

- (IBAction)onCountryLabelPress:(id)sender {
    [self.phoneNumberField resignFirstResponder];
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.phoneNumberField becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Called here so user can see the picker animate.
    [self setupPickerData];
}

@end
