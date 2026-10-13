CLASS zcl_query_cond_record_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_rap_query_provider,
      if_sadl_exit_calc_element_read.
    CLASS-METHODS: get_conditionRateValue
      IMPORTING iv_material                  TYPE zc_sale_auto_p-material
                iv_salesorganization         TYPE zc_sale_auto_p-salesorganization
                iv_soldtoparty               TYPE zc_sale_auto_p-soldtoparty
                iv_distributionchannel       TYPE zc_sale_auto_p-distributionchannel
                iv_salesordertype            TYPE zc_sale_auto_p-salesordertype
                iv_division                  type zc_sale_auto_p-Division
*                iv_yy1_ablad_sdi             TYPE zc_sale_auto_p-yy1_ablad_sdi
      RETURNING VALUE(rv_conditionratevalue) TYPE zc_sale_auto_p-VirCondRate.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_QUERY_COND_RECORD_RATE IMPLEMENTATION.


  METHOD get_conditionRateValue.
    DATA: lt_request       TYPE TABLE FOR FUNCTION IMPORT i_slsprcgconditionrecordtp_2~getconditionrecord.
    lt_request = VALUE #( ( %cid = 'Test1'
                                %param = VALUE #( conditionvaliditystartdate = '20230101'
                                                  conditionvalidityenddate = '99991231'
                                                  deltdconditionrecordisexcluded = 'X'

                                                  _conditionrecordcriteriaitem = VALUE #( ( _conditiontype = VALUE #( ( pricingconditiontyperangesign = 'I' prcgconditiontyperangeoption = 'EQ' pricingconditiontyperangelow = 'ZR00' ) )
                                                  _conditiontable = VALUE #( ( pricingconditiontablerangesign = 'I' prcgconditiontablerangeoption = 'EQ' pricingconditiontablerangelow = '630' )
                                                                             ( pricingconditiontablerangesign = 'I' prcgconditiontablerangeoption = 'EQ' pricingconditiontablerangelow = '630' ) )

                                                 _conditionfield = VALUE #(
                                                 ( prcgconditionfieldrangename = 'MATERIAL'            prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_material )
                                                 ( prcgconditionfieldrangename = 'SALESORGANIZATION'   prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_salesorganization )
                                                 ( prcgconditionfieldrangename = 'CUSTOMER'            prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_soldtoparty )
                                                 ( prcgconditionfieldrangename = 'DISTRIBUTIONCHANNEL' prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_distributionchannel )
                                                 ( prcgconditionfieldrangename = 'SALESDOCUMENTTYPE'   prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_salesordertype )
                                                 ( prcgconditionfieldrangename = 'DIVISION'            prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_division )
*                                                 ( prcgconditionfieldrangename = 'YY1_ABLAD_PCI'       prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = iv_yy1_ablad_sdi  )
                                                 ) ) ) ) ) ).
    READ ENTITIES OF i_slsprcgconditionrecordtp_2
       ENTITY salespricingconditionrecord
       EXECUTE getconditionrecord
       FROM lt_request

       RESULT DATA(lt_result)
       FAILED DATA(ls_failed)
       REPORTED DATA(ls_reported).
    SORT lt_result DESCENDING BY %param-ConditionRecord.
    DELETE lt_result WHERE %param-ConditionValidityEndDate NE '99991231'.
    IF lt_result IS NOT INITIAL.
      rv_conditionratevalue = lt_result[ 1 ]-%param-ConditionRateValue.
    ENDIF.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: it_result TYPE TABLE OF zce_condition_record_rate.

    IF io_request->is_data_requested( ).

      DATA: lt_request  TYPE TABLE FOR FUNCTION IMPORT i_slsprcgconditionrecordtp_2~getconditionrecord,
            lt_request1 TYPE TABLE FOR FUNCTION IMPORT i_slsprcgconditionrecordtp_2~getconditionrecord,
            lt_request2 TYPE TABLE FOR FUNCTION IMPORT i_slsprcgconditionrecordtp_2~getconditionrecord,
            lt_result   TYPE TABLE FOR FUNCTION RESULT i_slsprcgconditionrecordtp_2~getconditionrecord,
            ls_reported TYPE RESPONSE FOR REPORTED i_slsprcgconditionrecordtp_2,
            ls_failed   TYPE RESPONSE FOR FAILED i_slsprcgconditionrecordtp_2.

      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      IF lv_top < 0.
        lv_top = 1.
      ENDIF.

      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
      DATA(lt_sort)    = io_request->get_sort_elements( ).
      DATA(lv_conditions) =  io_request->get_filter( )->get_as_sql_string( ).
      DATA : lv_orderby TYPE string.

      LOOP AT lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } DESCENDING '|.
        ELSE.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } ASCENDING '|.
        ENDIF.
      ENDLOOP.

      IF lv_orderby IS INITIAL.
        lv_orderby = 'MATNR'.
      ENDIF.

      SELECT header~SalesOrganization,
             Header~DistributionChannel,
             Header~SoldToParty,
             Header~SalesOrderType,
             item~material
