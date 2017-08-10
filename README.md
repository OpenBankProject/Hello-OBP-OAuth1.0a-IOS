Hello-OBP-OAuth1.0a-iOS
========================

This is a basic iOS app that talks to Open Bank Project's API sandbox, demonstrates authorization and retrieves banks, accounts and transactions. (If you just need a simple OBP starter app to copy and modify, try [OBP-iOS-Starter](https://github.com/OpenBankProject/OBP-iOS-Starter).)

The app will proceed through OAuth1 authentication, and then make signed API requests that retrieve the list of [private accounts](https://github.com/OpenBankProject/OBP-API/wiki/REST-API-V1.2#accounts-private) on the sandbox API and show their details in the UI (see below for example accounts to log in). 

You can then use this demonstration as an example of how to use the Open Bank Project (OBP) API to create apps that allow user to access to their bank data, and create Banking, Accounting, ERM, or other financial applications utilizing this OBP JSON API. You can find the latest API specifications on the [OBP API Wiki](https://github.com/OpenBankProject/OBP-API/wiki).

The OBI API does not require OAuth, but this project uses it. However, all the heavy lifting is done for you by [OBPKit](https://github.com/OpenBankProject/OBPKit-iOSX).

## Login credentials

You will need to login to the OBP Sandbox API when running the app (which talks to the server apisandbox.openbankproject.com), just download install and click login. Then you can use following test login credentials:

username: joe.bloggs@example.com
password: qwerty
(contains various bank accounts including blank accounts, and accounts with errors) 

username: jane.bloggs@example.com
password: qwerty
(contains two bank accounts)

username: john.bloggs@example.com
password: qwerty
(contains one bank account)

You can also setup your own instance of the API and point this app to your instance in this demo, instructions to do this below.

## Installation

To install the project source, clone the git repo and then according to your preference, run [Carthage][] ([install][Carthage-install]) or [CocoaPods][] ([install][CocoaPods-install]).

I.e. first...

```sh
$ cd somewhere-suitable
$ git clone https://github.com/OpenBankProject/Hello-OBP-OAuth1.0a-iOS.git HelloOBP-iOS
Cloning into 'HelloOBP-iOS'...
remote: Counting objects: 478, done.
remote: Compressing objects: 100% (82/82), done.
remote: Total 478 (delta 27), reused 0 (delta 0), pack-reused 392
Receiving objects: 100% (478/478), 2.05 MiB | 948.00 KiB/s, done.
Resolving deltas: 100% (180/180), done.
Checking connectivity... done.
```

...then either use Carthage...

```sh
$ cd HelloOBP-iOS
$ carthage update --no-build --no-use-binaries 
*** Fetching OBPKit-iOSX
*** Fetching UICKeyChainStore
*** Fetching STHTTPRequest
*** Fetching OAuthCore
*** Checking out OAuthCore at "0.0.2"
*** Checking out STHTTPRequest at "1.1.1"
*** Checking out UICKeyChainStore at "v2.1.0"
*** Checking out OBPKit-iOSX at "1.0.0"
$ open HelloOBP-iOS-Cart.xcworkspace -a Xcode.app
```

...and then build and run, or use CocoaPods...

```sh
$ cd HelloOBP-iOS
$ pod install 
Analyzing dependencies
Pre-downloading: `OAuthCore` from `https://github.com/t0rst/OAuthCore.git`, commit `03121e6b8bc7ba3dea07df1289546134b192b494`
Pre-downloading: `OBPKit` from `https://github.com/OpenBankProject/OBPKit-iOSX.git`, commit `bb55d0add08e7da87844bfc3108d88a9e8b467a7`
Downloading dependencies
Installing OAuthCore (0.0.2)
Installing OBPKit (1.0.0)
Installing STHTTPRequest (1.1.0)
Installing UICKeyChainStore (2.1.0)
Generating Pods project
Integrating client project
[!] Please close any current Xcode sessions and use `HelloOBP-iOS-Pods.xcworkspace` for this project from now on.
Sending stats
Pod installation complete! There are 2 dependencies from the Podfile and 4 total pods installed.
[!] CocoaPods did not set the base configuration of your project because...
$ open HelloOBP-iOS-Pods.xcworkspace -a Xcode.app
```

...then one extra, not-yet-automated step that is needed with the latest CocoaPods (`pod --version` >= 1.0.0): in the navigator pane, click on the blue HelloOBP-iOS project icon, select HelloOBP-iOS under TARGETS, select Build Phases, clieck the 'x' to the right of the "Embed Frameworks (4 items)" build phase, as CocoaPods has installed it own "[CP] Embed Pods Frameworks" build phase further down (commiting this change now will allow you to easily revert it should you wish to try out using carthage later), and then...

...build and run. 

You can ignore the two pod warnings starting "CocoaPods did not set the base configuration of your project because...etc", because HelloOBP-iOS.xcodeproj configures for carthage or cocoapods whenever you build: a script sets the build configuration files Debug(dynamic).xcconfig and Release(dynamic).xcconfig to be copies of Debug(carthage).xcconfig and Release(carthage).xcconfig or Debug(cocoapods).xcconfig and Release(cocoapods).xcconfig, as appropriate. This sometimes goes under Xcode's radar, and you get a warning, but this clears after you clean, close and reopen the project.

## Screenshots

Login page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-login.png" />

Accounts page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-accounts.png" />

Transactions page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-transactions.png" />

## Setup of API on own server

If you want to work with your own credentials, there are a couple of things you need to do to get this project set up.

1. Get a client key and secret by registering your client at https://apisandbox.openbankproject.com/consumer-registration

2. Put your credentials into DefaultServerDetails.h

Current list of supported banks:  [https://api.openbankproject.com/connectors-status/](https://api.openbankproject.com/connectors-status/)

## LICENSE

This demo app is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

[Carthage]: https://github.com/Carthage/Carthage/blob/master/README.md
[Carthage-install]: https://github.com/Carthage/Carthage/blob/master/README.md#installing-carthage
[CocoaPods]: https://github.com/CocoaPods/CocoaPods/blob/master/README.md
[CocoaPods-install]: http://guides.cocoapods.org/using/getting-started.html#installation
