@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for sales auto additional line'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_sales_auto_addline
  as select from I_SalesDocumentItem as SOItem

  association [0..1] to C_BOMMaterialVH as _Material  on  _Material.Product = SOItem.Product  //Added by Sukhwinder on 03.11.2025
//  association [0..1] to C_BOMMaterialVH as _Material  on  _Material.Product = SOItem.Product //Commented by Sukhwinder on 03.11.2025

  association [0..1] to zsales_auto_inp as _UserInput on  _UserInput.salesorder     = $projection.SalesOrder
                                                      and _UserInput.salesorderitem = $projection.SalesOrderItem

{
  key SOItem.SalesDocument                                                                                                as SalesOrder,
  key SOItem.SalesDocumentItem                                                                                            as SalesOrderItem,
  key coalesce( SOItem._ScheduleLine.ScheduleLine, '0000' )                                                               as ScheduleLine,
  key cast( '' as abap.char(10) )                                                                                         as OutboundDelivery,
  key cast( '000000' as abap.numc( 6 ) )                                                                                  as OutboundDeliveryItem,
  key cast( '' as abap.char(10) )                                                                                         as BillingDocument,
  key cast( '000000' as abap.numc( 6 ) )                                                                                  as BillingDocumentItem,
      SOItem.MaterialByCustomer,
      SOItem.Product                                                                                                      as Material,
      _Material.MaterialDescription,
      SOItem._SalesDocument.SalesDocumentType                                                                             as SalesOrderType,
      //    _SalesOrder.SoldToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'WE' ].Partner                                                  as ShipToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].FullName                                                 as ShipToPartyName,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].Partner                                                  as SoldToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].FullName                                                 as SoldToPartyName,
      SOItem.Batch,
      SOItem.ShippingPoint,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SOItem._ScheduleLine.ScheduleLineOrderQuantity,
      SOItem._ScheduleLine.OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      SOItem._ScheduleLine.DeliveredQuantityInBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit                                                                     as Quantity,
      SOItem._ScheduleLine.OrderQuantityUnit                                                                              as QuantityUnit,

      SOItem._ScheduleLine.BaseUnit,
      SOItem._SalesDocument.SalesOrganization,
      SOItem._SalesDocument.DistributionChannel,
      SOItem._SalesDocument.OrganizationDivision                                                                          as Division,
      SOItem.Plant,
      SOItem.StorageLocation,
      SOItem._StorageLocation.StorageLocationName,
      SOItem._ScheduleLine.DeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SOItem.OrderQuantity,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem.NetAmount,
      SOItem.TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem.NetPriceAmount,
      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionRateValue                                                as CGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionAmount                                                   as CGST_value,
      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionRateValue                                                as SGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionAmount                                                   as SGST_value,
      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionRateValue                                                as IGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionAmount                                                   as IGST_value,
      coalesce( _UserInput.route, SOItem.Route)                                                                           as Route,
      coalesce( _UserInput.vehicleno, cast( '' as abap.char(25) ) )                                                       as VehicleNo,
      case when _UserInput.forwadingagent = '' or _UserInput.forwadingagent = '0000000000'
      then SOItem._SalesDocument._Partner[1: PartnerFunction = 'SP' ].Supplier
      else coalesce( _UserInput.forwadingagent, SOItem._SalesDocument._Partner[1: PartnerFunction = 'SP' ].Supplier ) end as ForwardingAgent,
      cast( '' as abap.char(1))                                                                                           as GoodsMovementStatus
//      SOItem.YY1_ablad_SDI //commenetd by trupti
}

//  as select from I_SalesOrderItem as SOItem
//
//  association [0..1] to C_BOMMaterialVH     as _Material  on  _Material.Product = SOItem.Product
//
//  association [0..1] to zsales_auto_inp     as _UserInput on  _UserInput.salesorder     = $projection.SalesOrder
//                                                          and _UserInput.salesorderitem = $projection.SalesOrderItem
//
//  association [0..1] to I_SalesDocumentItem as _SODocItem on  _SODocItem.SalesDocument     = SOItem.SalesOrder
//                                                          and _SODocItem.SalesDocumentItem = SOItem.SalesOrderItem
//{
//  key SOItem.SalesOrder,
//  key SOItem.SalesOrderItem,
//  key coalesce( SOItem._ScheduleLine.ScheduleLine, '0000' )                as ScheduleLine,
//  key cast( '' as abap.char(10) )                                          as OutboundDelivery,
//  key cast( '000000' as abap.numc( 6 ) )                                   as OutboundDeliveryItem,
//  key cast( '' as abap.char(10) )                                          as BillingDocument,
//  key cast( '000000' as abap.numc( 6 ) )                                   as BillingDocumentItem,
//      SOItem.MaterialByCustomer,
//      SOItem.Product                                                       as Material,
//      _Material.MaterialDescription,
//      SOItem._SalesOrder.SalesOrderType,
//      //    _SalesOrder.SoldToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'WE' ].Partner      as ShipToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].FullName     as ShipToPartyName,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].Partner      as SoldToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].FullName     as SoldToPartyName,
//      SOItem.Batch,
//      SOItem.ShippingPoint,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//      SOItem._ScheduleLine.ScheduleLineOrderQuantity,
//      SOItem._ScheduleLine.OrderQuantityUnit,
//      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
//      SOItem._ScheduleLine.DeliveredQuantityInBaseUnit,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit,
//      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
//      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit                      as Quantity,
//      SOItem._ScheduleLine.OrderQuantityUnit                               as QuantityUnit,
//
//      SOItem._ScheduleLine.BaseUnit,
//      SOItem._SalesOrder.SalesOrganization,
//      SOItem._SalesOrder.DistributionChannel,
//      SOItem._SalesOrder.OrganizationDivision                              as Division,
//      SOItem.Plant,
//      SOItem.StorageLocation,
//      SOItem._StorageLocation.StorageLocationName,
//      SOItem._ScheduleLine.DeliveryDate,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//      SOItem.OrderQuantity,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem.NetAmount,
//      SOItem.TransactionCurrency,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem.NetPriceAmount,
//      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionRateValue as CGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionAmount    as CGST_value,
//      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionRateValue as SGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionAmount    as SGST_value,
//      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionRateValue as IGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionAmount    as IGST_value,
//      coalesce( _UserInput.route, SOItem.Route)                            as Route,
//      coalesce( _UserInput.vehicleno, cast( '' as abap.char(25) ) )        as VehicleNo,
//      cast( '' as abap.char(1))                                            as GoodsMovementStatus,
//      _SODocItem.YY1_ablad_SDI
//}
