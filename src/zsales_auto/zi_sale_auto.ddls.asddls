@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for sales auto'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_SALE_AUTO
  as select from ZI_SALES_AUTO_SUM

  association [0..1] to zsales_auto_inp            as _UserInput on  _UserInput.salesorder        = $projection.SalesOrder
                                                                 and _UserInput.salesorderitem    = $projection.SalesOrderItem
                                                                 and $projection.OutboundDelivery = ''

  association [0..1] to I_StockQuantityValueByType as _Stock     on  _Stock.Material                  = $projection.Material
                                                                 and _Stock.Plant                     = $projection.Plant
                                                                 and _Stock.StorageLocation           = $projection.StorageLocation
                                                                 and _Stock.InventoryStockType        = '01'
                                                                 and _Stock.InventorySpecialStockType = ' '
                                                                 and _Stock.MaterialBaseUnit          = $projection.BaseUnit
                                                                 and _Stock.Currency                  = $projection.TransactionCurrency
                                                                 and _Stock.ValuationAreaType         = '1'
  association [0..1] to ZR_MAT_OBD                 as _MatObd    on  _MatObd.Matnr = $projection.Material
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
      coalesce( _UserInput.quantity, Quantity )         as Quantity,
      coalesce( _UserInput.quantityunit, QuantityUnit ) as QuantityUnit,
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
      _Stock.MatlWrhsStkQtyInMatlBaseUnit               as MaterialCurrentStock,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetAmount,
      TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      NetPriceAmount                                    as NetPriceAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'

      //      _rate._rate.rate                                        as ConditionRecordRate,
      cast( '0' as abap.curr( 12, 2 ))                  as ConditionRecordRate,
      CGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CGST_value,
      SGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SGST_value,
      IGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      IGST_value,
      coalesce( _UserInput.route, Route )               as Route,
      case when OutboundDelivery = ''
      then coalesce( _UserInput.vehicleno, cast( '' as abap.char(25) ) )
      else cast( '' as abap.char(25) ) end              as VehicleNo,
      case when OutboundDelivery = ''
      then coalesce( _UserInput.transportername, cast( '' as abap.char(25) ) )
      else cast( '' as abap.char(25) ) end              as TransporterName,
      case when OutboundDelivery = ''
      then coalesce( _UserInput.drivername, cast( '' as abap.char(25) ) )
      else cast( '' as abap.char(25) ) end              as DriverName,
      case when OutboundDelivery = '' //is null
      then coalesce( _UserInput.driverlicenceno, cast( '' as abap.char(25) ) )
      else cast( '' as abap.char(25) ) end              as DriverLicenceNo,
      case when OutboundDelivery = ''
      then coalesce( _UserInput.packingdetails, cast( '' as abap.char(30) ) )
      else cast( '' as abap.char(25) ) end              as PackingDetails,
      case when OutboundDelivery = '' //is null
      then case when _UserInput.forwadingagent = '' or _UserInput.forwadingagent = '0000000000'
           then ForwardingAgentCustomer
           else coalesce( _UserInput.forwadingagent, ForwardingAgentCustomer ) end
      else cast( '' as abap.char(10) ) end              as ForwadingAgent,
      GoodsMovementStatus,
   //   YY1_ablad_SDI, //commented by trupti
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      _MatObd.MaxQty,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      _MatObd.UnitPer

}

union select from zi_sales_auto_addline_sum

association [0..1] to zsales_auto_inp            as _UserInput on  _UserInput.salesorder     = $projection.SalesOrder
                                                               and _UserInput.salesorderitem = $projection.SalesOrderItem

association [0..1] to I_StockQuantityValueByType as _Stock     on  _Stock.Material                  = $projection.Material
                                                               and _Stock.Plant                     = $projection.Plant
                                                               and _Stock.StorageLocation           = $projection.StorageLocation
                                                               and _Stock.InventoryStockType        = '01'
                                                               and _Stock.InventorySpecialStockType = ' '
                                                               and _Stock.MaterialBaseUnit          = $projection.BaseUnit
                                                               and _Stock.Currency                  = $projection.TransactionCurrency
                                                               and _Stock.ValuationAreaType         = '1'

association [0..1] to ZR_MAT_OBD                 as _MatObd    on  _MatObd.Matnr = $projection.Material
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
      ScheduleLineOrderQuantity,
      OrderQuantityUnit,
      DeliveredQuantityInBaseUnit,
      coalesce( _UserInput.quantity, Quantity )                            as Quantity,
      coalesce( _UserInput.quantityunit, QuantityUnit )                    as QuantityUnit,
      BaseUnit,
      SalesOrganization,
      DistributionChannel,
      Division,
      Plant,
      StorageLocation,
      StorageLocationName,
      DeliveryDate,
      OrderQuantity,
      _Stock.MatlWrhsStkQtyInMatlBaseUnit                                  as MaterialCurrentStock,
      NetAmount,
      TransactionCurrency,
      NetPriceAmount                                                       as NetPriceAmount,
      cast('0' as abap.curr( 12, 2 ))                                      as ConditionRecordRate,
      //      _rate.rate                                                    as ConditionRecordRate,
      CGST_rate,
      CGST_value,
      SGST_rate,
      SGST_value,
      IGST_rate,
      IGST_value,
      coalesce( _UserInput.route, Route )                                  as Route,
      coalesce( _UserInput.vehicleno, cast( '' as abap.char(25) ) )        as VehicleNo,
      coalesce( _UserInput.transportername, cast( '' as abap.char(25) ) )  as TransporterName,
      coalesce( _UserInput.drivername, cast( '' as abap.char(25) ) )       as DriverName,
      coalesce( _UserInput.driverlicenceno, cast( '' as abap.char(25) ) )  as DriverLicenceNo,
      coalesce( _UserInput.packingdetails, cast( '' as abap.char(30) ) )   as PackingDetails,
      case when _UserInput.forwadingagent = '' or _UserInput.forwadingagent = '0000000000'
           then ForwardingAgent
           else coalesce( _UserInput.forwadingagent, ForwardingAgent ) end as ForwadingAgent,
      GoodsMovementStatus,
//      YY1_ablad_SDI,//commented by trupti
      _MatObd.MaxQty,
      _MatObd.UnitPer
}
