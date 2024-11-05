/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2024 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Unit tests for the "Mck" Apex Class
 */
@IsTest
private with sharing class MckTest {

    /** **************************************************************************************************** **
	 **                                          PRIVATE CONSTANTS                                           **
	 ** **************************************************************************************************** **/
    // Create a test user with minimum access and a permission set
    static final User TST_USER  = Tst.createRunAsUser(
        Tst.MINIMUM_ACCESS_PROFILE,
        Tst.PERMISSION_SET_NAME
    );

    // A custom header map for testing
    static final Map<String,String> CUSTOM_HEADER_MAP = new Map<String,String>{'CustomHeaderKey' => 'CustomHeaderValue'};


    /** **************************************************************************************************** **
	 **                                             TEST METHODS                                             **
	 ** **************************************************************************************************** **/
    /**
     * @description  Method for testing multiple callouts in the same method
     */
    @IsTest
    static void testSingleResponse(){
        Test.startTest();
        System.runAs(TST_USER){
            // Set test responses
            Mck.setResponse('{"test" : false}');

            // Test response
            Assert.areEqual(200,                Mck.getInstance().respond(null).getStatusCode(),'Unexpected response status code');
            Assert.areEqual('{"test" : false}', Mck.getInstance().respond(null).getBody(),      'Unexpected responsebody');

            // Set test response with status code
            Mck.setResponse(200, '{"test" : true}');
            
            // Test response
            Assert.areEqual(200,                Mck.getInstance().respond(null).getStatusCode(), 'Unexpected response status code');
            Assert.areEqual('{"test" : true}',  Mck.getInstance().respond(null).getBody(),       'Unexpected responsebody');

            // Set test response with status code and custom header map
            Mck.setResponse(400, '{"test" : false}', CUSTOM_HEADER_MAP);

            // Test response
            Assert.areEqual(400,                 Mck.getInstance().respond(null).getStatusCode(),             'Unexpected response status code');
            Assert.areEqual('{"test" : false}',  Mck.getInstance().respond(null).getBody(),                   'Unexpected responsebody');
            Assert.areEqual('CustomHeaderValue', Mck.getInstance().respond(null).getHeader('CustomHeaderKey'),'Expected header value CustomHeaderKey to be in the header');
        }
        Test.stopTest();
    }


    /**
     * @description  Method for testing multiple callouts in the same method
     */
    @IsTest
    static void testMultipleResponses(){
        Test.startTest();
        System.runAs(TST_USER){
            // Add test responses
            Mck.addResponse('FIRST_RESPONSE',  200, '{"test" : true}');
            Mck.addResponse('SECOND_RESPONSE', 400, '{"test" : false}', CUSTOM_HEADER_MAP);

            // Test response 'FIRST_RESPONSE'
            Mck.setResponseIdentifier('FIRST_RESPONSE');
            Assert.areEqual(200,                Mck.getInstance().respond(null).getStatusCode(), 'Unexpected response status code');
            Assert.areEqual('{"test" : true}',  Mck.getInstance().respond(null).getBody(),       'Unexpected response body');
            
            // Test response 'SECOND_RESPONSE'
            Mck.setResponseIdentifier('SECOND_RESPONSE');
            Assert.areEqual(400,                Mck.getInstance().respond(null).getStatusCode(),              'Unexpected response status code');
            Assert.areEqual('{"test" : false}', Mck.getInstance().respond(null).getBody(),                    'Unexpected responsebody');
            Assert.areEqual('CustomHeaderValue',Mck.getInstance().respond(null).getHeader('CustomHeaderKey'), 'Expected header value CustomHeaderKey to be in the header');
        }
        Test.stopTest();
    }


    /**
     * @description    Method for testing the exception scenarios
     *                 - No response identifier
     *                 - An invalid response identifier
     * @false-positive PMD.ApexUnitTestClassShouldHaveAsserts  Asserts are executed through a utility method in the
     *                                                         "Tst" Apex Class.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testExceptions(){
        Test.startTest();
        System.runAs(TST_USER){
            try{
                // Set a null identifer and execute the callout logic
                Mck.setResponseIdentifier(null);
                Mck.getInstance().respond(null);
                
                // Make sure that if this part of the code is reached, a test exception will be thrown
                Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                // Assert the error message
                Tst.assertExceptionMessage(Mck.MSG_NO_REPONSE_ID, e);
            }


            try{
                // Set a null identifer and execute the callout logic
                Mck.setResponseIdentifier('INVALID_IDENTIFIER');
                Mck.getInstance().respond(null);

                // Make sure that if this part of the code is reached, a test exception will be thrown
                Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                // Assert the error message
                Tst.assertExceptionMessage(Mck.MSG_INVALID_REPONSE_ID, 'INVALID_IDENTIFIER', e);   
            }    
        }
        Test.stopTest();
    }
}