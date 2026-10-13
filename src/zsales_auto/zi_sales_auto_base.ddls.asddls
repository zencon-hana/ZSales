@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for sales auto'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_SALES_AUTO_BASE
  as select from    I_SalesDocumentItem        as SOItem
    left outer join zi_sales_auto_max_delivery as _max_delivery on  _max_delivery.SalesDocument       =  SOItem.SalesDocument
                                                                and _max_delivery.maxOutboundDelivery <> ''
    left outer join I_OutboundDeliveryItem     as _DeliveryItem on  _DeliveryItem.ReferenceSDDocument     = SOItem.SalesDocument
                                                                and _DeliveryItem.ReferenceSDDocumentItem = SOItem.SalesDocumentItem
                                                                and _DeliveryItem.OutboundDelivery        = _max_delivery.maxOutboundDelivery

    left outer join I_BillingDocumentItem      as _BillingItem  on  _BillingItem.ReferenceSDDocument     = _DeliveryItem.OutboundDelivery
                                                                and _BillingItem.ReferenceSDDocumentItem = _DeliveryItem.OutboundDeliveryItem

    association [0..*] to C_BOMMaterialVH as _Material on _Material.Product = SOItem.Product //Added by Sukhwinder on 03.11.2025
//  association [0..1] to C_BOMMaterialVH as _Material on _Material.Product = SOItem.Product //Commented by Sukhwinder on 03.11.2025


