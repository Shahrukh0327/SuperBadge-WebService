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
@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {
  @HttpPut
  global static String reportLostDevice(String assetIdentifier) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<Asset> assetRec = [
      SELECT Id, Status
      FROM Asset
      WHERE Asset_Identifier__c = :assetIdentifier
      LIMIT 1
    ];

    if (assetRec.isEmpty()) {
      return 'No device found.';
    }
    List<Insurance__c> insuranceRec = [
      SELECT Id, Asset__c
      FROM Insurance__c
      WHERE
        Asset__c = :assetRec[0].Id
        AND Coverage__c = 'Comprehensive'
        AND Active__c = TRUE
      LIMIT 1
    ];

    if (insuranceRec.isEmpty()) {
      // If No coverage found, Still update Assets.
      assetRec[0].Status = 'Lost';
      update assetRec[0];
      return 'No coverage. Asset status adjusted to Lost.';
    }

    List<Claim__c> checkClaimFiled = [
      SELECT Id, Name
      FROM Claim__c
      WHERE Insurance__c = :insuranceRec[0].Id AND Type__c = 'Loss'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    if (!checkClaimFiled.isEmpty()) {
      return checkClaimFiled[0].Name + 'already filed';
    }

    // Set Claim field
    Claim__c claimRec = new Claim__c();
    claimRec.Asset__c = assetRec[0].Id;
    claimRec.Insurance__c = insuranceRec[0].Id;
    claimRec.Type__c = 'Loss';

    //Insert Claim record
    Database.insert(claimRec, AccessLevel.SYSTEM_MODE);

    //Update Asset Status=Lost
    assetRec[0].Status = 'Lost';
    update assetRec[0];
    Claim__c claimUpdated = [
      SELECT Id, Name
      FROM Claim__c
      WHERE Insurance__c = :insuranceRec[0].Id AND Type__c = 'Loss'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    return claimUpdated.Name;
  }
}
