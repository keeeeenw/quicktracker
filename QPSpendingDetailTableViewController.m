//
//  QPSpendingDetailTableViewController.m
//  QuickPlaner
//
//  Created by Zixiao on 1/25/13.
//  Copyright (c) 2013 Zixiao Wang. All rights reserved.
//

#import "QPSpendingDetailTableViewController.h"

@interface QPSpendingDetailTableViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextView *noteText;
@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation QPSpendingDetailTableViewController

#pragma mark - Sync Models and Views

- (UIDatePicker *) datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    return _datePicker;
}

#pragma mark - View Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.amountText.delegate = self;
    self.dateText.delegate = self;
    self.noteText.delegate = self;
    
    //Make the keyboard disappear when the user touches outside of the textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setUpTextFields];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

-(void)setUpTextFields{
    //Adding CurrencyLabel to amountText.text
    UILabel *currencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    currencyLabel.text = [[[NSNumberFormatter alloc]init]currencySymbol];
    currencyLabel.font = self.amountText.font;
    [currencyLabel sizeToFit];
    self.amountText.leftView = currencyLabel;
    self.amountText.leftViewMode = UITextFieldViewModeAlways;
    
    //self.amountText.text = [self.spend.amount stringValue];
    self.amountText.text = [NSString stringWithFormat:@"%.2f", [self.spend.amount doubleValue]];
    self.dateText.text = [self processDate:self.spend.date];
    self.noteText.text = self.spend.name;
    
    self.dateText.inputView = self.datePicker;
    self.datePicker.date = self.spend.date;
    
}

- (NSString *)processDate:(NSDate *) date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:self.amountText]) {
        if ([self.amountText.text doubleValue] != [self.spend.amount doubleValue]) {
            self.spend.amount = [NSNumber numberWithDouble:[self.amountText.text doubleValue]];
        }
    } else if ([textField isEqual:self.dateText]) {
        if (![self.datePicker.date isEqualToDate:self.spend.date]) {
            self.spend.date = self.datePicker.date;
            self.dateText.text = [self processDate:self.datePicker.date];
            
            //Sections in TableViewController are organized by day, month and year. secion_id = (year * 10000) + (month * 100) + day
            NSCalendar *calendar = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.datePicker.date];
            NSString *tmp = [NSString stringWithFormat:@"%d", ([components year] * 10000) + ([components month]*100) + [components day]];
            
            self.spend.section_id = tmp;
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField.text length] > 0) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (![self.spend.name isEqualToString:textView.text]) {
        self.spend.name = textView.text;
    }
    
}


#pragma mark - Target Action
- (IBAction)deletePressed:(UIButton *)sender {
    [self.spend.managedObjectContext deleteObject:self.spend];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissKeyboard {
    [self.dateText resignFirstResponder];
    [self.amountText resignFirstResponder];
    [self.noteText resignFirstResponder];
}

-(void)donePressed{
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
