//
//  QPHistoryTableViewController.m
//  QucikTracker
//
//  Created by Zixiao on 12/26/12.
//  Copyright (c) 2012 Zixiao Wang. All rights reserved.
//

#import "QPHistoryTableViewController.h"
#import "Saving+Budget.h"
#import "Spending+Budget.h"
#import "DocumentHelper.h"
#import "QPViewController.h"

@interface QPHistoryTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *totalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *savingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spendingCell;
@end

@implementation QPHistoryTableViewController

#pragma mark - Helper Methods

- (void)startSpinner:(NSString *)activity
{
    self.navigationItem.title = activity;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:spinner];
}

- (void)stopSpinner
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = self.title;
}

#pragma mark - Controller Logics

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupCells];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Cell Customization

- (void)setupCells{
    [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){
        double totalSaving = [[Saving totalSavingInManagedObjectContext:document.managedObjectContext] doubleValue];
        NSLog(@"Total Saving %f",totalSaving);
        self.savingCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",totalSaving];
        
        [self startSpinner:@"Loading..."];
        
        [DocumentHelper openDocument:SPEND usingBlock:^(UIManagedDocument *document){
            double totalSpending = [[Spending totalSpendingInManagedObjectContext:document.managedObjectContext] doubleValue];
            self.spendingCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",totalSpending];
            double currentValue = totalSaving - totalSpending;
            NSLog(@"Total Spending %f",totalSpending);
            
            self.totalCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",currentValue];
            NSLog(@"Current Value %f", currentValue);
            
            [self stopSpinner];
            
        }];
        
    }];
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
