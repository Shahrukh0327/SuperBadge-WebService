/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 05-10-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   05-10-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
global with sharing class CredentialVerificationService {
  webService static String verifyCredential(
    String lastName,
    String certificationName
  ) {
    List<Contact> cont = [
      SELECT Id, Name
      FROM Contact
      WHERE LastName = :lastName
      LIMIT 1
    ];
    if (cont.isEmpty()) {
      return 'No record found';
    }

    List<Contact_Certification__c> certification = [
      SELECT Id, Name, isActive__c
      FROM Contact_Certification__c
      WHERE Contact__c = :cont[0].Id AND Name = :certificationName
      LIMIT 1
    ];

    if (certification.isEmpty()) {
      return 'No record found';
    }
    if (certification[0].isActive__c) {
      return 'Valid';
    } else {
      return 'Needs Renewal';
    }
  }
}
