Hello-OBP-OAuth1.0a-IOS
========================

This is a basic app to demonstrate the integration of the OpenBankProject with OAuth1.0-Authentication into an IOS application. The app will run through OAuth authentication, and then make an OAuth signed API request that retrieves the list of [private accounts](https://github.com/OpenBankProject/OBP-API/wiki/REST-API-V1.2#accounts-private) on the sandbox API. 
You then allow user to access to their bank data, so you can create Banking, Accounting, ERM, and other financial applications.

## SETUP

If you want to work with your own credentials, there are a couple of things you need to do to get this project set up.

1. Get consumer key / secret:  
-register your client at  https://apisandbox.openbankproject.com/consumer-registration

2. Enter your app's your of register:  
-set OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET_KEY and OAUTH_URL_SCHEME (yourappname) in OAuth.m

3. Add your callback URL scheme to your app's (yourappname) `Info.plist` file (in the URL types field).

## Login credentials

You will need to login to the OBP Sandbox API (unless you change the API instance) when running the app. This can be done using any the following credentials:

username: joe.bloggs@example.com
password: qwerty

username: jane.bloggs@example.com
password: qwerty

username: john.bloggs@example.com
password: qwerty

## LICENSE

This project is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
