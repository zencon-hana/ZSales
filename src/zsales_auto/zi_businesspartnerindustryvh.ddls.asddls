@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for business partner'
@Metadata.ignorePropagatedAnnotations: true 
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BusinessPartnerIndustryVH
  as select from I_BusinessPartnerIndustry
  //  association [1..1] to I_Industrykeysystemtexts as _Text on  $projection.IndustrySystemType = _Text.IndustrySystemType
  //                                                            and $projection.IndustrySector = _Text.IndustrySector
  //                                                            and _Text.Language = $session.system_language
  //    association [0..1] to I_BusPartIndustrySystem  as _BusPartIndustrySystem on  $projection.IndustrySystemType = _BusPartIndustrySystem.IndustrySystemType
{


      @ObjectModel.foreignKey.association: '_BusinessPartner'
  key BusinessPartner ,//as businesspartner,
      IndustrySector,
      @ObjectModel.foreignKey.association:'_BusPartIndustrySystem'
      IndustrySystemType,
      IsStandardIndustry,
      IndustryKeyDescription,
      /* Associations */
      _BusinessPartner,
      _Text,
      _BusPartIndustrySystem
}
where
      IndustrySector     = '43'
  and IndustrySystemType = '0001'
