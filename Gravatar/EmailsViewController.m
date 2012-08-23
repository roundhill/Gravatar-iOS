//
//  EmailsViewController.m
//  Gravatar
//
//  Created by Beau Collins on 8/7/12.
//  Copyright (c) 2012 Beau Collins. All rights reserved.
//

#import "EmailsViewController.h"

@interface EmailsViewController ()

@end

@implementation EmailsViewController

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self reloadAccount];

}

- (void)reloadAccount {
    [self.account.client addressesOnSuccess:^(GravatarRequest *request, NSArray *params) {
        NSDictionary *emailData = (NSDictionary *)[params objectAtIndex:0];
        NSMutableArray *emails = [NSMutableArray arrayWithCapacity:[[emailData allKeys] count]];
        [emailData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [emails addObject:@{
             @"email": key,
             @"details": obj
             }];
        }];
        self.emails = emails;
        [self.tableView reloadData];
    } onFailure:^(GravatarRequest *request, NSDictionary *fault) {
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.emails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *details = [self.emails objectAtIndex:indexPath.row];
    cell.textLabel.text = [details objectForKey:@"email"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.delegate emailViewController:self didSelectEmail:@"hi"];
    
    
}

@end
