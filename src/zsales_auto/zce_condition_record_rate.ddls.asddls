@EndUserText.label: 'Travel data custom entity from PRV'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_COND_RECORD_RATE'

define custom entity ZCE_CONDITION_RECORD_RATE

{

      @UI.lineItem        : [ { position: 10 } ]
  key SalesOrganization   : vkorg;
  key DistributionChannel : vtweg;
  key SoldToParty         : kunag;
  key SalesOrderType      : auart;
  key material            : matnr;
  key yy1_ablad_sdi       : abap.char( 4 );
      @Semantics.amount.currencyCode: 'currencycode'
      rate                : abap.curr( 12, 2 );
      currencycode        : kwaeh;
}
