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
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:document.managedObjectContext sectionNameKeyPath:@"section_id" cacheName:nil];
    }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Saving *save = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = [[[[NSNumberFormatter alloc]init]currencySymbol] stringByAppendingFormat:@"%.2f", [save.amount doubleValue]];
    
    if (save.describe) {
        cell.detailTextLabel.text = save.describe;
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:save.date];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d", [components hour],[components minute]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	//We unpack section_id, which is defined by secion_id = (year * 10000) + (month * 100) + day
    
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    static NSArray *monthSymbols = nil;
    
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        monthSymbols = [formatter shortMonthSymbols];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    
	NSInteger year = numericSection / 10000;
    NSInteger month = (numericSection - (year*10000)) / 100;
	NSInteger day = numericSection - (year * 10000 + month*100);
	
	NSString *titleString = [NSString stringWithFormat:@"%@, %d %d", [monthSymbols objectAtIndex:month-1], day, year];
	
	return titleString;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return nil; //this hide the section index
}


@end
