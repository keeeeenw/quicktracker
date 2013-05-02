//
//  QPViewController.m
//  QuickTracker
//
//  Created by Zixiao on 12-8-8.
//  Copyright (c) 2012年 Zixiao Wang. All rights reserved.
//

#import "QPViewController.h"
#import "DocumentHelper.h"
#import "Spending+Budget.h"
#import "Saving+Budget.h"
#import <CoreLocation/CoreLocation.h>

@interface QPViewController () <UITextFieldDelegate,UIActionSheetDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *moneyRemainedLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyUpdateLabel;
@property (weak, nonatomic) IBOutlet UITextField *purchaseTextField; //this is also used to process saving
//@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *quickAddButtons;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSwitch;
@property (nonatomic) BOOL appMode; //0 is spending, 1 is save
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UIAlertView *digitChangeAlertView;
@property int buttonPressedIndex; //index of the button pressed by user

//Outlets for all the quick buttons
@property (weak, nonatomic) IBOutlet UIButton *quickButton1;
@property (weak, nonatomic) IBOutlet UIButton *quickButton2;
@property (weak, nonatomic) IBOutlet UIButton *quickButton3;
//@property (weak, nonatomic) IBOutlet UIButton *quickButton4;
@property (weak, nonatomic) IBOutlet UIButton *quickButton5;
@property (weak, nonatomic) IBOutlet UIButton *quickButton6;
@property (weak, nonatomic) IBOutlet UIButton *quickButton7;
//@property (weak, nonatomic) IBOutlet UIButton *quickButton8;

@property (strong, nonatomic) NSArray *quickAddButtons; //collection of the buttons above
@property (strong, nonatomic) CLLocationManager *locationManager; //prcoess location

//TODO: Light Weight Data Migration
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation QPViewController

@synthesize moneyRemainedLabel = _moneyRemainedLabel;
@synthesize purchaseTextField = _purchaseTextField;
@synthesize modeSwitch = _modeSwitch;
@synthesize appMode = _appMode;

#pragma mark - Sync Models and Views
-(CLLocationManager *) locationManager{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"MBPModel.sqlite"]];
//    
//    // handle db upgrade
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
//                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
//        // Handle error
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//- (NSManagedObjectModel *)managedObjectModel {
//    
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"MBPModel" ofType:@"momd"];
//    NSURL *momURL = [NSURL fileURLWithPath:path];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
//    
//    return _managedObjectModel;
//}

#pragma mark - Setup Properties
-(UIAlertView *) alertView{
    if (!_alertView) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"zh-Hans"]) {
            NSString *cnMsg = @"亲，你是否想要清除你的储蓄和消费数据？";
            _alertView = [[UIAlertView alloc] initWithTitle:@"请稍等!" message:cnMsg delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        } else {
            NSString *enMsg = @"Do you want to clear all of your spending and saving data?";
            _alertView = [[UIAlertView alloc] initWithTitle:@"Wait!" message:enMsg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        }
    }
    return _alertView;
}


