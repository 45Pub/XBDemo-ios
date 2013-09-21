//
//  MessageViewController.m
//  ClientTest
//
//  Created by pengjay on 13-7-11.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "MessageViewController.h"
#import <IMContext.h>
#import <IMUser.h>
#import <IMMsgAll.h>
#import <IMBaseClient.h>
#import <IMPathHelper.h>
#import "AppDelegate.h"
#import <XMPPXBRoster.h>
#import <IMXbcxClient.h>

@interface MessageViewController ()
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@end

@implementation MessageViewController

- (id)initWithUser:(IMUser *)user
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		
		_fromUser = user;
		
		_msgQueue = [[IMContext sharedContext].msgQueueMgr openNormalMsgQueueWithUser:_fromUser delegate:self];
        // Custom initialization
	
    }
    return self;
}

- (void)dealloc
{
	NSLog(@"close queue");
	[[IMContext sharedContext].msgQueueMgr closeNormalMsgQueueWithUser:_fromUser];
	[super dealloc];
}

- (void)testCreatGroup
{
	XMPPXBRoster *rost = ((IMXbcxClient *)del.client).xbRoster;
	NSDictionary *dic1 = @{@"jid": @"917e4a93eb69cd71dc5a7081f5732f441c0a2867@qiumihui.cn", @"name":@"testt"};
	NSDictionary *dic2 = @{@"jid": @"900e1107850a50f11330d73dfbfd7f09482e9ffc@qiumihui.cn", @"name":@"testt22"};
	NSArray *array = @[dic1, dic2];
	
	[rost createDiscussGroup:@"ppppttttt" withMembers:array];
	
}

- (void)doPic
{
	[self testCreatGroup];
	return;
	if(self.imgPicker == nil)
	{
		self.imgPicker = [[UIImagePickerController alloc]init] ;
		self.imgPicker.delegate = self;
	}
	
	self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	self.imgPicker.allowsEditing = NO;
	[self presentModalViewController:self.imgPicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
	
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	
	IMPicMsg *msg = [[IMPicMsg alloc]init];
	msg.fromType = IMMsgFromLocalSelf;
	msg.msgID = [IMMsg generateMessageID];
	msg.fromUser = self.fromUser;
	msg.msgUser = [IMContext sharedContext].loginUser;
	msg.procState = IMMsgProcStateUnproc;
	NSString *thbpath = [IMPathHelper thumbnailPathWithUserID:self.fromUser.userID fileName:msg.msgID];
	NSString *picPath = [IMPathHelper picPathWithUserID:self.fromUser.userID fileName:msg.msgID isSend:YES];
	NSData *data = UIImageJPEGRepresentation(image, 0.75f);
	[data writeToFile:thbpath atomically:YES];
	[data writeToFile:picPath atomically:YES];
	
	msg.msgSize = data.length;
	[del.client sendMsg:msg];
	
	//    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
	//    [image drawInRect:CGRectMake(0, 0, 100, 100)];
	//    UIImage *thimg = UIGraphicsGetImageFromCurrentImageContext();
	//    UIGraphicsEndImageContext();
	
//	NSString *workPath = [[UserSessionManager sharedSessionManager] userWorkBasePath];
//	NSString *filePath = [workPath stringByAppendingPathComponent:[_imUser createRelateRandPicPath]];
//	NSString *smallPath = [workPath stringByAppendingPathComponent:[_imUser createRelateRandPicPath]];
//	[Public createFileDoc:filePath];
//	NSData *data = UIImageJPEGRepresentation(image, 0.75f);
//	[data writeToFile:filePath atomically:YES];
//	PPLOG(@"filePath:%@", filePath);
//	IMPicMsg *msg = [[IMPicMsg alloc]init];
//	msg.fromUser = self.imUser;
//	msg.msgID = [Public generateMessageID];
//	msg.msgUser = self.myUser;
//	msg.originPicLoaclPath = filePath;
//	msg.localPath = smallPath;
//	msg.thumbImage = [image scaleToFitSize:CGSizeMake(kMsgPicCellMaxWidth, kMsgPicCellMaxHeight)]; // should be thimg //for test
//	
//	data = UIImageJPEGRepresentation(msg.thumbImage, 0.75f);
//	[data writeToFile:smallPath atomically:YES];
//	
//	msg.fromSelf = YES;
//	msg.msgSize = [data length];
//	
//	[[IMMsgCenter sharedIMMsgCenter] sendMsg:msg];
//	[msg release];
	
	
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"sendPic" style:UIBarButtonItemStyleBordered target:self action:@selector(doPic)];
	NSLog(@"%@", [IMContext sharedContext].loginUser);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	_msgArray = [_msgQueue msgArray];
	[self.tableView reloadData];
	self.tableView.contentOffset= CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
	

}

- (void)immsgQueue:(IMMsgQueue *)msgQueue didChanged:(NSArray *)msgArray
{
	_msgArray = [msgQueue msgArray];
	[self.tableView reloadData];
	self.tableView.contentOffset= CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
	
}

- (void)immsgQueue:(IMMsgQueue *)msgQueue didLoadHistory:(NSArray *)hisstroyArray
{
	_msgArray = [msgQueue msgArray];
	[self.tableView reloadData];
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
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	id obj = [_msgArray objectAtIndex:indexPath.row];
    // Configure the cell...
	NSString *str = nil;
	if ([obj isKindOfClass:[IMMsg class]]) {
		str = ((IMMsg *)obj).msgBody;
	}else {
		str = ((NSDate *)obj).description;
	}
	
    cell.textLabel.text = str;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
	id obj = [_msgArray objectAtIndex:indexPath.row];
    // Configure the cell...
	if ([obj isKindOfClass:[IMAudioMsg class]]) {
		[_msgQueue selectMsg:(IMMsg *)obj];
	}
}

@end
