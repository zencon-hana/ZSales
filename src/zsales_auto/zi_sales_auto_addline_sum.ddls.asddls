@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'view for sales auto addline sum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_sales_auto_addline_sum
  as select from zi_sales_auto_addline
{
  key SalesOrder,
  key SalesOrderItem,
  key OutboundDelivery,
  key OutboundDeliveryItem,
  key BillingDocument,
  key BillingDocumentItem,
      MaterialByCustomer,
      Material,
      MaterialDescription,
      SalesOrderType,
      ShipToParty,
      ShipToPartyName,
      SoldToParty,
      SoldToPartyName,
      Batch,
      ShippingPoint,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum( ScheduleLineOrderQuantity )   as ScheduleLineOrderQuantity,
      OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum( DeliveredQuantityInBaseUnit ) as DeliveredQuantityInBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      sum( Quantity )                    as Quantity,
      QuantityUnit,
      BaseUnit,
      SalesOrganization,
      DistributionChannel,
      Division,
      Plant,
      StorageLocation,
      StorageLocationName,
      max( DeliveryDate )                as DeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetAmount,
      TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetPriceAmount,
      CGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CGST_value,
      SGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SGST_value,
      IGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      IGST_value,
      Route,
      VehicleNo,
      ForwardingAgent,
      GoodsMovementStatus
//      YY1_ablad_SDI// commeneted by trupti
}
group by
  SalesOrder,
  SalesOrderItem,
  OutboundDelivery,
  OutboundDeliveryItem,
  BillingDocument,
  BillingDocumentItem,
  MaterialByCustomer,
  Material,
  MaterialDescription,
  SalesOrderType,
  ShipToParty,
  ShipToPartyName,
  SoldToParty,
  SoldToPartyName,
  Batch,
  ShippingPoint,
  OrderQuantityUnit,
  QuantityUnit,
  BaseUnit,
  SalesOrganization,
  DistributionChannel,
  Division,
  Plant,
  StorageLocation,
  StorageLocationName,
  OrderQuantity,
  NetAmount,
  TransactionCurrency,
  NetPriceAmount,
  CGST_rate,
  CGST_value,
  SGST_rate,
  SGST_value,
  IGST_rate,
  IGST_value,
  Route,
  VehicleNo,
  ForwardingAgent,
  GoodsMovementStatus
//  YY1_ablad_SDI //commented by trupti
