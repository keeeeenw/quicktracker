//
//  MBPViewController.m
//  My Budget Planner
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "QPViewController.h"

#define PURCHASE_ID @"purchase_id"
#define PURCHASE_NAME @"purchase_name"
#define PURCHASE_DATE @"purchase_date"
#define PURCHASE_AMOUNT @"purchase_amount"

#define SAVE_ID @"save_id"
#define SAVE_DESCRIPTION @"save_description"
#define SAVE_DATE @"save_date"
#define SAVE_AMOUNT @"save_amount"

@interface QPViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *moneyRemainedLabel;
@property (weak, nonatomic) IBOutlet UITextField *purchaseTextField;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *quickAddButtons;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSwitch;
@property (nonatomic) bool appMode; //0 is spending, 1 is save

@end

@implementation QPViewController

@synthesize moneyRemainedLabel = _moneyRemainedLabel;
@synthesize purchaseTextField = _purchaseTextField;
@synthesize quickAddButtons = _quickAddButtons;
@synthesize modeSwitch = _modeSwitch;
@synthesize appMode = _appMode;

#pragma mark - Helper Methods

- (void)startSpinner:(NSString *)activity
{
    self.navigationItem.title = activity;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:spinner];
}

- (void)stopSpinner
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = self.title;
}

- (void) processPurchase:(NSString *)purchaseAnswer
              fromButton:(UIButton *)sender{
    [self startSpinner:@"Updating Purchase"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    //Create purchase_id by using current time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *purchase_id = [NSString stringWithFormat:@"%f", timeStamp];
    
    //Create purchaseInfo to be recieved spendWithPurchaseInfo:inManangedObjectContext
    NSDictionary *purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  purchase_id,PURCHASE_ID,
                                   date,PURCHASE_DATE,
                                  [NSNumber numberWithDouble:[purchaseAnswer doubleValue]], PURCHASE_AMOUNT,
                                  nil];
    
    //Storing Information to Database
//    [DocumentHelper openDocument:@"Spending" usingBlock:^(UIManagedDocument *document){
//        [Spending spendingWithPurchaseInfo:purchaseInfo inManagedObjectContext:document.managedObjectContext];
//        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
//            if (success) {
//                NSLog(@"New Data Saving Succeed");
//                double currentValue = [self moneyValueInMoneyRemainedLabel] - [purchaseAnswer doubleValue];
//                self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", currentValue];
//                if (sender) {
//                    sender.hidden = NO;
//                }
//                [self stopSpinner];
//            }
//        }];
//    }];
}

- (void) processSaving:(NSString *) saveAmount
            fromButton:(UIButton *)sender {
    [self startSpinner:@"Adding Money"];

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    //Create save_id by using current time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *save_id = [NSString stringWithFormat:@"%f", timeStamp];
    
    //Create saveInfo to be recieved savedWithPurchaseInfo:inManangedObjectContext
    NSDictionary *saveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  save_id,SAVE_ID,
                                  date,SAVE_DATE,
                                  [NSNumber numberWithDouble:[saveAmount doubleValue]], SAVE_AMOUNT,
                                  nil];
    
//    [DocumentHelper openDocument:@"Saving" usingBlock:^(UIManagedDocument *document){
//        [Saving savingWithSaveInfo:saveInfo inManagedObjectContext:document.managedObjectContext];
//        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
//            if (success) {
//                NSLog(@"New Data Saving Succeed");
//                double currentValue = [self moneyValueInMoneyRemainedLabel] + [saveAmount doubleValue];
//                self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", currentValue];
//                if (sender) {
//                    sender.hidden = NO;
//                }
//                [self stopSpinner];
//            }
//        }];
//    }];
}

- (double) moneyValueInMoneyRemainedLabel{
    double moneyValue;
    if ([self.moneyRemainedLabel.text hasPrefix:[[[NSNumberFormatter alloc]init] currencySymbol]]) {
        moneyValue = [[self.moneyRemainedLabel.text substringFromIndex:1] doubleValue];
    } else if (!self.moneyRemainedLabel.text){
        moneyValue = 0;
    } else {
        moneyValue = [self.moneyRemainedLabel.text doubleValue];
    }
    return moneyValue;
}

