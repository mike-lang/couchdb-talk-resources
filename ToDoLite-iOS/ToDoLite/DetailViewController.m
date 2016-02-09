//
//  DetailViewController.m
//  ToDoLite
//
//  Created by Pasin Suriyentrakorn on 10/11/14.
//  Copyright (c) 2014 Pasin Suriyentrakorn. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Task.h"
#import "ImageViewController.h"

#define ImageDataContentType @"image/jpg"

@interface DetailViewController () {
    Task *taskToAddImageTo;
    UIImage *imageForNewTask;
    UIImage *imageToDisplay;
    UIView *imageActionSheetSenderView;
    UIPopoverController *imagePickerPopover;
}

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setList:(List *)list {
    if (_list != list) {
        _list = list;
        [self configureView];
    }
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        self.navigationItem.leftBarButtonItem = app.displayModeButtonItem;
    }
    [[app popoverController] dismissPopoverAnimated:YES];
}

- (void)configureView {    

    self.title = self.list.title;
    self.addItemTextField.enabled = YES;


    _dataSource.labelProperty = @"title";
    _dataSource.query = [[self.list queryTasks] asLiveQuery];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    List *list = [List modelForNewDocumentInDatabase:app.database];
    list.title = @"My List";
    self.list = list;
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showImage"]) {
        ImageViewController *controller = (ImageViewController *)[segue destinationViewController];
        controller.image = imageToDisplay;
        imageToDisplay = nil;
    }
}

#pragma mark - Text Field

// Called when the text field's Return key is tapped.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *title = _addItemTextField.text;
    if (title.length == 0) {
        return NO;  // Nothing entered
    }
    [_addItemTextField setText:nil];

    Task *task = [self.list addTaskWithTitle:title withImage:nil withImageContentType:ImageDataContentType];
    NSError *error;
    if (![task save:&error]) {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        [app showMessage:@"Couldn't save new task" withTitle:@"Error"];
    }

    [textField resignFirstResponder];

    return YES;
}

#pragma mark - UIImagePicker


- (NSData *)dataForImage:(UIImage *)image {
    return UIImageJPEGRepresentation(image, 0.5);
}


#pragma mark - TaskTableViewCellDelegate

- (UITableViewCell *)couchTableSource:(CBLUITableSource *)source cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Task";
    TaskTableViewCell *cell = (TaskTableViewCell *)[source.tableView
                                                    dequeueReusableCellWithIdentifier:CellIdentifier
                                                    forIndexPath:indexPath];
    CBLQueryRow *row = [source rowAtIndex:indexPath.row];
    Task *task = [Task modelForDocument:row.document];
    cell.task = task;
    cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBLQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
    Task *task = [Task modelForDocument:row.document];
    task.checked = !task.checked;

    NSError *error;
    if (![task save:&error]) {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        [app showMessage:@"Failed to update the task" withTitle:@"Error"];
    }
}


- (IBAction)syncButtonAction:(id)sender {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    [app startReplication];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.addItemTextField resignFirstResponder];
}

@end
