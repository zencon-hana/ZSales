@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZMAT_OBD'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_MAT_OBD
  as select from ZMAT_OBD
{
  key matnr as Matnr,
  maktx as Maktx,
  @Semantics.quantity.unitOfMeasure: 'Meins'
  unit_per as UnitPer,
  @Semantics.quantity.unitOfMeasure: 'Meins'
  max_qty as MaxQty,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  meins as Meins,
  @Semantics.user.createdBy: true
  creteduser as Creteduser,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
