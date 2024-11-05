/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2024 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Unit tests for the "HttpMockUtil" Apex Class
 */
@IsTest
private with sharing class HttpMockUtilTest {

    /** **************************************************************************************************** **
	 **                                          PRIVATE CONSTANTS                                           **
	 ** **************************************************************************************************** **/
    // Create a test user with minimum access and a permission set
    static final User TST_USER  = ApexUnitTestUtil.createRunAsUser(
        ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
        ApexUnitTestUtil.PERMISSION_SET_NAME
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
            HttpMockUtil.setResponse('{"test" : false}');

            // Test response
            Assert.areEqual(200,                HttpMockUtil.getInstance().respond(null).getStatusCode(),'Unexpected response status code');
            Assert.areEqual('{"test" : false}', HttpMockUtil.getInstance().respond(null).getBody(),      'Unexpected responsebody');

            // Set test response with status code
            HttpMockUtil.setResponse(200, '{"test" : true}');
            
            // Test response
            Assert.areEqual(200,                HttpMockUtil.getInstance().respond(null).getStatusCode(), 'Unexpected response status code');
            Assert.areEqual('{"test" : true}',  HttpMockUtil.getInstance().respond(null).getBody(),       'Unexpected responsebody');

            // Set test response with status code and custom header map
            HttpMockUtil.setResponse(400, '{"test" : false}', CUSTOM_HEADER_MAP);

            // Test response
            Assert.areEqual(400,                 HttpMockUtil.getInstance().respond(null).getStatusCode(),             'Unexpected response status code');
            Assert.areEqual('{"test" : false}',  HttpMockUtil.getInstance().respond(null).getBody(),                   'Unexpected responsebody');
            Assert.areEqual('CustomHeaderValue', HttpMockUtil.getInstance().respond(null).getHeader('CustomHeaderKey'),'Expected header value CustomHeaderKey to be in the header');
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
            HttpMockUtil.addResponse('FIRST_RESPONSE',  200, '{"test" : true}');
            HttpMockUtil.addResponse('SECOND_RESPONSE', 400, '{"test" : false}', CUSTOM_HEADER_MAP);

            // Test response 'FIRST_RESPONSE'
            HttpMockUtil.setResponseIdentifier('FIRST_RESPONSE');
            Assert.areEqual(200,                HttpMockUtil.getInstance().respond(null).getStatusCode(), 'Unexpected response status code');
            Assert.areEqual('{"test" : true}',  HttpMockUtil.getInstance().respond(null).getBody(),       'Unexpected response body');
            
            // Test response 'SECOND_RESPONSE'
            HttpMockUtil.setResponseIdentifier('SECOND_RESPONSE');
            Assert.areEqual(400,                HttpMockUtil.getInstance().respond(null).getStatusCode(),              'Unexpected response status code');
            Assert.areEqual('{"test" : false}', HttpMockUtil.getInstance().respond(null).getBody(),                    'Unexpected responsebody');
            Assert.areEqual('CustomHeaderValue',HttpMockUtil.getInstance().respond(null).getHeader('CustomHeaderKey'), 'Expected header value CustomHeaderKey to be in the header');
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
                HttpMockUtil.setResponseIdentifier(null);
                HttpMockUtil.getInstance().respond(null);
                
                // Make sure that if this part of the code is reached, a test exception will be thrown
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(Exception e){
                // Assert the error message
                ApexUnitTestUtil.assertExceptionMessage(HttpMockUtil.MSG_NO_REPONSE_ID, e);
            }


            try{
                // Set a null identifer and execute the callout logic
                HttpMockUtil.setResponseIdentifier('INVALID_IDENTIFIER');
                HttpMockUtil.getInstance().respond(null);

                // Make sure that if this part of the code is reached, a test exception will be thrown
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(Exception e){
                // Assert the error message
                ApexUnitTestUtil.assertExceptionMessage(HttpMockUtil.MSG_INVALID_REPONSE_ID, 'INVALID_IDENTIFIER', e);   
            }        
        }
        Test.stopTest();
    }
}