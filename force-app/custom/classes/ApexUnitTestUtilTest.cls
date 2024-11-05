/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2024 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Unit tests for the "Tst" Apex Class
 * @false-positive PMD.ApexUnitTestClassShouldHaveAsserts  Asserts are executed through a utility method in the
 *                                                         "ApexUnitTestUtil" Apex Class.
 */
@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private with sharing class ApexUnitTestUtilTest {

    /** **************************************************************************************************** **
	 **                                          PRIVATE CONSTANTS                                           **
	 ** **************************************************************************************************** **/
    // Create a test user with minimum access and a permission set
    static final User TST_USER  = ApexUnitTestUtil.createRunAsUser(
        ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
        ApexUnitTestUtil.PERMISSION_SET_NAME
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
            ApexUnitTestUtil.addForcedException('APEX_UNIT_TEST');

            try{
                // This should throw an exception now
                ApexUnitTestUtil.forceException('APEX_UNIT_TEST');

                // Make sure this part of the code is not reached without throwing an error
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.ForcedException e){

                // Test the standard forced exception message has been trhown
                ApexUnitTestUtil.assertForcedExceptionMessage(e);
            }

            // Remove the identifier
            ApexUnitTestUtil.removeForcedException('APEX_UNIT_TEST');

            // This should now NOT throw an exception
            ApexUnitTestUtil.forceException('APEX_UNIT_TEST');
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
            ApexUnitTestUtil.addForcedCondition('APEX_UNIT_TEST');

            // Validate the condition exists and returns true
            Assert.areEqual(true, ApexUnitTestUtil.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be true');

            // Remove the identifier
            ApexUnitTestUtil.removeForcedCondition('APEX_UNIT_TEST');

            // Validate the exception exists
            Assert.areEqual(false, ApexUnitTestUtil.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be false');
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
            ApexUnitTestUtil.safetyOverride = true;

            // Execute the logic
            ApexUnitTestUtil.assertExceptionHasBeenThrow();

            // Turn off so other tests don't fail
            ApexUnitTestUtil.safetyOverride = false;
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
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            // Create a user that has no permission sets
            User testUser = ApexUnitTestUtil.createRunAsUser(ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE);

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
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            // Create a user with data overrides
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
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
        System.runAs(ApexUnitTestUtil.getRunningUser()){

            // Invalid profile exception
            try{
                // Create a user with an invalid profile
                ApexUnitTestUtil.createRunAsUser('Invalid profile name');

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();
            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    ApexUnitTestUtil.PROFILE_DOES_NOT_EXIST_ERROR,
                    'Invalid profile name',
                    e
                );
            }

            // Invalid profile exception
            try{
                // Create a user with an invalid profile
                ApexUnitTestUtil.createRunAsUser(
                    ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                    new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME,'Invalid'}
                );

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    ApexUnitTestUtil.PERM_SET_DOES_NOT_EXIST_ERROR,
                    '2',
                    '1',
                    e
                );
            }

            // Invalid field in the data map
            try{
                // Create a user with an invalid field
                ApexUnitTestUtil.createRunAsUser(
                    ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                    new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                     new Map<String,Object>{
                    'FirstName'         => 'Henk',
                    'LastName'          => 'de Vries',
                    'InvalidField :-)'  => true
                }
                );

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    ApexUnitTestUtil.INVALID_FIELD_VALUE_MAP_FIELD,
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
            ApexUnitTestUtil.TEST_SR_BODY,
            ApexUnitTestUtil.getStaticResourceBody(ApexUnitTestUtil.TEST_SR_NAME),
            'Unexpected static resource body'
        );

        // Test the exceptions
        try{
            // Invalid static resource name
            ApexUnitTestUtil.getStaticResourceBody('invalid');

            // This code should not be reached
            ApexUnitTestUtil.assertExceptionHasBeenThrow();

        }catch(ApexUnitTestUtil.InvalidDataException e){
            ApexUnitTestUtil.assertExceptionMessage(
                ApexUnitTestUtil.STATIC_RESOURCE_ERROR,
                'invalid',
                e
            );
        }
	}
}