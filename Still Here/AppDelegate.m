//
//  AppDelegate.m
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "SHANestOperations.h"
#import "SHAConstants.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) SHANestOperations *nestOperationsManager;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;

@end

@implementation AppDelegate

- (void)registerURLScheme
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSURL *url = [NSURL URLWithString:urlString];

	/* TODO: Make more robust */
	if ([[url query] containsString:kSHANestAccessTokenKey]) {
		NSArray *query = [[url query] componentsSeparatedByString:@"="];
		NSUInteger accessTokenIndex = [query indexOfObject:kSHANestAccessTokenKey] + 1;
		[[NSUserDefaults standardUserDefaults] setObject:query[accessTokenIndex] forKey:kSHANestAccessTokenKey];

		[self subscribeToNestUpdates];
	}
}

- (void)subscribeToNestUpdates
{
	self.nestOperationsManager = [SHANestOperations sharedManager];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self registerURLScheme];

	if ([[NSUserDefaults standardUserDefaults] stringForKey:kSHANestAccessTokenKey] == nil)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://home.nest.com/login/oauth2?client_id=%@&state=%@", kSHANestAPIClientID, [NSUUID UUID].UUIDString]]];
	else
		[self subscribeToNestUpdates];
}

- (void)awakeFromNib
{
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	self.statusItem.menu = self.statusMenu;
	self.statusItem.button.accessibilityTitle = @"Still Awake Menu";

	NSImage *houseIconImage = [NSImage imageNamed:@"houseMenu"];
	[houseIconImage setTemplate:YES];
	self.statusItem.button.image = houseIconImage;
}

- (IBAction)toggleDockIcon:(id)sender
{
	if ([NSApp activationPolicy] == NSApplicationActivationPolicyRegular)
		[NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
	else
		[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:nil];
}

@end