- (void) updateMoneyRemainedLabel{
    
    //This will be changed to 1 via View Animation
    self.moneyRemainedLabel.alpha = 0;
    
//    [DocumentHelper openDocument:@"Saving" usingBlock:^(UIManagedDocument *document){
//
//        double totalSaving = [[Saving totalSavingInManagedObjectContext:document.managedObjectContext] doubleValue];
//        NSLog(@"Total Saving %f",totalSaving);
//        
//        [DocumentHelper openDocument:@"Spending" usingBlock:^(UIManagedDocument *document){
//            double totalSpending = [[Spending totalSpendingInManagedObjectContext:document.managedObjectContext] doubleValue];
//            double currentValue = totalSaving - totalSpending;
//            [UIView animateWithDuration:1 animations:^{
//                self.moneyRemainedLabel.alpha = 1;
//                            self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", currentValue];
//            }];
//            NSLog(@"Total Spending %f",totalSpending);
//            NSLog(@"Current Value %f", currentValue);
//            
//        }];
//        
//    }];
}

- (void)updateQuickAddButtonsUsingSign:(NSString *)sign{
    for (UIButton *button in self.quickAddButtons) {
        if ([button.titleLabel.text hasPrefix:@"+"]||
            [button.titleLabel.text hasPrefix:@"-"]) {
            NSString *figure = [button.titleLabel.text substringFromIndex:1];
            [button setTitle:[sign stringByAppendingString:figure] forState:UIControlStateNormal];
            [button setTitle:[sign stringByAppendingString:figure] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - Guesture Handling
- (IBAction)quickAddSwiped:(UISwipeGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.view];
    CGPoint moneyRemainedLabelLocation = self.moneyRemainedLabel.center;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            __block UIButton *button = (UIButton *)view;
            __block CGRect originalFrame = button.frame;
            if (CGRectContainsPoint(view.frame, touchLocation)){
                [UIView animateWithDuration:1 animations:^{
                    button.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.01,0.01);
                    button.center = moneyRemainedLabelLocation;
                    } completion:^(BOOL finished){
                        button.transform = CGAffineTransformIdentity;
                        button.frame = originalFrame;
                        [self quickAddPressed:button];
                }];
            }
        }
    }
}


#pragma mark - Target Action
- (IBAction)purchaseEntered:(UIButton *)sender {
    if ([self.purchaseTextField.text length] > 0) {
        [self.purchaseTextField resignFirstResponder];
    } else {
        [self.purchaseTextField becomeFirstResponder];
    }
}

- (IBAction)quickAddPressed:(UIButton *)sender {
    if ([sender.titleLabel.text hasPrefix:@"+"]) {
        NSString *addAmount = [sender.titleLabel.text substringFromIndex:1];
        sender.hidden = YES;
        [self processSaving:addAmount
                 fromButton:sender];
    } else if([sender.titleLabel.text hasPrefix:@"-"]){
        NSString *subtractAmount = [sender.titleLabel.text substringFromIndex:1];
        sender.hidden = YES;
        [self processPurchase:subtractAmount fromButton:sender];
    }
}

- (IBAction)modeSwitchValueChanged:(UISegmentedControl *)sender {
    int index = [sender selectedSegmentIndex];
    if (index == 0) {
        self.appMode = false; //Spending
        [self updateQuickAddButtonsUsingSign:@"-"];
    } else {
        self.appMode = true; //Saving
        [self updateQuickAddButtonsUsingSign:@"+"];
    }
    
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self processPurchase:self.purchaseTextField.text fromButton:nil];
    self.purchaseTextField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.purchaseTextField.text length] > 0) {
        [self.purchaseTextField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Setting up self.purchaseTextField
    self.purchaseTextField.delegate = self;
    self.purchaseTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    //Adding CurrencyLabel to self.purchaseTextField
    UILabel *currencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    currencyLabel.text = [[[NSNumberFormatter alloc]init]currencySymbol];
    currencyLabel.font = self.purchaseTextField.font;
    [currencyLabel sizeToFit];
    self.purchaseTextField.leftView = currencyLabel;
    self.purchaseTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //Setting up self.moneyRemainedLabel
    [self updateMoneyRemainedLabel];
    
    //Setting up title
    self.navigationItem.title = self.title;
}

- (void)viewDidUnload
{
    [self setMoneyRemainedLabel:nil];
    [self setPurchaseTextField:nil];
    [self setQuickAddButtons:nil];
    [self setModeSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
