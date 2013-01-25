//
//  QPSavingTableViewController.m
//  QucikTracker
//
//  Created by Zixiao on 12/30/12.
//  Copyright (c) 2012 Zixiao Wang. All rights reserved.
//

#import "QPSavingTableViewController.h"
#import "QPViewController.h"
#import "DocumentHelper.h"
#import "Saving+Budget.h"
#import "QPSavingDetailTableViewController.h"

@interface QPSavingTableViewController ()

@property (nonatomic, strong) UIManagedDocument *savingDocument;

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
    
    cell.detailTextLabel.text = save.describe;
    
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
	
	NSString *titleString = [NSString stringWithFormat:@"%@ %d %d", [monthSymbols objectAtIndex:month-1], day, year];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"]){
       	titleString = [NSString stringWithFormat:@"%d年%@%d日", year,[monthSymbols objectAtIndex:month-1], day];
    }
	
	
	return titleString;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return nil; //this hide the section index
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.savingDocument.documentState == UIDocumentStateEditingDisabled) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(self.savingDocument.documentState == UIDocumentStateEditingDisabled)) {
        double userDefaultSpending = [[[NSUserDefaults standardUserDefaults] objectForKey:SAVE] doubleValue];
        Saving *save = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[NSUserDefaults standardUserDefaults] setDouble:userDefaultSpending-[save.amount doubleValue] forKey:SAVE];
        [self.fetchedResultsController.managedObjectContext deleteObject:save];
    }
}

#pragma mark - Sigue Operation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //The second part of the "or" operation is used by segue for FlickrRecentPhotoViewController
    if ([segue.identifier isEqualToString:@"Saving Detail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setSave:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

@end