-(UIAlertView *) digitChangeAlertView{
    if (!_digitChangeAlertView) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"zh-Hans"]) {
            NSString *cnMsg = @"请输入新的自定义金额";
            _digitChangeAlertView = [[UIAlertView alloc] initWithTitle:@"自定义快速输入键" message:cnMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        } else {
            NSString *enMsg = @"Please enter the new amount";
            _digitChangeAlertView = [[UIAlertView alloc] initWithTitle:@"Customize Quick Button" message:enMsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        }
    }
    
    [_digitChangeAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [_digitChangeAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    return _digitChangeAlertView;
}

-(NSArray *)quickAddButtons{
    if(_quickAddButtons){
        _quickAddButtons = [[NSArray alloc]initWithObjects:self.quickButton1,self.quickButton2,
                            self.quickButton3,self.quickButton5,self.quickButton6,self.quickButton7,nil];
    }
    return _quickAddButtons;
}

#pragma mark - Helper Methods

-(void)setup{
    
    //Adding CurrencyLabel to self.purchaseTextField
    UILabel *currencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    currencyLabel.text = [[[NSNumberFormatter alloc]init]currencySymbol];
    currencyLabel.font = self.purchaseTextField.font;
    [currencyLabel sizeToFit];
    self.purchaseTextField.leftView = currencyLabel;
    self.purchaseTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //Store the amount on the quick digit button if not exist
    if (![[NSUserDefaults standardUserDefaults] objectForKey:QUICK_DIGITS]){
        NSMutableArray *digits = [[NSMutableArray alloc]init];
        
        for (UIButton *button in self.quickAddButtons) {
            [digits addObject:[button.titleLabel.text substringFromIndex:1]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[digits copy] forKey:QUICK_DIGITS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSArray *digits = [[[NSUserDefaults standardUserDefaults] objectForKey:QUICK_DIGITS] copy];
        
        NSUInteger index = 0;
        
        for (UIButton *button in self.quickAddButtons) {
            [self updateQuickAddButton:button WithAmount:[digits objectAtIndex:index]];
            index++;
        }
    }
    
    //Setup guesture for each button and the label
    for (UIButton *button in self.quickAddButtons) {
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(quickDigitPressed:)];
        [button addGestureRecognizer:recognizer];
    }
    
    //Setting up self.moneyRemainedLabel
    [self updateMoneyRemainedLabel];
    
    //Updating the digit buttons according to the mode
    if (![[NSUserDefaults standardUserDefaults] objectForKey:MODE]){
        [[NSUserDefaults standardUserDefaults] setBool:self.appMode forKey:MODE];
    } else {
        self.appMode = [[NSUserDefaults standardUserDefaults] boolForKey:MODE];
    }
    
    if (self.appMode) { //This means app is using Saving Mode
        [self updateQuickAddButtonsUsingSign:@"+"];
        [self.modeSwitch setSelectedSegmentIndex:1];
    } else { //This means app is using Spending Mode
        [self updateQuickAddButtonsUsingSign:@"-"];
        [self.modeSwitch setSelectedSegmentIndex:0];
    }
    
    //Attempt to Open CoreData Database to spend up the process
    [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){}];
    [DocumentHelper openDocument:SPEND usingBlock:^(UIManagedDocument *document){}];
    
    //Setting up title
    self.navigationItem.title = self.title;
    
    //Make the keyboard disappear when the user touches outside of the textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self.locationManager startUpdatingLocation]; //try to refresh the data
    [self.locationManager stopUpdatingLocation];
}

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

- (void)updateQuickAddButton:(UIButton *)button WithAmount:(NSString *)amount{
    NSString *sign = @"+";
    if ([button.titleLabel.text hasPrefix:@"-"]){
        sign = @"-";
    }
    [button setTitle:[sign stringByAppendingString:amount] forState:UIControlStateNormal];
    [button setTitle:[sign stringByAppendingString:amount] forState:UIControlStateHighlighted];
}

/**
 Returns the NSString to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths lastObject];
    
    return documentPath;
}

#pragma mark - Money Helper

- (void) processPurchase:(NSString *)purchaseAmount
              fromButton:(UIButton *)sender{
    [self startSpinner:@"Updating Spending"];
    
    [self setMoneyUpdateLabelByAmount:purchaseAmount isSave:NO];
    
    //To spend up the responsiveness of the UI the money label is updated using NSUserDefaults instead of CoreData
    [self updateSpendingByAmount:[purchaseAmount doubleValue]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    //Create purchase_id by using current time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *purchase_id = [NSString stringWithFormat:@"%f", timeStamp];
    
    //Getting the location
    [self.locationManager startUpdatingLocation];
    CLLocation *location = self.locationManager.location;
    NSLog(@"Purchase Location %f %f", location.coordinate.latitude, location.coordinate.longitude);
    NSNumber *latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
    [self.locationManager stopUpdatingLocation];

    
    //Create purchaseInfo to be recieved spendWithPurchaseInfo:inManangedObjectContext
    NSDictionary *purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  purchase_id,PURCHASE_ID,
                                  date,PURCHASE_DATE,
                                  [NSNumber numberWithDouble:[purchaseAmount doubleValue]], PURCHASE_AMOUNT,
                                  latitude, PURCHASE_LATITUDE,
                                  longitude, PURCHASE_LONGITUDE,
                                  nil];
    
    
    //sender.enabled = NO;
    
    //Storing Information to Database
    [DocumentHelper openDocument:SPEND usingBlock:^(UIManagedDocument *document){
        [Spending spendingWithPurchaseInfo:purchaseInfo inManagedObjectContext:document.managedObjectContext];
        sender.enabled = YES;
        [self stopSpinner];
    }];
}

- (void) updateSpendingByAmount:(double) purchaseAmount{
    
    double spending =  [[[NSUserDefaults standardUserDefaults] objectForKey:SPEND] doubleValue];
    spending -= purchaseAmount;
    
    [[NSUserDefaults standardUserDefaults] setDouble:spending forKey:SPEND];
    
    double total = [self moneyValueInMoneyRemainedLabel] - purchaseAmount;
    self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", total];
}

- (void) processSaving:(NSString *) saveAmount
            fromButton:(UIButton *)sender {
    [self startSpinner:@"Updating Saving"];
    
    [self setMoneyUpdateLabelByAmount:saveAmount isSave:YES];

    
    //To spend up the responsiveness of the UI the money label is updated using NSUserDefaults instead of CoreData
    [self updateSavingByAmount:[saveAmount doubleValue]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    //Create save_id by using current time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *save_id = [NSString stringWithFormat:@"%f", timeStamp];
    
    //Getting the location
    [self.locationManager startUpdatingLocation];
    CLLocation *location = self.locationManager.location;
    NSLog(@"Save Location %f %f", location.coordinate.latitude, location.coordinate.longitude);
    NSNumber *latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
    [self.locationManager stopUpdatingLocation];
    
    //Create saveInfo to be recieved savedWithPurchaseInfo:inManangedObjectContext
    NSDictionary *saveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              save_id,SAVE_ID,
                              date,SAVE_DATE,
                              [NSNumber numberWithDouble:[saveAmount doubleValue]], SAVE_AMOUNT,
                              latitude, SAVE_LATITUDE,
                              longitude, SAVE_LONGITUDE,
                              nil];
    //sender.enabled = NO;
    
    [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){
        [Saving savingWithSaveInfo:saveInfo inManagedObjectContext:document.managedObjectContext];
        sender.enabled = YES;
        [self stopSpinner];
    }];
}

- (void) updateSavingByAmount:(double) saveAmount{
    
    double saving =  [[[NSUserDefaults standardUserDefaults] objectForKey:SAVE] doubleValue];
    saving += saveAmount;
    
    [[NSUserDefaults standardUserDefaults] setDouble:saving forKey:SAVE];
    
    double total = [self moneyValueInMoneyRemainedLabel] + saveAmount;
    self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", total];
}

- (void) setMoneyUpdateLabelByAmount:(NSString *)amount isSave:(BOOL)save{
    self.moneyUpdateLabel.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.moneyUpdateLabel.alpha = 1;
        if (save) {
            self.moneyUpdateLabel.text = [NSString stringWithFormat:@"+%@",amount];
        } else {
            self.moneyUpdateLabel.text = [NSString stringWithFormat:@"-%@",amount];
        }
        
        [UIView animateWithDuration:2 animations:^{
            self.moneyUpdateLabel.alpha = 0;
        }];
    }];
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
    
    NSString * msg = @"loading...";
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"]) {
        msg = @"载入中...";
    }
    
    [self startSpinner:msg];
    
    __block double saving;
    __block double spending;
    
    //Create saving/spending keys in NSUserDefaults if they do not exit
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:SAVE] doubleValue]) {
        saving = 0;
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:SAVE];
    } else {
        saving = [[[NSUserDefaults standardUserDefaults] objectForKey:SAVE] doubleValue];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:SPEND] doubleValue]) {
        spending = 0;
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:SPEND];
    } else {
        spending = [[[NSUserDefaults standardUserDefaults] objectForKey:SPEND] doubleValue];
    }
    
    //Update the money label using data in NSUserDefaults
    [UIView animateWithDuration:0.5 animations:^{
        self.moneyRemainedLabel.alpha = 0.8;
        self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", saving+spending];
    }];
    
    //Check whether the data in NSUserDefaults is in conflict with the data in CoreData
    //If there is a conflict, resolve it by using the data in CoreData
    
    [DocumentHelper openDocument:SPEND usingBlock:^(UIManagedDocument *document){
        __block double coreDataSpending = [[Spending totalSpendingInManagedObjectContext:document.managedObjectContext] doubleValue];
            
        [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){
            double coreDataSaving = [[Saving totalSavingInManagedObjectContext:document.managedObjectContext] doubleValue];
            
            NSLog(@"Saving is %.2f", saving);
            NSLog(@"Spending is %.2f", spending);
            NSLog(@"coreDataSaving is %.2f", coreDataSaving);
            NSLog(@"coreDataSaving is %.2f", coreDataSpending);

            
            if (coreDataSaving != saving) {
                NSLog(@"Saving Data is in conflict");
                saving = coreDataSaving;
                [[NSUserDefaults standardUserDefaults] setDouble:saving forKey:SAVE];
            }
            
            if (-1*coreDataSpending != spending){
                NSLog(@"Spending Data is in conflict");
                spending = -1*coreDataSpending;
                [[NSUserDefaults standardUserDefaults] setDouble:spending forKey:SPEND];
            }
            
            double total = saving + spending; //noted spending is negative
            
            [UIView animateWithDuration:0.5 animations:^{
                self.moneyRemainedLabel.alpha = 1;
                self.moneyRemainedLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", total];
                [self stopSpinner];
            }];
        }];
    }];
    
}

#pragma mark - Guesture Handling
- (IBAction)quickAddSwiped:(UISwipeGestureRecognizer *)sender {
    //handles the speical swipe up of the digit button
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

- (void)quickDigitPressed:(UILongPressGestureRecognizer *)sender {
    //handles holding of digit button that changes digit amount
    UIButton *buttonPressed = (UIButton *)sender.view;
    
    for (NSInteger i=0; i<[self.quickAddButtons count]; i++) {
        UIButton *button = [self.quickAddButtons objectAtIndex:i];
        if ([button isEqual:buttonPressed]){
            self.buttonPressedIndex = i;
        }
    }
    
    [self.digitChangeAlertView show];
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
        //sender.hidden = YES;
        [self processSaving:addAmount
                 fromButton:sender];
    } else if([sender.titleLabel.text hasPrefix:@"-"]){
        NSString *subtractAmount = [sender.titleLabel.text substringFromIndex:1];
        //sender.hidden = YES;
        
        [self processPurchase:subtractAmount fromButton:sender];
    }
}

- (IBAction)modeSwitchValueChanged:(UISegmentedControl *)sender {
    int index = [sender selectedSegmentIndex];
    if (index == 0) {
        self.appMode = NO; //Spending
        [self updateQuickAddButtonsUsingSign:@"-"];
    } else {
        self.appMode = YES; //Saving
        [self updateQuickAddButtonsUsingSign:@"+"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:self.appMode forKey:MODE];
}

- (IBAction)resetPressed:(UIButton *)sender {
    [self.alertView show];
}

-(void)dismissKeyboard {
    //prevent updating the amount when dismiss keyboard
    self.purchaseTextField.text = @"";
    [self.purchaseTextField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == self.alertView) {
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:SAVE];
            [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:SPEND];
            [DocumentHelper removeDocument:SAVE];
            [DocumentHelper removeDocument:SPEND];
            [self setup];
        }
    } else if (alertView == self.digitChangeAlertView){
        if (buttonIndex == 1) {
            NSString *amount = [alertView textFieldAtIndex:0].text;
            //sync with NSUserDefaults
            NSMutableArray *digits = [[[NSUserDefaults standardUserDefaults] objectForKey:QUICK_DIGITS] mutableCopy];
            
            //Find the button that need to be changed and update NSUserDefaults
            
            if (self.buttonPressedIndex >= 0 && ![amount isEqual:@""]) {
                UIButton *button = [self.quickAddButtons objectAtIndex:self.buttonPressedIndex];
                [digits replaceObjectAtIndex:self.buttonPressedIndex withObject:amount];
                [self updateQuickAddButton:button WithAmount:amount];
            }

            
            [[NSUserDefaults standardUserDefaults]setObject:[digits copy] forKey:QUICK_DIGITS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.buttonPressedIndex = 0;
            [alertView textFieldAtIndex:0].text = @"";
        }
    }
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (![textField.text isEqual:@""]) {
        if (self.appMode) {
            [self processSaving:self.purchaseTextField.text fromButton:nil];
        } else {
            [self processPurchase:self.purchaseTextField.text fromButton:nil];
        }
        
        self.purchaseTextField.text = @"";
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.purchaseTextField.text length] > 0) {
        [self.purchaseTextField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //leave here for future implementation
}


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad{
    //Setup Delegate
    //Setting up self.purchaseTextField
    self.purchaseTextField.delegate = self;
    self.purchaseTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    //Setting up UIActionSheetDelegate
    self.alertView.delegate = self;
    self.digitChangeAlertView.delegate = self;
    
    //Setup core location CLLocationManagerDelegate
    self.locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Do any additional setup after loading the view, typically from a nib.
    [self setup];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setBool:self.appMode forKey:MODE];
    [self startSpinner:@"Saving Data"];
    [DocumentHelper openDocument:SPEND usingBlock:^(UIManagedDocument *document){
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            if (!success) { //if not success rollback the updates on NSUserDefault
                NSLog(@"New Spending Data Saving Failed");
            } else{
                NSLog(@"New Spending Data Saving Succeed");
            }
        }];
        [self stopSpinner];
    }];
    [self startSpinner:@"Saving Data"];
    [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            if (!success) { //if not success rollback the updates on NSUserDefault
                NSLog(@"New Saving Data Saving Failed");
            } else{
                NSLog(@"New Saving Data Saving Succeed");
            }
        }];
        [self stopSpinner];
    }];
//    [DocumentHelper closeDocument:SAVE usingBlock:nil];
//    [DocumentHelper closeDocument:SPEND usingBlock:nil];
    [super viewWillDisappear:animated];
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
