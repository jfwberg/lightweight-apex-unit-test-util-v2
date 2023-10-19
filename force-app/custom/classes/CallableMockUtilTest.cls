/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Unit tests for the "CallableMockUtil" Apex Class
 */
@IsTest
private with sharing class CallableMockUtilTest {

    /** **************************************************************************************************** **
	 **                                          PRIVATE CONSTANTS                                           **
	 ** **************************************************************************************************** **/
    // Create a test user with minimum access and a permission set
    static final User TST_USER  = ApexUnitTestUtil.createRunAsUser(
        ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
        ApexUnitTestUtil.PERMISSION_SET_NAME
    );

    
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
            
            // Create a new action
            CallableMockUtil.setActionResponse('testBoolean', true);

            // Create a new test object
            Callable callableObject = CallableMockUtil.getInstance();

            // Test the default action
            Assert.areEqual(
                true,
                (Boolean) callableObject.call('testBoolean',null),
                'Unexpected callable value'
            );

            try {
                // Force an exception
                callableObject.call('invalid',null);
                
                // Make sure this part of the code has not been reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            } catch (Exception e) {
                // Assert the exception message
                ApexUnitTestUtil.assertExceptionMessage(
                    CallableMockUtil.INVALID_ACTION_MSG, 'invalid', e);
            }
        }
        Test.stopTest();
    }
}