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

    private static List<PermissionSet> createTestPermissionSets(List<String> names){
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for(String name : names){
            permissionSets.add(new PermissionSet(
                Name = name,
                Label = name
            ));
        }
        insert permissionSets;
        return permissionSets;
    }

    private static List<PermissionSetGroup> createTestPermissionSetGroups(List<String> names){
        List<PermissionSetGroup> permissionSetGroups = new List<PermissionSetGroup>();
        for(String name : names){
            permissionSetGroups.add(new PermissionSetGroup(
                DeveloperName = name,
                MasterLabel = name
            ));
        }
        insert permissionSetGroups;
        return permissionSetGroups;
    }

    private class PermissionAssignmentCounts {
        Integer directPermissionSetCount = 0;
        Integer permissionSetGroupCount = 0;
    }

    private static PermissionAssignmentCounts getPermissionAssignmentCounts(Id assigneeId){
        PermissionAssignmentCounts counts = new PermissionAssignmentCounts();

        for(PermissionSetAssignment psa : [
            SELECT PermissionSetGroupId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :assigneeId
            AND PermissionSet.IsOwnedByProfile = FALSE
        ]){
            if(psa.PermissionSetGroupId != null){
                ++counts.permissionSetGroupCount;
            }else {
                ++counts.directPermissionSetCount;
            }
        }

        return counts;
    }

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

                // Test the standard forced exception message has been thrown
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
            Assert.isTrue(ApexUnitTestUtil.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be true');

            // Remove the identifier
            ApexUnitTestUtil.removeForcedCondition('APEX_UNIT_TEST');

            // Validate the exception exists
            Assert.isFalse(ApexUnitTestUtil.forceCondition('APEX_UNIT_TEST'), 'Expected condition to be false');
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
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);

            // Check that no permission sets are assigned for the newly created user
            Assert.areEqual(
                0,
                counts.directPermissionSetCount,
                'Expected no direct permission set assignments'
            );

            Assert.areEqual(
                0,
                counts.permissionSetGroupCount,
                'Expected no permission set group assignments'
            );
        }
        Test.stopTest();
    }


    @IsTest
    static void testCreateUserWithSinglePermissionSet(){
        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            List<PermissionSet> permissionSets = createTestPermissionSets(
                new List<String>{'ApexUtilSinglePS'}
            );

            // Create a user with one permission set
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{permissionSets[0].Name}
            );
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);

            // Check that one permission set is assigned for the newly created user
            Assert.areEqual(
                1,
                counts.directPermissionSetCount,
                'Expected one permission set assignment'
            );

            Assert.areEqual(
                0,
                counts.permissionSetGroupCount,
                'Expected no permission set group assignments'
            );
        }
        Test.stopTest();
    }


    @IsTest
    static void testCreateUserWithMultiplePermissionSets(){
        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            List<PermissionSet> permissionSets = createTestPermissionSets(
                new List<String>{'ApexUtilMultiPS1', 'ApexUtilMultiPS2'}
            );

            // Create a user with two permission sets
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{permissionSets[0].Name, permissionSets[1].Name}
            );
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);

            // Check that two permission sets are assigned for the newly created user
            Assert.areEqual(
                2,
                counts.directPermissionSetCount,
                'Expected two permission set assignments'
            );

            Assert.areEqual(
                0,
                counts.permissionSetGroupCount,
                'Expected no permission set group assignments'
            );
        }
        Test.stopTest();
    }


    @IsTest
    static void testCreateUserWithSinglePermissionSetGroup(){
        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            List<PermissionSetGroup> permissionSetGroups = createTestPermissionSetGroups(
                new List<String>{'ApexUtilSinglePSG'}
            );

            // Create a user with one permission set group
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{permissionSetGroups[0].DeveloperName}
            );
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);

            // Check that one permission set group is assigned for the newly created user
            Assert.areEqual(
                1,
                counts.permissionSetGroupCount,
                'Expected one permission set group assignment'
            );

            Assert.areEqual(
                0,
                counts.directPermissionSetCount,
                'Expected no direct permission set assignments'
            );
        }
        Test.stopTest();
    }


    @IsTest
    static void testCreateUserWithMultiplePermissionSetGroups(){
        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            List<PermissionSetGroup> permissionSetGroups = createTestPermissionSetGroups(
                new List<String>{'ApexUtilMultiPSG1', 'ApexUtilMultiPSG2'}
            );

            // Create a user with two permission set groups
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{permissionSetGroups[0].DeveloperName, permissionSetGroups[1].DeveloperName}
            );
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);

            // Check that two permission set groups are assigned for the newly created user
            Assert.areEqual(
                2,
                counts.permissionSetGroupCount,
                'Expected two permission set group assignments'
            );

            Assert.areEqual(
                0,
                counts.directPermissionSetCount,
                'Expected no direct permission set assignments'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateUserWithPermissionSetsAndPermissionSetGroups(){
        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            List<PermissionSet> permissionSets = createTestPermissionSets(
                new List<String>{'ApexUtilMixPS1', 'ApexUtilMixPS2', 'ApexUtilMixPS3'}
            );
            List<PermissionSetGroup> permissionSetGroups = createTestPermissionSetGroups(
                new List<String>{'ApexUtilMixPSG1', 'ApexUtilMixPSG2'}
            );

            // Create a user with mixed permission sets and permission set groups
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{
                    permissionSets[0].Name,
                    permissionSetGroups[0].DeveloperName,
                    permissionSets[1].Name,
                    permissionSetGroups[1].DeveloperName,
                    permissionSets[2].Name
                }
            );
            PermissionAssignmentCounts counts = getPermissionAssignmentCounts(testUser.Id);


            // Check that direct permission set and permission set group assignments are both present
            Assert.areEqual(
                3,
                counts.directPermissionSetCount,
                'Expected three direct permission set assignments'
            );

            Assert.areEqual(
                2,
                counts.permissionSetGroupCount,
                'Expected two permission set group assignments'
            );
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the creation of a test user
     */
    @IsTest
    static void testCreateUserWithDataOverridesWithFieldsAsStrings(){

        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            // Create a user with data overrides
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                new Map<String,Object>{
                    'FirstName'          => 'Henk',
                    'LastName'           => 'de Vries',
                    'ReceivesInfoEmails' => true
                }
            );

            // Check that the custom values on the user record are updated correctly
            Assert.areEqual('Henk',     testUser.FirstName,         'Expected FirstName to be Henk');
            Assert.areEqual('de Vries', testUser.LastName,          'Expected last name to be de Vries');
            Assert.isTrue(              testUser.ReceivesInfoEmails,'Expected ReceivesInfoEmails to be true');
        }
        Test.stopTest();
    }


    /**
     * @description Method to test the creation of a test user
     */
    @IsTest
    static void testCreateUserWithDataOverridesWithFieldsAsSObjectFields(){

        Test.startTest();
        System.runAs(ApexUnitTestUtil.getRunningUser()){
            // Create a user with data overrides
            User testUser = ApexUnitTestUtil.createRunAsUser(
                ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                new Map<SObjectField,Object>{
                    User.FirstName          => 'Henk',
                    User.LastName           => 'de Vries',
                    User.ReceivesInfoEmails => true
                }
            );

            // Check that the custom values on the user record are updated correctly
            Assert.areEqual('Henk',     testUser.FirstName,         'Expected FirstName to be Henk');
            Assert.areEqual('de Vries', testUser.LastName,          'Expected last name to be de Vries');
            Assert.isTrue(              testUser.ReceivesInfoEmails,'Expected ReceivesInfoEmails to be true');
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

            // Invalid field name in the data map
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

            // Invalid field value type in the data map
            try{
                // Create a user with an invalid field
                ApexUnitTestUtil.createRunAsUser(
                    ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                    new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                    new Map<String,Object>{
                        'FirstName' => 'Henk',
                        'LastName'  => 12
                    }
                );

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    'Illegal assignment from Integer to String',
                    e
                );
            }

            // Invalid SObjectField in the data map
            try{
                // Create a user with an invalid field
                ApexUnitTestUtil.createRunAsUser(
                    ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                    new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                    new Map<SObjectField,Object>{
                        User.FirstName => 'Henk',
                        User.LastName  => 'de Vries',
                        Account.Name   => 'Name'
                    }
                );

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    'Account.Name does not belong to SObject type User',
                    e
                );
            }

            // Invalid SObjectField value type in the data map
            try{
                // Create a user with an invalid field
                ApexUnitTestUtil.createRunAsUser(
                    ApexUnitTestUtil.MINIMUM_ACCESS_PROFILE,
                    new String[]{ApexUnitTestUtil.PERMISSION_SET_NAME},
                    new Map<SObjectField,Object>{
                        User.FirstName => 'Henk',
                        User.LastName  => 12
                    }
                );

                // This code should not be reached
                ApexUnitTestUtil.assertExceptionHasBeenThrow();

            }catch(ApexUnitTestUtil.InvalidDataException e){

                // Assert a message with a detailed message inside
                ApexUnitTestUtil.assertExceptionMessage(
                    'Illegal assignment from Integer to String',
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