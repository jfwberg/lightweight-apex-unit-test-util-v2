# Lightweight - Apex Unit Test Util v2
## Description
A lightweight Apex Unit Test Utility library for User creation, Exception Testing, HTTP Callout and Callable Mocking

## Blog details
**Advanced Exception Testing**
https://medium.com/@justusvandenberg/advanced-exception-handling-in-salesforce-apex-unit-tests-958bef9c34a9

**Callable Interface Testing**
https://medium.com/@justusvandenberg/testing-apex-callable-interface-dependencies-in-salesforce-unit-tests-db039342db22

**Testing Callouts**
Coming soon...

## Package info
| Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2|
|Version|2.3.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007oePIAQ*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007og1IAA*


# Demo
For detailed examples see the *force-app/demo* folder. Note that the demo files are OOTB only working with the packaged versions. To use the custom versions remove the namespace and update the class names accordingly.

# Custom Implementation
For an example of a custom implementation without the use of a namespace see the *force-app/custom* folder.
In a custom implementation all the global modifiers have been changed to public or private with the @TestVisible annotation.
The ```checkTestStatus();``` methods have been removed as well, as this is not required when the @TestVisible annotation is used.

# HTTP Mock Utilities
## Apex Class Methods (Implement in *standard* apex classes only)
```java
// If you have a method that has multiple callouts, add an identifier
// to each callout. In the test class you can match the response to the identifier
// This method is NOT required for tests with a single callout
utl.Mck.setResponseIdentifier(IDENTIFIER_NAME);
```

## Test Class Methods (Implement in *test* classes only)
```java
// This method is only used to mock the callout class
// The following line should be in each test method where you have a callout
Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

// Method and overloads to set a SINGLE Mock response
utl.Mck.setResponse('responseBody');
utl.Mck.setResponse(200, 'responseBody');
utl.Mck.setResponse(200, 'responseBody', new Map<String,String>{'Custom' => 'Header'});

// Method and overloads to add MULTIPLE Mock responses that are returned for a a specific identifier
utl.Mck.addResponse(IDENTIFIER_NAME, 200, 'responseBody');
utl.Mck.addResponse(IDENTIFIER_NAME, 200, 'responseBody', new Map<String,String>{'Custom' => 'Header'});
```

# Test Utilities
## Apex Class Methods (Implement in *standard* apex classes only)
```java
// Force an exception 
utl.Tst.forceException(IDENTIFIER_NAME);

// Force a Boolean that is resturn TRUE
Boolean result = utl.Tst.forceCondition(IDENTIFIER_NAME);
```

## Test Class Methods (Implement in *test* classes only)
```java
/**
 * FORCED EXCEPTION & CONDITION METHODS
 */ 
// Method to add and remove a forced exception identifier
utl.Tst.addForcedException(IDENTIFIER_NAME);
utl.Tst.removeForcedException(IDENTIFIER_NAME);

// Method to add and remove a forced TRUE condition identifier
Tst.addForcedCondition(IDENTIFIER_NAME);
Tst.removeForcedCondition(IDENTIFIER_NAME);


/**
 * ASSERT METHODS
 */
// Get the exception message that was forced through the forceException() method
String message = utl.Tst.getForcedExceptionMessage();

// The method will throw an exception. Place this method in your test class after 
// the code that should throw an exception.If your code does not throw an exception, the test fails.
// This method will fail the test as it should not be reached
utl.Tst.assertExceptionHasBeenThrow();

// Assert the default forced exception message
utl.Tst.assertForcedExceptionMessage(e);

// Assert a string and the exception message from the e.getMessage() method
utl.Tst.assertExceptionMessage('expectedMessage', 'actualMessage');
utl.Tst.assertExceptionMessage('expectedMessage', e);

// Assert a formatted string with a single value and the exception message from e.getMessage()
// Example: "sObject {0} does not exist in the metadata"
utl.Tst.assertExceptionMessage('expectedMessage', 'firstDetail', 'actualMessage');
utl.Tst.assertExceptionMessage('expectedMessage', 'firstDetail', e);

// Assert a formatted string with multiple values and the exception message from e.getMessage()
// Example: "field {0} does not exist on sObject {1}"
utl.Tst.assertExceptionMessage('expectedMessage', 'firstDetail', 'secondDetail', 'actualMessage');
utl.Tst.assertExceptionMessage('expectedMessage', 'firstDetail', 'secondDetail', e);


/**
 * STATIC RESOURCE METHODS
 */
// Method to get the body of a static resource, ideal for storing large test payloads
String body = utl.Tst.getStaticResourceBody(MY_STATIC_RESOURCE);


/**
 * USER CREATION METHODS
 */
// Method to get the current running user as a User object
User currentUser = Tst.getRunningUser();

// Method and overload methods to create a new User
User runAsUser = Tst.createRunAsUser(PROFILE_NAME);

// Method and overload methods to create a new User with a profile and single permission set
User runAsUser = Tst.createRunAsUser(
    PROFILE_NAME,
    PERMISSION_SET_NAME
);

// Method and overload methods to create a new User with a profile and multiple permission sets
User runAsUser = Tst.createRunAsUser(
    PROFILE_NAME,
    new String[]{PERMISSION_SET_ONE, PERMISSION_SET_TWO}
);


// Method and overload methods to create a new User with a profile and multiple permission sets
User runAsUser = Tst.createRunAsUser(
    PROFILE_NAME,
    new String[]{PERMISSION_SET_ONE, PERMISSION_SET_TWO}
);

// Method and overload methods to create a new User with a profile and multiple permission sets
// and the ability to override any fields on the User record.
User runAsUser = createRunAsUser(
    PROFILE_NAME,
    new String[]{PERMISSION_SET_ONE, PERMISSION_SET_TWO},
    new Map<String,Object>{
        'FirstName'         => 'Henk',
        'LastName'          => 'de Vries',
        'LanguageLocaleKey' => 'en_US',
        'LocaleSidKey'      => 'en_US',
        'TimeZoneSidKey'    => 'America/Los_Angeles'
    }
);
```

# Callable Mock Utilities
The callable mock utilities allow you to mock a callable response from a test class.
This allows you to not have the code you call availible in a package during testing, but
you can still get enough code coverage and create a test scenario if required.

## Test Class Methods (Implement in *test* classes only)
```java
    // Run from a TEST CLASS to setup the response
    utl.Clbl.setActionResponse(String action, Object response);
```


## Apex Class Methods (Implement in *standard* apex classes only)
```java
    // Implementation in your normal code to return the Mock callable during an Apex Unit Test
    if(Test.isRunningTest()){
        return (Callable) utl.Clbl.getInstance();
    }
```
