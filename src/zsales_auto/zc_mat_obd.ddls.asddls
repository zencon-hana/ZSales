@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZMAT_OBD'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_MAT_OBD
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_MAT_OBD
  association [1..1] to ZR_MAT_OBD as _BaseEntity on $projection.MATNR = _BaseEntity.MATNR
{
  key Matnr,
  Maktx,
  @Semantics: {
    Quantity.Unitofmeasure: 'Meins'
  }
  UnitPer,
  @Semantics: {
    Quantity.Unitofmeasure: 'Meins'
  }
  MaxQty,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'UnitOfMeasure', 
      Entity.Name: 'I_UnitOfMeasureStdVH', 
      Useforvalidation: true
    } ]
  }
  Meins,
  @Semantics: {
    User.Createdby: true
  }
  Creteduser,
  @Semantics: {
    User.Lastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
