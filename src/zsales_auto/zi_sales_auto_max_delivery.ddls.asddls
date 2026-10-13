@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View to get max delivery'
@Metadata.ignorePropagatedAnnotations: true

define view entity zi_sales_auto_max_delivery
  as select from    I_SalesDocument        as SO
    inner join      I_SalesDocumentItem    as SOItem        on SOItem.SalesDocument = SO.SalesDocument
    left outer join I_OutboundDeliveryItem as _DeliveryItem on  _DeliveryItem.ReferenceSDDocument     = SOItem.SalesDocument
                                                            and _DeliveryItem.ReferenceSDDocumentItem = SOItem.SalesDocumentItem

{
  key SO.SalesDocument, //Added by Sukhwinder on 03.11.2025
//  SO.SalesDocument //Commented by Sukhwinder on 03.11.2025
  max( _DeliveryItem.OutboundDelivery ) as maxOutboundDelivery
}
group by
  SO.SalesDocument
