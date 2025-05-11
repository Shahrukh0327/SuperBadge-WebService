/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 05-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   05-07-2025   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {
  @HttpGet
  global static String getPermissibleFlyZone() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String message = '';
    List<Product_Geo_Mapping__mdt> geoMapping = new List<Product_Geo_Mapping__mdt>();
    String countryCode = req.headers.get('CountryCode');
    if (String.isEmpty(countryCode)) {
      countryCode = 'US';
    }
    String productCode = req.params.get('ProductCode');

    if (String.isEmpty(productCode)) {
      return 'ProductCode is missing or doesn\'t exist';
    }
    List<Product2> prod = [
      SELECT Id, Family
      FROM Product2
      WHERE ProductCode = :productCode
      LIMIT 1
    ];

    if (prod.isEmpty()) {
      return 'ProductCode is missing or doesn\'t exist';
    }
    Product2 product = prod[0];
    geoMapping = [
      SELECT Id, Permissible_Fly_Zone__c
      FROM Product_Geo_Mapping__mdt
      WHERE
        Product_Family__c = :product.Family
        AND Country_Code__c = :countryCode
      LIMIT 1
    ];

    if (!geoMapping.isEmpty()) {
      return geoMapping[0].Permissible_Fly_Zone__c;
    } else {
      return 'Confirm with the local authorities';
    }
  }
}
