//
//  TableViewController.m
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "TableViewController.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"
#import "ENMLUtility.h"
#import "CustomTableViewCell.h"


@interface TableViewController ()

@property (nonatomic,assign) NSInteger currentNote;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;
//@property (nonatomic,strong) NSString* sharedId;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)createNoteAction:(UIButton *)sender;


@end

@implementation TableViewController
@synthesize noteList;
//@synthesize sharedId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(viewRect.size.width/2, viewRect.size.height/2, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.activityIndicator];
	// Do any additional setup after loading the view, typically from a nib.
    UINib *nib = [UINib nibWithNibName:TableViewCustomCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self startEvernoteSession];
    [self getNote];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)appendText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, text];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //選択状態を解除
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
}

- (void)startEvernoteSession {
    EvernoteSession *session = [EvernoteSession sharedSession];
    [self appendText:[NSString stringWithFormat:@"start Evernote Authorication"]];
    [self appendText:[NSString stringWithFormat:@"Session host: %@", [session host]]];
    [self appendText:[NSString stringWithFormat:@"Session key: %@", [session consumerKey]]];
    [self appendText:[NSString stringWithFormat:@"Session secret: %@", [session consumerSecret]]];
    
    /*[session authenticateWithViewController:self completionHandler:^(NSError *error) {
     if (!error && session.isAuthenticated) {
     EvernoteUserStore *userStore = [EvernoteUserStore userStore];
     [userStore getUserWithSuccess:^(EDAMUser *user) {
     NSLog(@"success evernote session");
     } failure:^(NSError *error) {} ];
     }
     }];*/
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated){
            if (error) {
                [self appendText:[NSString stringWithFormat:@"Error authenticating with Evernote Cloud API: %@", error]];
            }
            if (!session.isAuthenticated) {
                [self appendText:[NSString stringWithFormat:@"Session not authenticated"]];
            }
        } else {
            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
            [userStore getUserWithSuccess:^(EDAMUser *user) {
                sharedId = user.shardId;
                NSLog(@"Shard id : %@",sharedId);
                [self appendText:[NSString stringWithFormat:@"-- Authenticated as %@", [user username]]];
            } failure:^(NSError *error) {
                [self appendText:[NSString stringWithFormat:@"-- Error getting user: %@", error]];
            } ];
        
        }
    }];
}

- (void)getNote {
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSString* aToken = [session authenticationToken];
    EDAMNoteStoreClient* ensClient = [session noteStore];
    EDAMNotebook* defaultNotebook = [ensClient getDefaultNotebook:aToken];
    NSLog(@"Default Notebook is %@", [defaultNotebook name]);
    
    
    
    //EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    //EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    /*EDAMNoteFilter* noteFilter = [[EDAMNoteFilter alloc] initWithOrder:0
     ascending:NO
     words:nil
     notebookGuid:nil
     tagGuids:nil
     timeZone:nil
     inactive:NO
     emphasized:nil];*/
    EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:NO words:nil notebookGuid:nil tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
    EDAMNotesMetadataResultSpec *resultSpec = [[EDAMNotesMetadataResultSpec alloc] initWithIncludeTitle:YES includeContentLength:YES includeCreated:NO includeUpdated:NO includeDeleted:NO includeUpdateSequenceNum:NO includeNotebookGuid:NO includeTagGuids:NO includeAttributes:NO includeLargestResourceMime:NO includeLargestResourceSize:NO];
    [[EvernoteNoteStore noteStore] findNotesMetadataWithFilter:filter offset:self.currentNote maxNotes:10 resultSpec:resultSpec success:^(EDAMNotesMetadataList *metadata) {
        if(metadata.notes.count > 0) {
            self.noteList = metadata.notes;
            [self.tableView reloadData];
            //[self loadNote];
        }
        else {
            [self.webView loadHTMLString:@"No note found" baseURL:nil];
            [[self activityIndicator] stopAnimating];
        }
    } failure:^(NSError *error) {
        NSLog(@"Failed to find notes : %@",error);
        [[self activityIndicator] stopAnimating];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)getUserShardId {
 //Get the User from userStore and return the user's shard ID
 [[EvernoteUserStore userStore] getUserWithSuccess:^(EDAMUser *user) {
 NSString* shardId = user.shardId;
 NSLog(@"Shard id : %@",shardId);
 } failure:^(NSError *error) {
 NSLog(@"Error : %@",error);
 }];
 }



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [noteList count];
    //return 10;	// 0 -> 10 に変更
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }*/
    
    
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    EDAMNoteMetadata* note = [noteList objectAtIndex:[indexPath row]];
    NSLog(@"Shard id : %@",sharedId);
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSString* aToken = [session authenticationToken];
    NSString *str = [NSString stringWithFormat:@"%@thm/note/%@.png?size=75", session.webApiUrlPrefix,note.guid];
    NSLog(@"str id : %@",str);
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSString *body = [NSString stringWithFormat:@"auth=%@", aToken];
    [request setURL:[NSURL URLWithString:str]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
                
    UIImage* imaga = [UIImage imageWithData:data];
                
                
    NSLog(@"image width:%f",imaga.size.width);
               
    
                
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirPath = [array objectAtIndex:0];
    NSString *filePath = [cacheDirPath stringByAppendingPathComponent:@"sample.png"];
                
    if ([data writeToFile:filePath atomically:YES]) {
        NSLog(@"OK");
    } else {
        NSLog(@"Error");
    }
    
    
    cell.LabelCell.text = [note title];
    cell.imageThumb.image = imaga;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 先ほど "selectRow" と名付けたSegueを実行します
    //EDAMNote *note = [noteList objectAtIndex:[indexPath row]];
    //EDAMNoteMetadata *note = [noteList objectAtIndex:[indexPath row]];
    //webViewController.guid = [note guid];
    //if(webViewController.guid == nil){
        [self performSegueWithIdentifier:@"selectRow" sender:self];
    //}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // identifier が toViewController であることの確認
    if ([[segue identifier] isEqualToString:@"selectRow"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WebViewController *vc = /*(WebViewController*)*/[segue destinationViewController];
        EDAMNoteMetadata* note = [noteList objectAtIndex:[indexPath row]];
        vc.noteguid = note.guid;
        
        //vc.cityName = [noteList objectAtIndex:indexPath.row];
        // 移行先の ViewController に画像名を渡す
       // vc.guid = WebViewController.guid;
    }
}

@end
