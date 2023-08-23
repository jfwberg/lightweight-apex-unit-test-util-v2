# Lightweight - Apex Unit Test Util v2
## Description
A lightweight Apex Unit Test Utility library for User creation, Exception Testing and HTTP Callout Mocking

| Managed Package Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2|
|Version|2.0.0-2|
|Installation URL| */packaging/installPackage.apexp?p0=04t4K000002JvUDQA0*
|GIT URL|https://github.com/jfwberg/lightweight-apex-unit-test-util-v2.git|

| Unlocked Package Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2 (Unlocked)|
|Version|2.0.0-2|
|Installation URL| */packaging/installPackage.apexp?p0=04t4K000002JvU8QAK*
|GIT URL|https://github.com/jfwberg/lightweight-apex-unit-test-util-v2.git|

# Demo
For detailed examples see the *force-app/demo* folder. Note that teh demo files are OOTB only working with the packaged versions. To use the custom versions remove the namespace and update the class names accordingly.

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
