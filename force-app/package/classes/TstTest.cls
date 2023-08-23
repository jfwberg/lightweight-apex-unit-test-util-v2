/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Unit tests for the "Tst" Apex Class
 * @false-positive PMD.ApexUnitTestClassShouldHaveAsserts  Asserts are executed through a utility method in the
 *                                                         "Tst" Apex Class.
 */
@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private with sharing class TstTest {

    /** **************************************************************************************************** **
	 **                                          PRIVATE CONSTANTS                                           **
	 ** **************************************************************************************************** **/
    // Create a test user with minimum access and a permission set
    static final User TST_USER  = Tst.createRunAsUser(
        Tst.MINIMUM_ACCESS_PROFILE,
        Tst.PERMISSION_SET_NAME
    );


    /** **************************************************************************************************** **
     **                                    NORMAL APEX CLASS SETTERS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the forced exceptions
     */
    @IsTest
    static void testForcedException(){
        Test.startTest();
        System.runAs(TST_USER){

            // Add the identifier for the condition
            Tst.addForcedException('APEX_UNIT_TEST');

            try{
                // This should throw an exception now
                Tst.forceException('APEX_UNIT_TEST');

                // Make sure this part of the code is not reached without throwing an error
                Tst.assertExceptionHasBeenThrow();

            }catch(Tst.ForcedException e){

                // Test the standard forced exception message has been trhown
                Tst.assertForcedExceptionMessage(e);
            }

            // Remove the identifier
            Tst.removeForcedException('APEX_UNIT_TEST');

            // This should now NOT throw an exception
            Tst.forceException('APEX_UNIT_TEST');
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the forced conditions
     */
    @IsTest
    static void testForcedCondition(){
        Test.startTest();
        System.runAs(TST_USER){

            // Add the identifier for the condition
            Tst.addForcedCondition('APEX_UNIT_TEST');

            // Validate the condition exists and returns true
            Assert.areEqual(true, Tst.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be true');

            // Remove the identifier
            Tst.removeForcedCondition('APEX_UNIT_TEST');

            // Validate the exception exists
            Assert.areEqual(false, Tst.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be false');
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the exceptions should have been thrown
     */
    @IsTest
    static void testAssertExceptionHasBeenThrow(){
        Test.startTest();
        System.runAs(TST_USER){

            // Set the override
            Tst.safetyOverride = true;

            // Execute the logic
            Tst.assertExceptionHasBeenThrow();

            // Turn off so other tests don't fail
            Tst.safetyOverride = false;
        }
        Test.stopTest();
    }


    /** **************************************************************************************************** **
     **                                        TEST CLASS SETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the creation of a test user
     */
    @IsTest
    static void testCreateUserWithoutPermissionSets(){
        Test.startTest();
        System.runAs(Tst.getRunningUser()){
            // Create a user that has no permission sets
            User testUser = Tst.createRunAsUser(Tst.MINIMUM_ACCESS_PROFILE);

            // Check that no permission sets are assigned for the newly created user
            Assert.areEqual(
                0,
                [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :testUser.Id AND PermissionSet.IsOwnedByProfile = false],
                'Expected no permission sets to exists'
            );
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the creation of a test user
     */
    @IsTest
    static void testCreateUserWithDataOverrides(){

        Test.startTest();
        System.runAs(Tst.getRunningUser()){
            // Create a user with data overrides
            User testUser = Tst.createRunAsUser(
                Tst.MINIMUM_ACCESS_PROFILE,
                new String[]{Tst.PERMISSION_SET_NAME},
                new Map<String,Object>{
                    'FirstName'         => 'Henk',
                    'LastName'          => 'de Vries',
                    'ReceivesInfoEmails'=> true
                }
            );

            // Check that the custom values on the user record are updated correctly
            Assert.areEqual('Henk',     testUser.FirstName,         'Expected FirstName to be Henk');
            Assert.areEqual('de Vries', testUser.LastName,          'Expected last name to be de Vries');
            Assert.areEqual(true,       testUser.ReceivesInfoEmails,'Expected ReceivesInfoEmails to be true');
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the creation of a test user
     */
    @IsTest
    static void testCreateRunAsUserExceptions(){

        Test.startTest();
        System.runAs(Tst.getRunningUser()){

            // Invalid profile exception
            try{
                // Create a user with an invalid profile
                Tst.createRunAsUser('Invalid profile name');

                // This code should not be reached
                Tst.assertExceptionHasBeenThrow();
            }catch(Tst.InvalidDataException e){

                // Assert a message with a detailed message inside
                Tst.assertExceptionMessage(
                    Tst.PROFILE_DOES_NOT_EXIST_ERROR,
                    'Invalid profile name',
                    e
                );
            }

            // Invalid profile exception
            try{
                // Create a user with an invalid profile
                Tst.createRunAsUser(
                    Tst.MINIMUM_ACCESS_PROFILE,
                    new String[]{Tst.PERMISSION_SET_NAME,'Invalid'}
                );

                // This code should not be reached
                Tst.assertExceptionHasBeenThrow();

            }catch(Tst.InvalidDataException e){

                // Assert a message with a detailed message inside
                Tst.assertExceptionMessage(
                    Tst.PERM_SET_DOES_NOT_EXIST_ERROR,
                    '2',
                    '1',
                    e
                );
            }


            // Invalid field in the data map
            try{
                // Create a user with an invalid field
                Tst.createRunAsUser(
                    Tst.MINIMUM_ACCESS_PROFILE,
                    new String[]{Tst.PERMISSION_SET_NAME},
                     new Map<String,Object>{
                    'FirstName'         => 'Henk',
                    'LastName'          => 'de Vries',
                    'InvalidField :-)'  => true
                }
                );

                // This code should not be reached
                Tst.assertExceptionHasBeenThrow();

            }catch(Tst.InvalidDataException e){

                // Assert a message with a detailed message inside
                Tst.assertExceptionMessage(
                    Tst.INVALID_FIELD_VALUE_MAP_FIELD,
                    'InvalidField :-)',
                    'User',
                    e
                );
            }
        }
        Test.stopTest();
    }


    /** **************************************************************************************************** **
     **                                     PRIVATE TEST UTILITY METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the static resource utility
     */
    @IsTest
    static void getStaticResourceBody(){

        // Check the body is as expected
        Assert.areEqual(
            Tst.TEST_SR_BODY,
            Tst.getStaticResourceBody(Tst.TEST_SR_NAME),
            'Unexpected static resource body'
        );

        // Test the exceptions
        try{
            // Invalid static resource name
            Tst.getStaticResourceBody('invalid');

            // This code should not be reached
            Tst.assertExceptionHasBeenThrow();

        }catch(Tst.InvalidDataException e){
            Tst.assertExceptionMessage(
                Tst.STATIC_RESOURCE_ERROR,
                'invalid',
                e
            );
        }
	}


    /**
     * @description Method to test the test status logic
     */
    @IsTest
    static void testCheckTestStatus(){

        Test.startTest();
        System.runAs(TST_USER){
            try{
                // Set the override
                Tst.isRunningTestOverride = true;

                // Execute the logic
                Tst.checkTestStatus();

                // This code should not be reached
                Tst.assertExceptionHasBeenThrow();

            }catch(Tst.TestContextException e){

                // Turn off so other tests don't fail
                Tst.isRunningTestOverride = false;

                // Validate the exception message
                Tst.assertExceptionMessage(
                    Tst.TEST_METHOD_ONLY_ERROR,
                    e
                );
            }
        }
        Test.stopTest();
    }
}