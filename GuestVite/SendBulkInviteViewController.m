//
//  SendBulkInviteViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-13.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SendBulkInviteViewController.h"
#import "HomePageViewController.h"
#import "SendAddressBookInviteViewController.h"
#import "SendNewInviteViewController.h"
#import <MessageUI/MessageUI.h>
#import "SACalendar.h"
#import "MapKit/MapKit.h"

@import Firebase;

@interface SendBulkInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate,SACalendarDelegate>

@property (weak, nonatomic) IBOutlet UITextView *eMailguestList;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITextField *inviteForDateText;
@property (weak, nonatomic) IBOutlet UITextField *inviteExpireDateText;
@property (weak, nonatomic) IBOutlet UITextView *inviteMessage;

@property (weak, nonatomic) IBOutlet UITextView *smsGuestList;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerExpire;


@property (weak, nonatomic) IBOutlet UINavigationBar *sendBulkInviteBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;

@property (nonatomic, strong) UITextField *currentTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSString *string;

@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;

@end

@implementation SendBulkInviteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    // Set the current date and time as date
    
    
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
    [currentDateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [currentDateFormatter stringFromDate:[NSDate date]];
    
    self.startTime = currentTime;
    NSLog(@"Start Time on load %@", self.startTime);
    
    self.endTime = currentTime;
    
    NSLog(@"End Time on load %@", self.endTime);
    
    
    
    self.sendBulkInviteBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.sendBulkInviteBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.sendBulkInviteBack.translucent = YES;
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"navbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    
    
    
    self.backLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:10.0];
    self.backLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_sendBulkInviteBack];
    
    
   
    self.ref = [[FIRDatabase database] reference];
    
    self.eMailguestList.text = @"Enter Email Addressses here";
    self.eMailguestList.textColor = [UIColor lightGrayColor];
    self.eMailguestList.layer.cornerRadius = 10.0;
    self.eMailguestList.layer.borderWidth = 1.0;
    self.eMailguestList.delegate = self;
    
    self.smsGuestList.text = @"Enter Phone Numbers here";
    self.smsGuestList.textColor = [UIColor lightGrayColor];
    self.smsGuestList.layer.cornerRadius = 10.0;
    self.smsGuestList.layer.borderWidth = 1.0;
    self.smsGuestList.delegate = self;
    
    self.inviteForDateText.layer.cornerRadius = 10.0;
    self.inviteForDateText.layer.borderWidth = 1.0;
    
    self.inviteExpireDateText.layer.cornerRadius = 10.0;
    self.inviteExpireDateText.layer.borderWidth = 1.0;
    
    self.inviteMessage.text = @"Personalized Message";
    self.inviteMessage.textColor = [UIColor lightGrayColor];
    self.inviteMessage.layer.cornerRadius = 10.0;
    self.inviteMessage.layer.borderWidth = 1.0;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    
    self.eMailguestList.inputAccessoryView = keyboardDoneButtonView;
    self.smsGuestList.inputAccessoryView = keyboardDoneButtonView;
    //self.inviteForDateText.inputAccessoryView = keyboardDoneButtonView;
    //self.inviteExpireDateText.inputAccessoryView = keyboardDoneButtonView;
    self.inviteMessage.inputAccessoryView = keyboardDoneButtonView;
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];

    self.datePicker.frame = CGRectMake(40, 70, 300, 50); // set frame as your need
    
    [self.datePicker setValue:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]forKey:@"textColor"];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.view addSubview: self.datePicker];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.datePickerExpire.frame = CGRectMake(40, 70, 300, 50); // set frame as your need
    [self.datePickerExpire setValue:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]forKey:@"textColor"];
    
    
    self.datePickerExpire.datePickerMode = UIDatePickerModeTime;
    [self.view addSubview: self.datePickerExpire];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    [self.datePickerExpire  addTarget:self action:@selector(dateChangedExpire:) forControlEvents:UIControlEventValueChanged];
}


- (IBAction)Back
{
    HomePageViewController *homePageVC =
    [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
    
    
    [self.navigationController pushViewController:homePageVC animated:YES];
    
    [self presentViewController:homePageVC animated:YES completion:nil];
}



- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    NSLog(@"Time For %@", currentTime);
    self.startTime = currentTime;
}

