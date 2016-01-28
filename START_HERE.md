# OBPKit

TESOBE Ltd
28 January 2016

*— Preliminary —*

## Overview

OBPKit allows you to connect your existing iOS and OSX apps to Open Bank Project servers.

It takes care of the OAuth process, and once the user has authorised your app to access his/her resources, it will add authorisation headers to each of your requests as you continue to access the Open Bank Project API.

Installation is fairly simple, and there are only a few calls to make. You can look at the HelloOBP sample application to see OBPKit in use.

## Installation

CocoaPods and Carthage support will be added soon, but for now, you will need to install manually with just a few steps:

1.	Add Hello-OBP-OAuth1.0a-IOS as a submodule to your project repo from https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS.git in your directory for third party sources, and check out the 'experimental' branch.

1.	Hello-OBP-OAuth1.0a-IOS has its self got submodules, so do `git submodule init` and `git submodule update` to copy source into the workspace.

1.	Add just the OBPKit folder hierarchy to your project. In the subfolder OBKit/External/STHTTPRequest, you need only add STHTTPRequest.h and .m and the README.md

1.	Add Security.framework to your project if not already.

## Classes

There are two classes to use and one protocol to adopt.

### OBPAccessData

An OBPAccessData instance records the data necessary to access an OBP server. It stores sensitive credentials securely in the key chain.

The OBPAccessData class keeps a persistant record of all complete instances. An instance is complete once its client key and secret have been set. You can typically obtain these for your app from https://<OBP server host>/consumer-registration.

You can use OBPAccessData to keep a record of all the OBP servers for which you support a connection; mostly you will just have one, but more are possible. OBPAccessData instances are reloaded automatically when your app is launched.

### OBPSessionAuth

An OBPSessionAuth instance will perform the OAuth authorisation sequence when requested, using data provided by an OBPAccessData instance. You create an OBPSessionAuth instance for an OBP server that you want to connect to.

The OBPSessionAuth class keeps track of the instances that are currently alive. Both OBPAccessData and OBPSessionAuth allow you to access default instances, or when you only want to deal with singletons.

### OBPWebViewProvider

OBPSessionAuth needs some part of your app to act as an OBPWebViewProvider protocol adopter, so that OBPSessionAuth can show the user a web page when it is time to get his/her authorisation.

## Use

The way the classes are used in the HelloOBP sample apps demonstrates how to use the OBPKit classes fairly simply.

In your app delegate after start-up, check for and create if necessary the OBPAccessData instance for the main server you will connect to:

	if (nil == [OBPAccessData firstEntryForAPIServer: kDefaultServer_APIBase])
	{
		OBPAccessData*	accessData;
		accessData = [OBPAccessData addEntryForAPIServer: kDefaultServer_APIBase];
		accessData.data = DefaultServerDetails();
	}

Here the details of the default server are fetched from a header (DefaultServerDetails.h), which is insecure, but in production, they should be obtained from an encrypted source.

In your main or starting view, create the OBPSessionAuth instances that you want to work with:

    if (_sessionAuth == nil)
	{
		OBPAccessData*	accessData = [OBPAccessData defaultEntry];
		_sessionAuth = [OBPSessionAuth sessionAuthWithAccessData: accessData];
	}

When the user requests to log in, set the default SessionAuth instance to validate, i.e. get authorisation for accessing resources on behaf of the client:

	- (void)viewDidLoad
	{
		...

		_accessData = [OBPAccessData defaultEntry];
		_sessionAuth = [OBPSessionAuth sessionAuthWithAccessData: _accessData];

		self.webView.delegate = self;
		_sessionAuth.webViewProvider = self;

		// Kick off session authentication
		[_sessionAuth validate:
			^(NSError* error)
			{
				if (error == nil) // success...
					[self fetchAccounts];
				[self.navigationController popToRootViewControllerAnimated:YES]; // done with log-in
			}
		];
	}

From this point onwards, where you want to access the OBP API, use the current sessionAuth instance to authorise your URL requests as the last step befor sending them:

	// ...request is complete apart from last step, which is to authorise it, then send
	if ([[OBPSessionAuth currentSession] authorizeSTHTTPRequest: request])
		[request startAsynchronous];


