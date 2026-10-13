@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for sale automation'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SALE_AUTO_P
  provider contract transactional_query
  as projection on ZC_SALE_AUTO
{
          //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrder', element: 'SalesOrder' } }]
  key     SalesOrder,
  key     SalesOrderItem,

          @Consumption.valueHelpDefinition: [{ entity: { name: 'I_OutboundDelivery', element: 'OutboundDelivery' } }]
  key     OutboundDelivery,
  key     OutboundDeliveryItem,

          @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BillingDocument', element: 'BillingDocument' } }]
  key     BillingDocument,
  key     BillingDocumentItem,
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
          @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
          ScheduleLineOrderQuantity,
          OrderQuantityUnit,
          @Semantics.quantity.unitOfMeasure: 'BaseUnit'
          DeliveredQuantityInBaseUnit,
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          //      DeliveredQtyInOrderQtyUnit,
          Quantity,
          QuantityUnit,
          BaseUnit,
          SalesOrganization,
          DistributionChannel,
          Division,
          Plant,
          StorageLocation,
          StorageLocationName,
          @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
          OrderQuantity,
          @EndUserText.label: 'Current stock'
          @Semantics.quantity.unitOfMeasure: 'BaseUnit'
          MaterialCurrentStock,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          NetAmount,
          TransactionCurrency,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          @EndUserText.label: 'SO rate'
          NetPriceAmount,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          //      @EndUserText.label: 'Condition record rate'
          //      ConditionRecordRate,
          @EndUserText.label: 'CGST rate'
          CGST_rate,
          @EndUserText.label: 'CGST value'
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          CGST_value,
          @EndUserText.label: 'SGST rate'
          SGST_rate,
          @EndUserText.label: 'SGST value'
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          SGST_value,
          @EndUserText.label: 'IGST rate'
          IGST_rate,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          IGST_value,
          Route,
          VehicleNo,
          TransporterName,
          DriverName,
          DriverLicenceNo,
          PackingDetails,
          @EndUserText.label: 'Forwarding agent'
          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_BusinessPartnerIndustryVH', element: 'BusinessPartner' } }]
          ForwadingAgent,
          GoodsMovementStatus,
          //YY1_ablad_SDI,//commented by trupti
          @EndUserText.label: 'Condition record rate'
          @Semantics.amount.currencyCode: 'TransactionCurrency'
//          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_QUERY_COND_RECORD_RATE'
  virtual VirCondRate : abap.curr(10,2),
          @EndUserText.label: 'Maximum Allow quantity'
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          MaxQty,
          @EndUserText.label: 'Multiplier Quantity'
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          UnitPer

} where OrderQuantity > 0