- (void)dateChangedExpire:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePickerExpire.date];
    NSLog(@"Time Expire%@", currentTime);
    self.endTime = currentTime;
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    // NSLog(@"RESULU is %@",result);
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}



- (IBAction)segmentTapped:(id)sender {
    
    if(self.segmentControl.selectedSegmentIndex ==0){
        
        
        SendNewInviteViewController *sendNewVC =
        [[SendNewInviteViewController alloc] initWithNibName:@"SendNewInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendNewVC animated:YES];
        
        [self presentViewController:sendNewVC animated:YES completion:nil];
    }
    
    if(self.segmentControl.selectedSegmentIndex ==2){
        
        
        SendAddressBookInviteViewController *sendAddrVC =
        [[SendAddressBookInviteViewController alloc] initWithNibName:@"SendAddressBookInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendAddrVC animated:YES];
        
        [self presentViewController:sendAddrVC animated:YES completion:nil];
    }

    
}


- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if(self.eMailguestList.isFirstResponder)
    {
        if([self.eMailguestList.text isEqualToString:@"Enter Email Addressses here"]) {
    self.eMailguestList.text = @"";
    self.eMailguestList.textColor = [UIColor blackColor];
        }
        
        }
    
    if(self.smsGuestList.isFirstResponder)
    {
        if([self.smsGuestList.text isEqualToString:@"Enter Phone Numbers here"]) {
        self.smsGuestList.text = @"";
        self.smsGuestList.textColor = [UIColor blackColor];
    }
    }
    
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    
    
    if(!self.eMailguestList.isFirstResponder)
        {
                if(self.eMailguestList.text.length == 0){
                    self.eMailguestList.textColor = [UIColor lightGrayColor];
                    self.eMailguestList.text = @"Enter Email Addressses here";
                    [self.eMailguestList resignFirstResponder];
                }
    }
    
    
    if(!self.smsGuestList.isFirstResponder)
    {
        if(self.smsGuestList.text.length == 0){
            self.smsGuestList.textColor = [UIColor lightGrayColor];
            self.smsGuestList.text = @"Enter Phone Numbers here";
            [self.smsGuestList resignFirstResponder];
        }
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneClicked:(id)sender
{
    //NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}


- (IBAction)forDateBeginEdit:(id)sender {
    
    self.inviteExpireDateText.enabled = FALSE;
    
    SACalendar *calendar = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
    
    calendar.delegate = self;
    [self.view addSubview:calendar];
    
    [self.view endEditing:YES];
}

- (IBAction)forDateBeginEditExpire:(id)sender {
    
    self.inviteForDateText.enabled = FALSE;
    
    SACalendar *calendar1 = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
    
    calendar1.delegate = self;
    [self.view addSubview:calendar1];
    
    [self.view endEditing:YES];
}



- (void) setCurrentTextField:(UITextField *)currentTextField{
    self.currentTextField.text = self.string;
}

// Prints out the selected date
-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    
    [self.view endEditing:YES];
    self.string = [NSString stringWithFormat:@"%02d/%02d/%02d",month,day,year];
    
    NSLog(@"Date Selected is : %@",self.string);
    
    if(self.inviteForDateText.isEnabled){
        self.inviteForDateText.text = self.string;
        self.inviteExpireDateText.enabled = TRUE;
        NSLog(@"FOR DATE ");
    }
    
    else if(self.inviteExpireDateText.isEnabled){
        self.inviteExpireDateText.text = self.string;
        self.inviteForDateText.enabled = TRUE;
        NSLog(@"EXPIRE DATE ");
    }
    
    [calendar removeFromSuperview];
    
    
    
}

//Utility Function to convert String to date

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    return [dateFormatter dateFromString:dateStr];
}



- (IBAction)editEnded:(id)sender {
    [sender resignFirstResponder];
}

// Prints out the month and year displaying on the calendar
-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    [self.view endEditing:YES];
}

- (IBAction)sendSMSTapped:(id)sender {
    
    
    // Get the invite Row
    
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    __block NSMutableArray *smsList = [[NSMutableArray alloc] init];
    
    //__block NSMutableArray *emailList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *noneList = [[NSMutableArray alloc] init];
    
    
    __block NSString *startDateTime  = [[NSString alloc] init];
    
    __block NSString *endDateTime = [[NSString alloc] init];
    
    startDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteForDateText.text,self.startTime];
    
    endDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteExpireDateText.text,self.endTime];
    
    //startDateTime = [self.inviteForDateText.text self.startTime];
    
    //endDateTime = [self.inviteExpireDateText.text stringByAppendingString:self.endTime];
    
    
    
    NSDate *fromDate = [self dateToFormatedDate:startDateTime];
    
    NSDate *toDate = [self dateToFormatedDate:endDateTime];
    
    
    NSLog(@"FROM DATE %@",fromDate);
    
    NSLog(@"TO DATE %@",toDate);
    
    if([self.smsGuestList.text length] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else{
        
        if([fromDate compare:toDate] == NSOrderedAscending) // ONLY if from is earlier
        {
        
        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
             NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
            int i =0;
            for(NSString *address in arr)
            {
                
                              if([address length] == 10)
                              {
                                  
                                  NSString *hostaddr = [[NSString alloc]init];
                                  
                                  if([[dict valueForKey:@"Address2"] length] > 0)
                                  {
                                      hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"Address2"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                                  }
                                  
                                  else {
                                      hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                                  }
                                  
                                  CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];

                                  
                    NSDictionary *post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                           @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                           @"Sender EMail": [dict valueForKey:@"EMail"],
                                           @"Sender Address1": [dict valueForKey:@"Address1"],
                                           @"Sender Address2": [dict valueForKey:@"Address2"],
                                           @"Sender City": [dict valueForKey:@"City"],
                                           @"Sender Zip": [dict valueForKey:@"Zip"],
                                           @"Sender Phone": [dict valueForKey:@"Phone"],
                                           @"Mesage From Sender": self.inviteMessage.text,
                                           @"Receiver First Name": @"BULK",
                                           @"Receiver Last Name": @"BULK",
                                           @"Receiver EMail": @"BULK",
                                           @"Receiver Phone": address,
                                           @"Invite For Date": startDateTime,
                                           @"Invite Valid Till Date": endDateTime,
                                           @"Invitation Status": @"Pending",
                                           @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                           @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                           @"Guest Location Status" : @"NOT_STARTED",
                                           };//Dict post
                    
                    
                    
                    
                    
                    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                    NSRange range = [intervalString rangeOfString:@"."];
                    NSString *primarykey = [intervalString substringToIndex:range.location];
                    NSString *pkey1 = [userID stringByAppendingString:primarykey];
                    
                    NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                
                    NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:address]]];
                    
                    [rowValue setString:pKey];
                    [senderName setString:[dict valueForKey:@"First Name"]];
                    [senderName appendString:@" "];
                    [senderName appendString:[dict valueForKey:@"Last Name"]];
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                    [_ref updateChildValues:childUpdates];
                    [smsList addObject:address];
                    //NSLog(@"PKEY for PHONE NUMBER %@",pKey);
                } // If addr length = 10 ends
    
                else {
                    
                    [noneList addObject:address];
                    
                } // else ends
                
                
                i++;
                
                
            } // for loop ends
            
            
            
        }]; // DB Query ends
        
        while([rowValue length]== 0 && [senderName length] ==0 && ([smsList count] == 0 || [noneList count] == 0)) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if([smsList count] > 0){
            
            
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:nil];
                return;
            }
            
            
            
            
            
            //NSArray *recipents = [NSArray arrayWithObject:self.guestPhoneText.text];
            
            
            NSString *message = [NSString stringWithFormat:@"Hey!, You are invited by %@ as a guest on %@ at %@, Please login/Register to GuestVite App for more Details ,Thanks!",senderName,self.inviteForDateText.text,self.startTime];
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:smsList];
            [messageController setBody:message];
            
            
            [self presentViewController:messageController animated:YES completion:nil];
            
        }
        
    }
    
    else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }

    
         if([noneList count] > 0) {
         
         NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
         NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.smsGuestList.text];
             
             for(NSString *temp in arr){
                 for(NSString *tempNone in noneList){
                 
                        if([temp isEqualToString:tempNone]){
                     
                            
                            NSRange range=[self.smsGuestList.text rangeOfString:temp];
                            NSLog(@"None String Range is %@",NSStringFromRange(range));
                            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                        }
                 }
             }
             [self.smsGuestList setAttributedText:string];
         
         }
        

        
        
    } // Main else ends
    
}

