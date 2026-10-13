@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales auto sum values cds'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SALES_AUTO_SUM
  as select from ZI_SALES_AUTO_BASE
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
      ForwardingAgentCustomer,
      Batch,
      ShippingPoint,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum( ScheduleLineOrderQuantity )   as ScheduleLineOrderQuantity,
      OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      sum( DeliveredQuantityInBaseUnit ) as DeliveredQuantityInBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      case when OutboundDelivery is null
      then sum( Quantity )
      else max( Quantity ) end           as Quantity,
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
      max( OrderQuantity )               as OrderQuantity,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( NetAmount )                   as NetAmount,
      TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      max( NetPriceAmount )              as NetPriceAmount,
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
      GoodsMovementStatus
//      YY1_ablad_SDI //commented by trupti
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
  ForwardingAgentCustomer,
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
  TransactionCurrency,
  CGST_rate,
  CGST_value,
  SGST_rate,
  SGST_value,
  IGST_rate,
  IGST_value,
  Route,
  GoodsMovementStatus
//  YY1_ablad_SDI commented by trupti
