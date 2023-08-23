@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest
public with sharing class TstDemoTest {

    /** **************************************************************************************************** **
     **                                      EXCEPTION UTILIY METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test difficult to reach or impossible to reach exception
     */
     @IsTest
    static void testUnreachableException(){
        
        // Add the DEBUG_ABC identifier, any method that has this identifier
        // specified will throw an exception
        utl.Tst.addForcedException('DEBUG_ABC');

        // Test code that will thrown an exception
        try{
            // This method should throw an exception, if not it continues
            TstDemo.unreachableException();
    
            // Make sure this part of the code is not reached without throwing an error
            utl.Tst.assertExceptionHasBeenThrow();
            
        // By default a ForcedException is thrown, this is only visible and possible in test classes
        }catch(utl.Tst.ForcedException e){
            
            // We can check the forced exception message with a standard method
            utl.Tst.assertForcedExceptionMessage(e);

            // Optionally, we can manually assert the message using the getDefaultForcedExceptionMessage()
            // method. This method return the default forced exception message
            Assert.areEqual(
                utl.Tst.getForcedExceptionMessage(),
                e.getMessage()
            );
        }finally{
            // Don't break any other tests so do a clean-up
            utl.Tst.removeForcedException('DEBUG_ABC');
        }
    }


    /**
     * @description Method to test difficult to reach or impossible to reach exception
     *              with additional details in the exception message
     */
    @IsTest
    static void testUnreachableExceptionWithDetails(){
        
        // Add the DEBUG_ABC identifier
        utl.Tst.addForcedException('DEBUG_ABC');

        // Test code that will thrown an exception
        try{
            // This method should throw an exception, if not it continues
            TstDemo.unreachableExceptionWithDetails();
    
            // Make sure this part of the code is not reached without throwing an error
            utl.Tst.assertExceptionHasBeenThrow();
            
        // Catch the string exception
        }catch(StringException e){
            
            // In this example we're using the getForcedExceptionMessage() method to 
            // validate the message is the same as in our  method that has combined the exception message
            Assert.areEqual(
                TstDemo.DEBUG_ABC_MESSAGE + TstDemo.DELIMITER + utl.Tst.getForcedExceptionMessage(),
                e.getMessage()
            );
        }finally{
            // Don't break any other tests so do a clean-up
            utl.Tst.removeForcedException('DEBUG_ABC');
        }
    }


    /**
     * @description Method to test difficult to reach or impossible to reach condition
     */
    @IsTest
    static void testForcedCondition(){
        
        // Add the DEBUG_ABC identifier, any method that has this identifier
        // specified will throw return TRUE
        utl.Tst.addForcedCondition('DEBUG_ABC');

        // Test code that will thrown an exception
        try{
            // This method should throw an exception, if not it continues
            TstDemo.forcedCondition();
    
            // Make sure this part of the code is not reached without throwing an error
            utl.Tst.assertExceptionHasBeenThrow();
    
        }catch(StringException e){
            // Assert the correct exception has been thrown
            utl.Tst.assertExceptionMessage(TstDemo.DEBUG_ABC_MESSAGE,e);
        }finally{
            // Don't break any other tests so do a clean-up
            utl.Tst.removeForcedCondition('DEBUG_ABC');
        }
    }


    /**
     * @description Method to test an exception message that has a single parameter {0}
     */
    @IsTest
    static void testThrowExceptionWithSingleParameter(){
        try{
            // This method should throw an exception, if not it continues
            TstDemo.throwExceptionWithSingleParameter('sObject__c');
    
            // Make sure this part of the code is not reached without throwing an error
            utl.Tst.assertExceptionHasBeenThrow();
    
        }catch(StringException e){
            
            // Assert a message with two formatted parameters
            utl.Tst.assertExceptionMessage(
                TstDemo.SINGLE_PARAM_MESSAGE,
                'sObject__c',
                e
            );
        }
    }


    /**
     * @description Method to test an exception message that has a multiple parameters {0} {1}
     */
    @IsTest
    static void testThrowExceptionWithTwoParameters(){
        try{
            // This method should throw an exception, if not it continues
            TstDemo.throwExceptionWithTwoParameters('Field__c','sObject__c');
    
            // Make sure this part of the code is not reached without throwing an error
            utl.Tst.assertExceptionHasBeenThrow();
    
        }catch(StringException e){
            
            // Assert a message with two formatted parameters
            utl.Tst.assertExceptionMessage(
                TstDemo.MULTI_PARAM_MESSAGE,
                'Field__c',
                'sObject__c',
                e
            );
        }
    }
    

    /** **************************************************************************************************** **
     **                                          USER UTILIY METHODS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method create a TEST user with a minimum access profile that we can use for run as
     */
    @IsTest
    static void testCreateTestUser(){
        
        // Create a TEST user with a minimum access profile that we can use for run as
        final User testUser  = utl.Tst.createRunAsUser(
            utl.Tst.MINIMUM_ACCESS_PROFILE
        );


        Test.startTest();
        System.runAs(testUser){
            Assert.areEqual(true, true);
        }
        Test.stopTest();
        
    }


    /**
     * @description Method to create a TEST user with a minimum access profile and a single permission set
     */
    @IsTest
    static void testCreateTestUserWithPermissionSet(){
        
        // Create a TEST user with a minimum access profile and a single permission set
        final User testUser  = utl.Tst.createRunAsUser(
            utl.Tst.MINIMUM_ACCESS_PROFILE,
            utl.Tst.PERMISSION_SET_NAME
        );


        Test.startTest();
        System.runAs(testUser){
            Assert.areEqual(true, true);
        }
        Test.stopTest();
        
    }


    /**
     * @description Method to create a TEST user with a list of multiple permission sets
     */
    @IsTest
    static void testCreateTestUserWithMultiplePermissionSets(){
        
        // Create a TEST user with a list of multiple permission sets
        final User testUser  = utl.Tst.createRunAsUser(
            utl.Tst.MINIMUM_ACCESS_PROFILE,
            new String[]{utl.Tst.PERMISSION_SET_NAME}
        );

        Test.startTest();
        System.runAs(testUser){
            Assert.areEqual(true, true);
        }
        Test.stopTest();  
    }

    
    /**
     * @description Method to create a TEST user with a list of multiple permission sets
     *              and a set of standard fields to override with a custom value
     */
    @IsTest
    static void testCreateTestUserWithPermissionSetAndFieldOverrides(){
        
        // Method to create a TEST user with a list of multiple permission sets
        // and a set of standard fields to override with a custom value
        final User testUser  = utl.Tst.createRunAsUser(
            utl.Tst.MINIMUM_ACCESS_PROFILE,
            new String[]{utl.Tst.PERMISSION_SET_NAME},
            new Map<String,Object>{
                'FirstName' => 'Henk',
                'LastName'  => 'de Vries'
            }
        );

        Test.startTest();
        System.runAs(testUser){
            Assert.areEqual(true, true);
        }
        Test.stopTest();
    }


    /**
     * @description Method to get the current running user as a User object
     *              This removes the need to query the current user when you switch
     *              user contexts in the same test.
     */
    @IsTest
    static void testWithTheCurrentlyRunningUser(){
        
        // Method to the get the current running user
        User currentUser = utl.Tst.getRunningUser();

        // Create a TEST user with a minimum access profile and a single permission set
        final User testUser  = utl.Tst.createRunAsUser(
            utl.Tst.MINIMUM_ACCESS_PROFILE,
            utl.Tst.PERMISSION_SET_NAME
        );

        Test.startTest();
        System.runAs(currentUser){
            // Validate the current user Id matches
            Assert.areEqual(UserInfo.getUserId(), currentUser.Id);
        }

        System.runAs(testUser){
            // Validate the current user Id matches
            Assert.areEqual(UserInfo.getUserId(), testUser.Id);
        }
        Test.stopTest();
    }


    /** **************************************************************************************************** **
     **                                         TEST UTILITY METHODS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the static resource utility.
     *              This utility allows you to fetch the body of a static resource
     *              based on the API name. This is handy when you want to compare
     *              test responses like API responses or Certificate data in a test method
     *          
     */
    @IsTest
    static void getStaticResourceBody(){
        // Check the body is as expected
        Assert.areEqual(
            utl.Tst.TEST_SR_BODY,
            utl.Tst.getStaticResourceBody(utl.Tst.TEST_SR_NAME),
            'Unexpected static resource body'
        );
    }
}