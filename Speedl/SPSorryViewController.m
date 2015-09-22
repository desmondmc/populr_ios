//
//  SPSorryViewController.m
//  Populr
//
//  Created by Desmond McNamee on 2015-09-22.
//  Copyright © 2015 Speedl. All rights reserved.
//

#import "SPSorryViewController.h"

@interface SPSorryViewController ()

@end

@implementation SPSorryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[SPAppearance getMainBackgroundColour]];
}

- (IBAction)dismissPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
