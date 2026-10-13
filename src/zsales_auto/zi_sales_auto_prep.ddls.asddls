@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view before root of sales auto'
@Metadata.ignorePropagatedAnnotations: true

define view entity zi_sales_auto_prep
  as select from ZI_SALE_AUTO
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
      ScheduleLineOrderQuantity,
      OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      DeliveredQuantityInBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      Quantity,
      QuantityUnit,
      BaseUnit,
      SalesOrganization,
      DistributionChannel,
      Division,
      Plant,
      StorageLocation,
      StorageLocationName,
      DeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      MaterialCurrentStock,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( ( cast( NetPriceAmount as abap.dec(11,2) ) * Quantity ) as abap.curr( 15, 2 ) )                                                                   as NetAmount,
      //      NetAmount,
      TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetPriceAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ConditionRecordRate,
      CGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( ( cast( ( cast( NetPriceAmount as abap.dec(11,2) ) * Quantity ) as abap.dec( 15, 2 ) ) * division( CGST_rate, 100, 2 )  ) as abap.curr( 11, 2 ) ) as CGST_value,
      SGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( ( cast( ( cast( NetPriceAmount as abap.dec(11,2) ) * Quantity ) as abap.dec( 15, 2 ) ) * division( SGST_rate, 100, 2 )  ) as abap.curr( 11, 2 ) ) as SGST_value,
      IGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( ( cast( ( cast( NetPriceAmount as abap.dec(11,2) ) * Quantity ) as abap.dec( 15, 2 ) ) * division( IGST_rate, 100, 2 )  ) as abap.curr( 11, 2 ) ) as IGST_value,
      Route,
      VehicleNo,
      TransporterName,
      DriverName,
      DriverLicenceNo,
      PackingDetails,
      ForwadingAgent,
      GoodsMovementStatus,
//      YY1_ablad_SDI,//commeneted by trupti
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      MaxQty,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      UnitPer
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
  ScheduleLineOrderQuantity,
  OrderQuantityUnit,
  DeliveredQuantityInBaseUnit,
  Quantity,
  QuantityUnit,
  BaseUnit,
  SalesOrganization,
  DistributionChannel,
  Division,
  Plant,
  StorageLocation,
  StorageLocationName,
  DeliveryDate,
  OrderQuantity,
  MaterialCurrentStock,
  NetAmount,
  TransactionCurrency,
  NetPriceAmount,
  ConditionRecordRate,
  CGST_rate,
  CGST_value,
  SGST_rate,
  SGST_value,
  IGST_rate,
  IGST_value,
  Route,
  VehicleNo,
  TransporterName,
  DriverName,
  DriverLicenceNo,
  PackingDetails,
  ForwadingAgent,
  GoodsMovementStatus,
  //YY1_ablad_SDI,//commented by trupti
  MaxQty,
  UnitPer