- (IBAction)sendEMailTapped:(id)sender {
    
    // Get the invite Row
    
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    //__block NSMutableArray *smsList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *emailList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *noneList = [[NSMutableArray alloc] init];
    
    __block NSString *startDateTime  = [[NSString alloc] init];
    
    __block NSString *endDateTime = [[NSString alloc] init];
    
    startDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteForDateText.text,self.startTime];
    
    endDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteExpireDateText.text,self.endTime];
    
    //startDateTime = [self.inviteForDateText.text self.startTime];
    
    //endDateTime = [self.inviteExpireDateText.text stringByAppendingString:self.endTime];
    
    
    
    NSDate *fromDate = [self dateToFormatedDate:startDateTime];
    
    NSDate *toDate = [self dateToFormatedDate:endDateTime];
    
    if([self.eMailguestList.text length] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else{
        
        if([fromDate compare:toDate] == NSOrderedAscending) // ONLY if from is earlier
        {
            
        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
            NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
            int i =0;
            for(NSString *address in arr)
            {
                
                
                if([address containsString:@".com"])
                {
                    
                    NSString *hostaddr = [[NSString alloc]init];
                    
                    if([[dict valueForKey:@"Address2"] length] > 0)
                    {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"Address2"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    else {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];

                    
                    
                    NSDictionary *post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                           @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                           @"Sender EMail": [dict valueForKey:@"EMail"],
                                           @"Sender Address1": [dict valueForKey:@"Address1"],
                                           @"Sender Address2": [dict valueForKey:@"Address2"],
                                           @"Sender City": [dict valueForKey:@"City"],
                                           @"Sender Zip": [dict valueForKey:@"Zip"],
                                           @"Sender Phone": [dict valueForKey:@"Phone"],
                                           @"Mesage From Sender": self.inviteMessage.text,
                                           @"Receiver First Name": @"BULK",
                                           @"Receiver Last Name": @"BULK",
                                           @"Receiver EMail": address,
                                           @"Receiver Phone": @"BULK",
                                           @"Invite For Date": startDateTime,
                                           @"Invite Valid Till Date": endDateTime,
                                           @"Invitation Status": @"Pending",
                                           @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                           @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                           @"Guest Location Status" : @"NOT_STARTED",
                                           };
                    
                    
                    
                    
                    
                    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                    NSRange range = [intervalString rangeOfString:@"."];
                    NSString *primarykey = [intervalString substringToIndex:range.location];
                    
                    NSString *pkey1 = [userID stringByAppendingString:primarykey];
                    
                    NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                    
                    NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:address]]];
                    
                    
                    [rowValue setString:pKey];
                    [senderName setString:[dict valueForKey:@"First Name"]];
                    [senderName appendString:@" "];
                    [senderName appendString:[dict valueForKey:@"Last Name"]];
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                    [_ref updateChildValues:childUpdates];
                    [emailList addObject:address];
                    
                }
                
                
                
                else {
                    
                    [noneList addObject:address];
                    
                }
                
                
                i++;
                
                
            }
            
            
            
        }];
        
        while([rowValue length]== 0 && [senderName length] ==0 && ([emailList count] == 0 || [noneList count] == 0)) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if([emailList count] > 0) {
            
            // Email Subject
            NSString *emailTitle = @"Message From GeuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey!, This is %@  and I want to invite you at my place on %@ at %@ , please login to this new cool App GuestVite! for all further details, Thanks and looking forward to see you soon!",senderName,self.inviteForDateText.text,self.startTime];
            // To address
            //NSArray *toRecipents = [NSArray arrayWithObject:self.guestEMailText.text];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:emailList];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
            
            
        }
        
    }
    
    else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }

    
    
    
    }// else ends
    
        
    
    
    if([noneList count] > 0) {
        
        NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.eMailguestList.text];
        
        for(NSString *temp in arr){
            for(NSString *tempNone in noneList){
                
                if([temp isEqualToString:tempNone]){
                    
                    //NSLog(@"None String is %@",temp);
                    
                    NSRange range=[self.eMailguestList.text rangeOfString:temp];
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                }
            }
        }
        
        [self.eMailguestList setAttributedText:string];
        
    }
    
    
    //NSLog(@"Email List: %@",emailList);
    
    //NSLog(@"None List: %@",noneList);
}

    



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
            
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
           // NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
           // NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent: {
            //NSLog(@"Mail SENT!!!");
            
            break;
        }
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
