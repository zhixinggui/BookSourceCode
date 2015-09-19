//
//  BIDTaskListController.m
//  Simple Storyboard
//

#import "BIDTaskListController.h"

@interface BIDTaskListController ()
@property (strong, nonatomic) NSMutableArray *tasks;
@property (copy, nonatomic) NSDictionary *editedSelection;
@end

@implementation BIDTaskListController

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
    
    self.tasks = [@[@"Walk the dog",
    @"URGENT: Buy milk",
    @"Clean hidden lair",
    @"Invent miniature dolphins",
    @"Find new henchmen",
    @"Get revenge on do-gooder heroes",
    @"URGENT: Fold laundry",
    @"Hold entire world hostage",
    @"Manicure"] mutableCopy];
}

- (void)setEditedSelection:(NSDictionary *)dict {
    if (![dict isEqual:self.editedSelection]) {
        _editedSelection = dict;
        NSIndexPath *indexPath = dict[@"indexPath"];
        id newValue = dict[@"object"];
        [self.tasks replaceObjectAtIndex:indexPath.row withObject:newValue];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    NSString *task = [self.tasks objectAtIndex:indexPath.row];
    NSRange urgentRange = [task rangeOfString:@"URGENT"];
    if (urgentRange.location == NSNotFound) {
        identifier = @"plainCell";
    } else {
        identifier = @"attentionCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Configure the cell...
    
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:1];
    NSMutableAttributedString *richTask = [[NSMutableAttributedString alloc]
                                           initWithString:task];
    NSDictionary *urgentAttributes =
    @{NSFontAttributeName : [UIFont fontWithName:@"Courier" size:24],
    NSStrokeWidthAttributeName : @3.0};
    [richTask setAttributes:urgentAttributes
                      range:urgentRange];
    cellLabel.attributedText = richTask;
    
    return cell;
}


//跳转时,将设置DetailView中的代理和数据(数据即文本)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    if ([destination respondsToSelector:@selector(setDelegate:)]) {
        [destination setValue:self forKey:@"delegate"];
    }
    if ([destination respondsToSelector:@selector(setSelection:)]) {
        // prepare selection info
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id object = self.tasks[indexPath.row];
        NSDictionary *selection = @{@"indexPath" : indexPath,
        @"object" : object};
        [destination setValue:selection forKey:@"selection"];
    }
}
@end
