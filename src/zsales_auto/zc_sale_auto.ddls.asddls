@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view of sales auto'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SALE_AUTO
  as select from zi_sales_auto_prep
{
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrder', element: 'SalesOrder' } }]
  key SalesOrder,
  key SalesOrderItem,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_OutboundDelivery', element: 'OutboundDelivery' } }]
  key OutboundDelivery,
  key OutboundDeliveryItem,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BillingDocument', element: 'BillingDocument' } }]
  key BillingDocument,
  key BillingDocumentItem,
      MaterialByCustomer,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'C_BOMMaterialVH', element: 'Material' } }]
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
      @EndUserText.label: 'Quantity'
      Quantity,
      @EndUserText.label: 'Label'
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
      NetAmount,
      TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetPriceAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ConditionRecordRate,
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
      @EndUserText.label: 'Vehicle No'
      VehicleNo,
      @EndUserText.label: 'Transporter Name'
      TransporterName,
      @EndUserText.label: 'Driver Name'
      DriverName,
      @EndUserText.label: 'Driver Licence No'
      DriverLicenceNo,
      @EndUserText.label: 'Packing Details'
      PackingDetails,
      @EndUserText.label: 'Forwading Agent'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_BusinessPartnerIndustryVH', element: 'BusinessPartner' } }]
      ForwadingAgent,
      GoodsMovementStatus,
//      YY1_ablad_SDI,//commented by trupti
      @EndUserText.label: 'Maximum Allow Quantity'
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      MaxQty,
      @EndUserText.label: 'Multiplier Quantity'
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
//  YY1_ablad_SDI,//commeneted by trupti
  MaxQty,
  UnitPer