{
  key SOItem.SalesDocument                                                                              as SalesOrder,
  key SOItem.SalesDocumentItem                                                                          as SalesOrderItem,
  key coalesce( SOItem._ScheduleLine.ScheduleLine, '0000' )                                             as ScheduleLine,
  key coalesce( _DeliveryItem.OutboundDelivery, '' )                                                    as OutboundDelivery,
  key coalesce( _DeliveryItem.OutboundDeliveryItem, '000000' )                                          as OutboundDeliveryItem,
  key coalesce( _BillingItem.BillingDocument, '' )                                                      as BillingDocument,
  key coalesce( _BillingItem.BillingDocumentItem, '000000' )                                            as BillingDocumentItem,
      SOItem.MaterialByCustomer,
      SOItem.Product                                                                                    as Material,
      _Material.MaterialDescription,
      SOItem._SalesDocument.SalesDocumentType                                                           as SalesOrderType,
      //    _SalesOrder.SoldToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'WE' ].Partner                                as ShipToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].FullName                               as ShipToPartyName,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].Partner                                as SoldToParty,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'AG' ].FullName                               as SoldToPartyName,
      SOItem._SalesDocument._Partner[1: PartnerFunction = 'SP' ].Supplier                               as ForwardingAgentCustomer,
      SOItem.Batch,
      SOItem.ShippingPoint,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SOItem._ScheduleLine.ScheduleLineOrderQuantity,
      SOItem._ScheduleLine.OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      SOItem._ScheduleLine.DeliveredQuantityInBaseUnit                                                  as DeliveredQuantityInBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      coalesce( _DeliveryItem.ActualDeliveryQuantity, SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit ) as Quantity,
      SOItem._ScheduleLine.OrderQuantityUnit                                                            as QuantityUnit,

      SOItem._ScheduleLine.BaseUnit,
      SOItem._SalesDocument.SalesOrganization,
      SOItem._SalesDocument.DistributionChannel,
      SOItem._SalesDocument.OrganizationDivision                                                        as Division,
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
      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionRateValue                              as CGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionAmount                                 as CGST_value,
      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionRateValue                              as SGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionAmount                                 as SGST_value,
      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionRateValue                              as IGST_rate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionAmount                                 as IGST_value,
      coalesce( _DeliveryItem._OutboundDelivery.ProposedDeliveryRoute, SOItem.Route)                    as Route,
      coalesce( _DeliveryItem.GoodsMovementStatus, '' )                                                 as GoodsMovementStatus
//      SOItem.YY1_ablad_SDI //commented by trupti
} where _BillingItem.SalesDocumentItemCategory != 'CB99'
//  as select from    I_SalesOrderItem           as SOItem
//    left outer join zi_sales_auto_max_delivery as _max_delivery on  _max_delivery.SalesDocument       =  SOItem.SalesOrder
//                                                                and _max_delivery.maxOutboundDelivery <> ''
//    left outer join I_OutboundDeliveryItem     as _DeliveryItem on  _DeliveryItem.ReferenceSDDocument     = SOItem.SalesOrder
//                                                                and _DeliveryItem.ReferenceSDDocumentItem = SOItem.SalesOrderItem
//                                                                and _DeliveryItem.OutboundDelivery        = _max_delivery.maxOutboundDelivery
//
//    left outer join I_BillingDocumentItem      as _BillingItem  on  _BillingItem.ReferenceSDDocument     = _DeliveryItem.OutboundDelivery
//                                                                and _BillingItem.ReferenceSDDocumentItem = _DeliveryItem.OutboundDeliveryItem
//
//
//
//  association [0..1] to C_BOMMaterialVH     as _Material  on  _Material.Product = SOItem.Product
//
//  association [0..1] to I_SalesDocumentItem as _SODocItem on  _SODocItem.SalesDocument     = SOItem.SalesOrder
//                                                          and _SODocItem.SalesDocumentItem = SOItem.SalesOrderItem
//
//{
//  key SOItem.SalesOrder,
//  key SOItem.SalesOrderItem,
//  key coalesce( SOItem._ScheduleLine.ScheduleLine, '0000' )                                             as ScheduleLine,
//  key coalesce( _DeliveryItem.OutboundDelivery, '' )                                                    as OutboundDelivery,
//  key coalesce( _DeliveryItem.OutboundDeliveryItem, '000000' )                                          as OutboundDeliveryItem,
//  key coalesce( _BillingItem.BillingDocument, '' )                                                      as BillingDocument,
//  key coalesce( _BillingItem.BillingDocumentItem, '000000' )                                            as BillingDocumentItem,
//      SOItem.MaterialByCustomer,
//      SOItem.Product                                                                                    as Material,
//      _Material.MaterialDescription,
//      SOItem._SalesOrder.SalesOrderType,
//      //    _SalesOrder.SoldToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'WE' ].Partner                                   as ShipToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].FullName                                  as ShipToPartyName,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].Partner                                   as SoldToParty,
//      SOItem._SalesOrder._Partner[1: PartnerFunction = 'AG' ].FullName                                  as SoldToPartyName,
//      SOItem.Batch,
//      SOItem.ShippingPoint,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//      SOItem._ScheduleLine.ScheduleLineOrderQuantity,
//      SOItem._ScheduleLine.OrderQuantityUnit,
//      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
//      SOItem._ScheduleLine.DeliveredQuantityInBaseUnit                                                  as DeliveredQuantityInBaseUnit,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//      SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit,
//      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
//      coalesce( _DeliveryItem.ActualDeliveryQuantity, SOItem._ScheduleLine.DeliveredQtyInOrderQtyUnit ) as Quantity,
//      SOItem._ScheduleLine.OrderQuantityUnit                                                            as QuantityUnit,
//
//      SOItem._ScheduleLine.BaseUnit,
//      SOItem._SalesOrder.SalesOrganization,
//      SOItem._SalesOrder.DistributionChannel,
//      SOItem._SalesOrder.OrganizationDivision                                                           as Division,
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
//      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionRateValue                              as CGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOCG'].ConditionAmount                                 as CGST_value,
//      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionRateValue                              as SGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOSG'].ConditionAmount                                 as SGST_value,
//      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionRateValue                              as IGST_rate,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      SOItem._PricingElement[1: ConditionType = 'JOIG'].ConditionAmount                                 as IGST_value,
//      coalesce( _DeliveryItem._OutboundDelivery.ProposedDeliveryRoute, SOItem.Route)                    as Route,
//      coalesce( _DeliveryItem.GoodsMovementStatus, '' )                                                 as GoodsMovementStatus,
//      _SODocItem.YY1_ablad_SDI
//}
