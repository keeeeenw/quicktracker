//
//  QPSavingTableViewController.m
//  QuickPlaner
//
//  Created by Zixiao on 12/30/12.
//  Copyright (c) 2012 Zixiao Wang. All rights reserved.
//

#import "QPSavingTableViewController.h"
#import "QPViewController.h"
#import "DocumentHelper.h"
#import "Saving+Budget.h"

@interface QPSavingTableViewController ()

@end

@implementation QPSavingTableViewController

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
    [self setupFetchResultsController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CoreDataTableViewController
- (void) setupFetchResultsController{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:SAVE];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [DocumentHelper openDocument:SAVE usingBlock:^(UIManagedDocument *document){
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Saving *save = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = [save.amount stringValue];
    cell.detailTextLabel.text = [save.date description];
    
    return cell;
}

@end
