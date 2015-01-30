Hello-OBP-OAuth1.0a-iOS
========================

This is a basic app to demonstrate the integration of the OpenBankProject with OAuth1.0-Authentication into an iOS application. The app will run through OAuth authentication, and then make an OAuth signed API request that retrieves the list of [private accounts](https://github.com/OpenBankProject/OBP-API/wiki/REST-API-V1.2#accounts-private) on the sandbox API and show them in the UI (see below for example accounts to log in). 

You can then use this demonstration as an example of how to use the Open Bank Project (OBP) API to create apps that allow user to access to their bank data, and create Banking, Accounting, ERM, or other financial applications utilizing this OBP JSON API. Documentation about the latest OBP API specifications here: [Version: 1.2.1](https://github.com/OpenBankProject/OBP-API/wiki/REST-API-V1.2.1)

Though the OBI API does not require OAuth, this project uses OAuth to do so, in order to demonstrate the process. 

## Login credentials

You will need to login to the OBP Sandbox API when running the app (which talks to the server apisandbox.openbankproject.com), just download install and click login. (If you are using iTimeBalance you will need to select "OBP Sandbox" as the login API from the selection). Then you can use following test login credentials:

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

## Screenshots

Login page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-login.png" />

Accounts page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-accounts.png" />

Transactions page

<img src="https://raw.githubusercontent.com/OpenBankProject/Hello-OBP-OAuth1.0a-IOS/master/images/hello-obp-transactions.png" />

## Setup of API on own server

If you want to work with your own credentials, there are a couple of things you need to do to get this project set up.

1. Get consumer key / secret:  
-register your client at  https://apisandbox.openbankproject.com/consumer-registration

2. Enter your app's your of register:  
-set OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET_KEY and OAUTH_URL_SCHEME (yourappname) in OAuth.m

3. Add your callback URL scheme to your app's (yourappname) `Info.plist` file (in the URL types field).

Current list of supported banks:  [https://api.openbankproject.com/connectors-status/](https://api.openbankproject.com/connectors-status/)

## LICENSE

This demo app is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
