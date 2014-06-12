//
//  MasterViewController.m
//  FSquareListGCD
//
//  Created by PRAVEEN ARAVAMUDHAN on 6/12/14.
//  Copyright (c) 2014 PRAVEEN ARAVAMUDHAN. All rights reserved.
//

#import "MasterViewController.h"
#import "Venue.h"

#define kCLIENTID @"O4N5CCDG0PD521SVU5OLX3BRIIFKHW2MOZ25XQUFHEELNPBD"
#define kCLIENTSECRET @"QP0ITQH0NVLJHUN4JICLO10OPQS2EFNFZOPOFDTO22M5LE1S"

@interface MasterViewController () {
    NSMutableArray *venues;
}

@property NSMutableArray *objects;

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)fetchedDataFourSquare:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    

    //NSLog(@"The json returned is: %@", json);
    
    NSArray *allvenues = [[(NSDictionary *)json objectForKey:@"response"] objectForKey:@"venues"];
    
    //NSLog(@"The venues are: %@", allvenues);
    
    [self plotPositionsVenues:allvenues];
}

- (void)plotPositionsVenues:(NSArray *)data
{
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        NSDictionary* eachVenue = [data objectAtIndex:i];
        Venue *aVenue = [[Venue alloc]init];
        aVenue.name = [eachVenue objectForKey:@"name"];;
        [venues addObject:aVenue];
    }
    
    [self.tableView reloadData];
}

- (void) loadFourSquareData {
    NSString *latLon = @"37.33,-122.03";
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?categoryId=4bf58dd8d48988d1e0931735&client_id=%@&client_secret=%@&ll=%@&v=20140118", kCLIENTID, kCLIENTSECRET, latLon];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: url];
        //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"the string is: %@", string);
        [self performSelectorOnMainThread:@selector(fetchedDataFourSquare:) withObject:data waitUntilDone:YES];
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    venues = [[NSMutableArray alloc]initWithCapacity:25];
    
    [self loadFourSquareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Venue *aVenue = venues[indexPath.row];
    cell.textLabel.text = [aVenue name];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