*             item~yy1_ablad_sdi//commented by trupti
      FROM I_SalesOrder AS header
      INNER JOIN I_SalesDocumentItem AS item
      ON item~OrderID = header~SalesOrder
      WHERE (lv_conditions)
      GROUP BY header~SalesOrganization,
             Header~DistributionChannel,
             Header~SoldToParty,
             Header~SalesOrderType,
             item~material
*             item~yy1_ablad_sdi//commented by trupti
      INTO TABLE @DATA(lt_sales_area)
      .

      LOOP AT lt_sales_area ASSIGNING FIELD-SYMBOL(<wa_results>).

        lt_request1 = VALUE #( ( %cid = 'Test1'
             %param = VALUE #(
             conditionvaliditystartdate = '20230101'
             conditionvalidityenddate = '99991231'
             deltdconditionrecordisexcluded = 'X'

             _conditionrecordcriteriaitem = VALUE #( ( _conditiontype = VALUE #( ( pricingconditiontyperangesign = 'I' prcgconditiontyperangeoption = 'EQ' pricingconditiontyperangelow = 'ZR00' ) )
             _conditiontable = VALUE #( ( pricingconditiontablerangesign = 'I' prcgconditiontablerangeoption = 'EQ' pricingconditiontablerangelow = '630' )
                                        ( pricingconditiontablerangesign = 'I' prcgconditiontablerangeoption = 'EQ' pricingconditiontablerangelow = '630' ) )

             _conditionfield = VALUE #(
             ( prcgconditionfieldrangename = 'MATERIAL'            prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-Material )
             ( prcgconditionfieldrangename = 'SALESORGANIZATION'   prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-SalesOrganization )
             ( prcgconditionfieldrangename = 'CUSTOMER'            prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-SoldToParty )
             ( prcgconditionfieldrangename = 'DISTRIBUTIONCHANNEL' prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-DistributionChannel )
             ( prcgconditionfieldrangename = 'SALESDOCUMENTTYPE'   prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-SalesOrderType )
*             ( prcgconditionfieldrangename = 'YY1_ABLAD_PCI'      prcgconditionfieldrangesign = 'I' prcgconditionfieldrangeoption = 'EQ' prcgconditionfieldrangelow = <wa_results>-YY1_ablad_SDI  )//commented by trupti
             ) ) ) ) ) )
             .

        .
        APPEND LINES OF lt_request1 TO lt_request.
      ENDLOOP.

      READ ENTITIES OF i_slsprcgconditionrecordtp_2
       ENTITY salespricingconditionrecord
       EXECUTE getconditionrecord
       FROM lt_request

       RESULT lt_result
       FAILED ls_failed
       REPORTED ls_reported.

*        DELETE lt_result WHERE %param-ConditionValidityStartDate NE  <wa_results>-oldfr.
** Update the Condition Records
*      TRY.

*          <wa_results>-knumh = lt_result[ 1 ]-%param-ConditionRecord.
*
*          <wa_results>-kmein = CONV #( lt_result[ 1 ]-%param-ConditionQuantityUnit ).
*          <wa_results>-kpein = CONV #( lt_result[ 1 ]-%param-ConditionQuantity ).
*          <wa_results>-newto = '99991231' .
*          <wa_results>-sdate = '99991231'.

*        CATCH cx_sy_itab_line_not_found.
*      ENDTRY.
    ENDIF.

    io_response->set_total_number_of_records( lines( it_result ) ).
    io_response->set_data( it_result ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_original_data TYPE STANDARD TABLE OF zc_sale_auto_p WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      <fs_original_data>-VirCondRate = get_conditionratevalue( iv_material            = <fs_original_data>-Material
                                                               iv_salesorganization   = <fs_original_data>-SalesOrganization
                                                               iv_soldtoparty         = <fs_original_data>-SoldToParty
                                                               iv_distributionchannel = <fs_original_data>-DistributionChannel
                                                               iv_salesordertype      = <fs_original_data>-SalesOrderType
                                                               iv_division            = <fs_original_data>-Division ).
*                                                               iv_yy1_ablad_sdi       = <fs_original_data>-YY1_ablad_SDI ).//commented by trupti
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity <> 'ZC_SALE_AUTO_P'.
      RETURN.
*      RAISE EXCEPTION TYPE zcx_sadl_exit.
    ENDIF.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'VIRCONDRATE'.
          et_requested_orig_elements = VALUE #( ( |SALESORGANIZATION| )
                                                ( |MATERIAL| )
                                                ( |SOLDTOPARTY| )
                                                ( |DISTRIBUTIONCHANNEL| )
                                                ( |SALESORDERTYPE| )
                                                ( |YY1_ABLAD_SDI| ) ).
        WHEN OTHERS.
*
*          RAISE EXCEPTION TYPE zcx_sadl_exit.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
