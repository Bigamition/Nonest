//
//  WebViewController.m
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "WebViewController.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"
#import "ENMLUtility.h"

@interface WebViewController ()

@property (nonatomic,assign) NSInteger currentNote;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation WebViewController
@synthesize noteguid;

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
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(viewRect.size.width/2, viewRect.size.height/2, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.activityIndicator];
    //[self getNote];
    [self loadCurrentNote];
}

- (void)appendText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)startEvernoteSession {
    EvernoteSession *session = [EvernoteSession sharedSession];
    [self appendText:[NSString stringWithFormat:@"start Evernote Authorication"]];
    [self appendText:[NSString stringWithFormat:@"Session host: %@", [session host]]];
    [self appendText:[NSString stringWithFormat:@"Session key: %@", [session consumerKey]]];
    [self appendText:[NSString stringWithFormat:@"Session secret: %@", [session consumerSecret]]];
    
    
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
                [self appendText:[NSString stringWithFormat:@"-- Authenticated as %@", [user username]]];
            } failure:^(NSError *error) {
                [self appendText:[NSString stringWithFormat:@"-- Error getting user: %@", error]];
            } ];
        }
    }];
}*/

/*- (void)getNote {
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSString* aToken = [session authenticationToken];
    EDAMNoteStoreClient* ensClient = [session noteStore];
    EDAMNotebook* defaultNotebook = [ensClient getDefaultNotebook:aToken];
    NSLog(@"Default Notebook is %@", [defaultNotebook name]);
    
    
    
 
    EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:NO words:nil notebookGuid:nil tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
    EDAMNotesMetadataResultSpec *resultSpec = [[EDAMNotesMetadataResultSpec alloc] initWithIncludeTitle:NO includeContentLength:NO includeCreated:NO includeUpdated:NO includeDeleted:NO includeUpdateSequenceNum:NO includeNotebookGuid:NO includeTagGuids:NO includeAttributes:NO includeLargestResourceMime:NO includeLargestResourceSize:NO];
    [[EvernoteNoteStore noteStore] findNotesMetadataWithFilter:filter offset:self.currentNote maxNotes:10 resultSpec:resultSpec success:^(EDAMNotesMetadataList *metadata) {
        if(metadata.notes.count > 0) {
            self.noteList = metadata.notes;
            [self loadCurrentNote];
        }
        else {
            [self.webView loadHTMLString:@"No note found" baseURL:nil];
            [[self activityIndicator] stopAnimating];
        }
    } failure:^(NSError *error) {
        NSLog(@"Failed to find notes : %@",error);
        [[self activityIndicator] stopAnimating];
    }];
    
}*/



- (void) loadCurrentNote {
    [[self activityIndicator] startAnimating];
    //if([self.noteList count] > self.currentNote%10) {
       // EDAMNoteMetadata* foundNote = self.noteList[self.currentNote%10];
    if(noteguid != nil){
        [[EvernoteNoteStore noteStore] getNoteWithGuid:noteguid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            ENMLUtility *utltility = [[ENMLUtility alloc] init];
            [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                if(error == nil) {
                    [self.webView loadHTMLString:html baseURL:nil];
                    [[self activityIndicator] stopAnimating];
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"Failed to get note : %@",error);
            [[self activityIndicator] stopAnimating];
        }];
    }
    //}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
