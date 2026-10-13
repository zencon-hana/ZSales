CLASS zcl_sales_auto_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_abap_parallel.

    TYPES: BEGIN OF tys_batches,
             material        TYPE matnr,
             plant           TYPE werks_d,
             storagelocation TYPE lgort_d,
             batch           TYPE charg_d,
             quantity        TYPE menge_d,
           END OF tys_batches.

    TYPES: tyt_sales_auto         TYPE TABLE FOR READ RESULT zc_sale_auto,
           tys_sales_auto         TYPE LINE OF tyt_sales_auto,
           tv_char01              TYPE c LENGTH 1,
           tys_edelivery_reported TYPE RESPONSE FOR REPORTED EARLY i_outbounddeliverytp,
           tys_ldelivery_reported TYPE RESPONSE FOR REPORTED LATE i_outbounddeliverytp,
           tys_ebill_reported     TYPE RESPONSE FOR REPORTED EARLY i_billingdocumenttp,
           tys_lbill_reported     TYPE RESPONSE FOR REPORTED LATE i_billingdocumenttp,
           tys_crt_sucr_keys      TYPE TABLE FOR ACTION IMPORT zc_sale_auto~createsuccessordocs,
           tyt_batches            TYPE STANDARD TABLE OF tys_batches WITH NON-UNIQUE DEFAULT KEY.

    DATA: mt_sales_auto              TYPE tyt_sales_auto,
          ms_crt_sucr_keys           TYPE  tys_crt_sucr_keys,
          mt_sales_auto_ear_reported TYPE RESPONSE FOR REPORTED EARLY zc_sale_auto,
          mt_sales_auto_ear_mapped   TYPE RESPONSE FOR MAPPED EARLY zc_sale_auto,
          mt_sales_auto_result       TYPE TABLE FOR ACTION RESULT zc_sale_auto~createsuccessordocs,
          mo_client_proxy            TYPE REF TO /iwbep/if_cp_client_proxy,
          ms_zc_api_usr              TYPE zc_api_user.

    METHODS : constructor IMPORTING it_sales_auto    TYPE tyt_sales_auto
                                    is_crt_sucr_keys TYPE  tys_crt_sucr_keys OPTIONAL.

    CLASS-METHODS: check_advance_payment IMPORTING iv_salesdocument     TYPE i_salesdocument-salesdocument
                                                   iv_salesdocumentitem TYPE i_salesdocumentitem-salesdocumentitem
                                         RETURNING VALUE(rs_message)    TYPE  tds_bd_le_shp_message.
*      create_so_subsequents_doc.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      fetch_credentials,

      build_delivery_doc
        IMPORTING is_sales_auto         TYPE tys_sales_auto
        RETURNING VALUE(rs_delivery_no) TYPE vbeln
        RAISING   zcx_sales_auto,

      check_n_update_so_partner
        IMPORTING is_sales_auto TYPE tys_sales_auto,

      get_etag
        IMPORTING iv_delivery_no TYPE vbeln
                  is_sales_auto  TYPE tys_sales_auto
        RETURNING VALUE(rv_etag) TYPE string,

      get_etag_delv_item
        IMPORTING iv_delivery_no TYPE vbeln
                  iv_posnr       TYPE posnr
                  is_sales_auto  TYPE tys_sales_auto
        RETURNING VALUE(rv_etag) TYPE string,

      get_batches IMPORTING is_sales_auto     TYPE tys_sales_auto
                  RETURNING VALUE(rt_batches) TYPE tyt_batches,

      do_delivery_pgi
        IMPORTING iv_delivery_no TYPE vbeln
                  is_sales_auto  TYPE tys_sales_auto
        RAISING   zcx_sales_auto,

      clear_user_inputs_db
        IMPORTING is_sales_auto TYPE tys_sales_auto,

      update_delivery_header
        IMPORTING iv_delivery_no TYPE vbeln
                  is_sales_auto  TYPE tys_sales_auto
        RAISING   zcx_sales_auto,

      update_delivery_header_text
        IMPORTING iv_delivery_no TYPE vbeln
                  is_sales_auto  TYPE tys_sales_auto
        RAISING   zcx_sales_auto,

      update_vehicle_text
        IMPORTING iv_delivery_no       TYPE vbeln
                  is_sales_auto        TYPE tys_sales_auto
        RETURNING VALUE(rv_update_flg) TYPE abap_boolean
        RAISING   zcx_sales_auto,

      update_delivery_item
        IMPORTING iv_delivery_no       TYPE vbeln
                  iv_item_no           TYPE posnr
                  iv_batch             TYPE charg_d
                  iv_batch_qty         TYPE menge_d
                  is_sales_auto        TYPE tys_sales_auto
        RETURNING VALUE(rv_update_flg) TYPE abap_boolean
        RAISING   zcx_sales_auto,

      update_delivery_item_batch
        IMPORTING iv_delivery_no TYPE vbeln
                  iv_item_no     TYPE posnr
                  iv_batch       TYPE charg_d
                  iv_batch_qty   TYPE menge_d
                  is_sales_auto  TYPE tys_sales_auto
*        RETURNING VALUE(rv_update_flg) TYPE abap_boolean
        RAISING   zcx_sales_auto,

      create_vehicle_text
        IMPORTING iv_delivery_no TYPE vbeln
                  is_sales_auto  TYPE tys_sales_auto
        RAISING   zcx_sales_auto,

      prepare_edelivery_reported
        IMPORTING is_reported_modify TYPE tys_edelivery_reported
                  is_sales_auto      TYPE tys_sales_auto,

      prepare_ldelivery_reported
        IMPORTING is_reported_modify TYPE tys_ldelivery_reported
                  is_sales_auto      TYPE tys_sales_auto,

      prepare_ebilling_reported
        IMPORTING is_reported_modify TYPE tys_ebill_reported
                  is_sales_auto      TYPE tys_sales_auto,

      prepare_lbilling_reported
        IMPORTING is_reported_modify TYPE tys_lbill_reported
                  is_sales_auto      TYPE tys_sales_auto,

      build_billing_doc
        IMPORTING iv_delivery_no            TYPE vbeln
                  is_sales_auto             TYPE tys_sales_auto
        RETURNING VALUE(rv_billingdocument) TYPE zc_sale_auto-billingdocument,

      prepare_message_reported
        IMPORTING iv_severity   TYPE tv_char01
                  is_sales_auto TYPE tys_sales_auto
                  iv_text       TYPE string,

      build_communication_with_api
        RAISING zcx_sales_auto,

      get_new_message
        IMPORTING iv_severity   TYPE tv_char01
                  iv_text       TYPE csequence OPTIONAL
        RETURNING VALUE(ro_msg) TYPE REF TO if_abap_behv_message,

      new_message
        IMPORTING
          !id        TYPE symsgid
          !number    TYPE symsgno
          !severity  TYPE if_abap_behv_message=>t_severity
          !v1        TYPE simple OPTIONAL
          !v2        TYPE simple OPTIONAL
          !v3        TYPE simple OPTIONAL
          !v4        TYPE simple OPTIONAL
        RETURNING
          VALUE(obj) TYPE REF TO if_abap_behv_message .

ENDCLASS.



CLASS ZCL_SALES_AUTO_UTILITY IMPLEMENTATION.


  METHOD build_billing_doc.
*ZBP_CPR_R_CREATE_BILLING2
    DATA : lt_create_billing TYPE TABLE FOR ACTION IMPORT       i_billingdocumenttp~createfromsddocument.
    DATA: ls_temporary_key TYPE STRUCTURE FOR KEY OF i_billingdocumenttp.

    CHECK iv_delivery_no IS NOT INITIAL AND is_sales_auto-billingdocument IS INITIAL.
*    WAIT UP TO 5 SECONDS.
*    lt_create_billing =  VALUE #( (  %cid = is_sales_auto-salesorder && cl_abap_context_info=>get_user_technical_name( ) && cl_abap_context_info=>get_system_date( ) && cl_abap_context_info=>get_system_time( )
*                                  %param = VALUE #(   _reference = VALUE #( ( sddocument = iv_delivery_no
**                                                                            _item = VALUE #( ( billingquantity = is_sales_auto-quantity
**                                                                                               sddocumentitem  = '000010'
**                                                                                               %control      = VALUE #( billingquantity = if_abap_behv=>mk-on
**                                                                                                                        sddocumentitem  = if_abap_behv=>mk-on ) )
**                                                                                             ( "billingquantity = is_sales_auto-quantity
**                                                                                               sddocumentitem  = '900001'
**                                                                                               %control      = VALUE #( "billingquantity = if_abap_behv=>mk-on
**                                                                                                                        sddocumentitem  = if_abap_behv=>mk-on ) )                            )
*                                                                            %control = VALUE #( sddocument = if_abap_behv=>mk-on _item = if_abap_behv=>mk-on  ) ) )
*                                                    %control =  VALUE #( _reference = if_abap_behv=>mk-on _control = if_abap_behv=>mk-on ) ) ) ).
    COMMIT ENTITIES RESPONSES
    FAILED   DATA(lt_commit_failed)
    REPORTED DATA(lt_commit_reported).

    MODIFY ENTITIES OF i_billingdocumenttp
    ENTITY billingdocument
    EXECUTE createfromsddocument AUTO FILL CID
    WITH VALUE #(
    ( %param = VALUE #( _reference = VALUE #( ( sddocument = iv_delivery_no
                          %control = VALUE #( sddocument = if_abap_behv=>mk-on ) ) )
      %control = VALUE #( _reference = if_abap_behv=>mk-on ) ) ) )

*    MODIFY ENTITIES OF i_billingdocumenttp FORWARDING PRIVILEGED
*                     ENTITY billingdocument
*                     EXECUTE createfromsddocument
*                     FROM lt_create_billing
         RESULT DATA(lt_result_modify)
                    FAILED DATA(ls_failed_modify)
                    REPORTED DATA(ls_reported_modify).
    IF ls_failed_modify IS NOT INITIAL.
      prepare_ebilling_reported( is_reported_modify = ls_reported_modify is_sales_auto = is_sales_auto ).
    ELSE.
      COMMIT ENTITIES BEGIN
       RESPONSE OF i_billingdocumenttp
       FAILED DATA(ls_failed_save)
       REPORTED DATA(ls_reported_save).
      CONVERT KEY OF i_billingdocumenttp FROM lt_result_modify[ 1 ]-%param-%pid TO DATA(ls_final_key).
*      CONVERT KEY OF i_billingdocumenttp FROM ls_temporary_key TO DATA(ls_final_key).
      COMMIT ENTITIES END.
      prepare_lbilling_reported( is_reported_modify = ls_reported_save is_sales_auto = is_sales_auto ).

    ENDIF.
    IF ls_final_key IS NOT INITIAL.
      prepare_message_reported( iv_severity = CONV #( if_abap_behv_message=>severity-success )
                                    is_sales_auto = is_sales_auto
                                    iv_text = |Billing document { CONV string( ls_final_key-billingdocument ) } is created.| ).
      rv_billingdocument = ls_final_key-billingdocument.
    ENDIF.
*      failed-zcpr_r_create_billing = VALUE #( ( %key = keys[ 1 ]-%key ) ).
*
*      APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                     %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                   text = 'Hint : Kindly Check Posted Billing Document.' ) ) TO reported-zcpr_r_create_billing.
*      APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                     %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                   text = 'Billing Quantity Can not be zero.' ) ) TO reported-zcpr_r_create_billing.
*
*
*      RETURN.

  ENDMETHOD.


  METHOD build_communication_with_api.
    DATA: lo_http_client   TYPE REF TO if_web_http_client.

    TRY.

*        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                      EXPORTING
*                                        comm_scenario      = 'ZCOM_ARRANGE_API'
**                                        service_id         = 'API_SUPPLIERINVOICE_PROC_SRV_0001_IWSG'
**                                       comm_system_id     = 'BACKEND_CON'
*                                        ).
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = zcl_api_usr_utility=>get_url( ) ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        lo_http_client->get_http_request( )->set_authorization_basic(
          EXPORTING
            i_username = CONV #( ms_zc_api_usr-apiuser )
            i_password = CONV #( ms_zc_api_usr-password )
        ).

*        DATA(lo_http_client) =  cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_client_proxy) = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
                                  EXPORTING
                                    is_proxy_model_key       =  VALUE #( repository_id = 'DEFAULT'
                                                                         proxy_model_id = 'ZSC_API_OUTBOUND_DELIVERY'
                                                                         proxy_model_version = '0001' )
                                    io_http_client           = lo_http_client
                                    iv_relative_service_root = zif_apis=>c_url-outbound_delivery ). "'/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV'

        mo_client_proxy = lo_client_proxy.

      CATCH cx_root INTO DATA(lx_root).
        RAISE EXCEPTION NEW zcx_sales_auto( previous = lx_root ).
    ENDTRY.

  ENDMETHOD.


  METHOD build_delivery_doc.

    DATA: ls_temporary_key        TYPE STRUCTURE FOR KEY OF i_outbounddeliverytp,
          ls_mapped_outbound_delv TYPE RESPONSE FOR MAPPED i_outbounddeliverytp,
          lv_count                TYPE sy-tabix,
          lv_item_quantity        TYPE menge_d,
          lv_batch_quantity       TYPE menge_d.

    DATA(lt_batches) = get_batches( is_sales_auto ).
    IF lt_batches IS NOT INITIAL.
      SELECT SINGLE SUM( quantity ) AS sum_qty
      FROM @lt_batches AS lt_batches
      INTO @DATA(lv_available_qty).
      IF lv_available_qty < is_sales_auto-quantity.
*      prepare_message_reported( iv_severity = CONV #( if_abap_behv_message=>severity-error )
*                                    is_sales_auto = is_sales_auto
*                                    iv_text = |Available quantity { lv_available_qty } is less than required quantity { is_sales_auto-quantity }| ).
        RAISE EXCEPTION TYPE zcx_sales_auto
          EXPORTING
            textid    = zcx_sales_auto=>cs_less_available_stock
            iv_field1 = CONV #( lv_available_qty )
            iv_field2 = CONV #( is_sales_auto-quantity ).
      ENDIF.
    ENDIF.
    MODIFY ENTITIES OF i_outbounddeliverytp FORWARDING PRIVILEGED
    ENTITY outbounddelivery
    EXECUTE createdlvfromsalesdocument
    FROM VALUE #( ( %cid = is_sales_auto-salesorder
                    %param = VALUE #( %control = VALUE #(
                                      shippingpoint = if_abap_behv=>mk-on
                                      deliveryselectiondate = if_abap_behv=>mk-on
                                      deliverydocumenttype = if_abap_behv=>mk-on )
                                      shippingpoint = is_sales_auto-shippingpoint
                                      deliveryselectiondate = is_sales_auto-deliverydate "cl_abap_context_info=>get_system_date( )
                                      deliverydocumenttype = 'LF'
                                      _referencesddocumentitem = VALUE #( ( %control = VALUE #( referencesddocument = if_abap_behv=>mk-on
                                                                                                referencesddocumentitem = if_abap_behv=>mk-on )
                                                                                                referencesddocument = is_sales_auto-salesorder
                                                                                                referencesddocumentitem = is_sales_auto-salesorderitem ) ) ) ) )
    MAPPED DATA(ls_mapped)
    REPORTED DATA(ls_reported_modify)
    FAILED DATA(ls_failed_modify).

    IF ls_failed_modify IS NOT INITIAL.
      prepare_edelivery_reported( is_reported_modify = ls_reported_modify is_sales_auto = is_sales_auto ).
    ELSE.

      COMMIT ENTITIES BEGIN
       RESPONSE OF i_outbounddeliverytp

       FAILED DATA(ls_failed_save)
       REPORTED DATA(ls_reported_save).
      CONVERT KEY OF i_outbounddeliverytp FROM ls_mapped-outbounddelivery[ 1 ]-%pid TO DATA(ls_final_key).
*      CONVERT KEY OF I_OutboundDeliveryTP FROM ls_temporary_key TO DATA(ls_final_key).
      COMMIT ENTITIES END.
      prepare_ldelivery_reported( is_reported_modify = ls_reported_save is_sales_auto = is_sales_auto ).
    ENDIF.
*    ELSE.
*      ls_final_key = is_sales_auto-OutboundDelivery.
*    ENDIF.
    IF ls_final_key IS NOT INITIAL.
      prepare_message_reported( iv_severity = CONV #( if_abap_behv_message=>severity-success )
                                  is_sales_auto = is_sales_auto
                                  iv_text = |Outbound delivery { CONV string( ls_final_key-outbounddelivery ) } is created.| ).

      MODIFY ENTITIES OF i_outbounddeliverytp
      ENTITY outbounddeliveryitem
      UPDATE
        FIELDS ( actualdeliveredqtyinorderunit orderquantityunit  )
        WITH VALUE #( ( actualdeliveredqtyinorderunit = is_sales_auto-quantity
                        orderquantityunit             = is_sales_auto-quantityunit
*                        batch                         = lt_batches[ 1 ]-batch
                        %tky-outbounddelivery         = ls_final_key-outbounddelivery
                        %tky-outbounddeliveryitem     = '000010' ) )
        FAILED   DATA(ls_failed_upd)
        REPORTED DATA(ls_reported_upd).
      IF ls_failed_upd IS NOT INITIAL.
        prepare_edelivery_reported( is_reported_modify = ls_reported_upd is_sales_auto = is_sales_auto ).
      ELSE.
        rs_delivery_no = ls_final_key-outbounddelivery.
        COMMIT ENTITIES BEGIN
         RESPONSE OF i_outbounddeliverytp
         FAILED DATA(ls_failed_upd_save)
         REPORTED DATA(ls_reported_upd_save).
        COMMIT ENTITIES END.
        prepare_ldelivery_reported( is_reported_modify = ls_reported_upd_save is_sales_auto = is_sales_auto ).
      ENDIF.

*      READ ENTITIES OF i_outbounddeliverytp
*        ENTITY outbounddeliveryitem
*          ALL FIELDS
*          WITH VALUE #( ( outbounddelivery = ls_final_key-outbounddelivery outbounddeliveryitem = '000010' ) )
*        RESULT   DATA(lt_delivery_item)
*        REPORTED DATA(ls_reported)
*        FAILED   DATA(ls_failed).

      LOOP AT lt_batches ASSIGNING FIELD-SYMBOL(<ls_batch>) WHERE batch IS NOT INITIAL.
        lv_count = sy-tabix.

        IF lv_count = 1.
          "modify item 10
          lv_item_quantity = lv_batch_quantity = COND #( WHEN <ls_batch>-quantity >= is_sales_auto-quantity THEN is_sales_auto-quantity ELSE <ls_batch>-quantity ).
        ELSE.
          IF ( lv_batch_quantity + <ls_batch>-quantity )  > is_sales_auto-quantity.
            lv_item_quantity = is_sales_auto-quantity - lv_batch_quantity.
            lv_batch_quantity = lv_batch_quantity + lv_item_quantity.
          ELSE.
            lv_batch_quantity += <ls_batch>-quantity.
            lv_item_quantity = <ls_batch>-quantity.
          ENDIF.
        ENDIF.
        update_delivery_item_batch( iv_delivery_no = ls_final_key-outbounddelivery
                                    iv_item_no = '000010'
                                    iv_batch = <ls_batch>-batch
                                    iv_batch_qty = lv_item_quantity
                                    is_sales_auto = is_sales_auto ).
        IF lv_batch_quantity >= is_sales_auto-quantity.
          EXIT.
        ENDIF.
      ENDLOOP.
*      IF lt_item IS NOT INITIAL.
*        MODIFY ENTITIES OF i_outbounddeliverytp
*        ENTITY outbounddelivery
*        CREATE BY \_item
*        FROM lt_item
*        MAPPED DATA(ls_mapped_itm_create)
*        REPORTED DATA(ls_reported_itm_create)
*        FAILED DATA(ls_failed_itm_create).
*      ENDIF.

*      CHECK ls_reported_modify IS NOT INITIAL.
*      READ ENTITIES OF I_OutboundDeliveryTP
*        ENTITY OutboundDeliveryItem
*          FIELDS ( ActualDeliveredQtyInOrderUnit OrderQuantityUnit )
*          WITH VALUE #( ( OutboundDelivery = ls_reported_modify-outbounddelivery[ 1 ]-OutboundDelivery OutboundDeliveryItem = '000010' ) )
*        RESULT   DATA(lt_delivery_item)
*        REPORTED DATA(ls_reported)
*        FAILED   DATA(ls_failed).

    ENDIF.

  ENDMETHOD.


  METHOD get_batches.
*    SELECT material, plant, storagelocation, batch, SUM( matlwrhsstkqtyinmatlbaseunit ) AS quantity
    SELECT material, plant, storagelocation, batch, SUM( matlwrhsstkqtyinmatlbaseunit ) AS quantity,
    SUM( matlcnsmpnqtyinmatlbaseunit ) AS consmpqty,
        SUM( matlstkincrqtyinmatlbaseunit ) AS stkiqty,
        SUM( matlstkdecrqtyinmatlbaseunit ) AS stkdqty
      FROM i_materialstock_2
     WHERE material = @is_sales_auto-material
       AND plant = @is_sales_auto-plant
       AND storagelocation = @is_sales_auto-storagelocation
*       AND matlwrhsstkqtyinmatlbaseunit > 0
     GROUP BY material, plant,storagelocation, batch
     ORDER BY batch
     INTO TABLE @DATA(lt_batches).
    IF sy-subrc = 0.
      rt_batches = CORRESPONDING #( lt_batches ).
      DELETE rt_batches WHERE quantity <= 0.
    ENDIF.
  ENDMETHOD.


  METHOD check_n_update_so_partner.
    DATA:
      ls_business_data TYPE zscm_api_sales_order=>tys_a_sales_order_header_par_2,
      ls_entity_key    TYPE zscm_api_sales_order=>tys_a_sales_order_header_par_2,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
      lo_request       TYPE REF TO /iwbep/if_cp_request_update,
      lo_response      TYPE REF TO /iwbep/if_cp_response_update.

    CHECK is_sales_auto-forwadingagent IS NOT INITIAL.
    SELECT SINGLE \_partner-salesdocument, \_partner-partnerfunction, \_partner-customer, \_partner-supplier
    FROM i_salesdocument
    WHERE salesdocument = @is_sales_auto-salesorder
      AND \_partner-partnerfunction = 'SP' "SP forwarding agent
      INTO @DATA(ls_forwarding_agnt).
    IF sy-subrc = 0 AND ls_forwarding_agnt-supplier <> is_sales_auto-forwadingagent.
      TRY.
          DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = zcl_api_usr_utility=>get_url( ) ).

          lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
          lo_http_client->get_http_request( )->set_authorization_basic(
            EXPORTING
              i_username = CONV #( ms_zc_api_usr-apiuser )
              i_password = CONV #( ms_zc_api_usr-password )
          ).

          " Create http client
          lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
            EXPORTING
               is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                   proxy_model_id      = 'ZSCM_API_SALES_ORDER'
                                                   proxy_model_version = '0001' )
              io_http_client             = lo_http_client
              iv_relative_service_root   = zif_apis=>c_url-sales_order ).
          ASSERT lo_http_client IS BOUND.
          " Set entity key
          ls_entity_key = VALUE #( sales_order      = is_sales_auto-salesorder
                                   partner_function = 'CR' ).
          " Prepare the business data
          ls_business_data = VALUE #( sales_order                 = is_sales_auto-salesorder
                                      partner_function            = 'CR'
                                      supplier                    = is_sales_auto-forwadingagent
*                                      customer                    = is_sales_auto-ForwadingAgent
*                                      partner_function_internal   = 'PartnerFunctionInternal'
*                                      personnel                   = 'Personnel'
*                                      contact_person              = 'ContactPerson'
*                                      reference_business_partner  = 'ReferenceBusinessPartner'
*                                      address_id                  = 'AddressId'
*                                      vatregistration             = 'Vatregistration'
                                    ).

          " Navigate to the resource and create a request for the update operation
          lo_resource = lo_client_proxy->create_resource_for_entity_set( 'A_SALES_ORDER_HEADER_PARTN' )->navigate_with_key( ls_entity_key ).
          lo_request = lo_resource->create_request_for_update( /iwbep/if_cp_request_update=>gcs_update_semantic-patch ).
          lo_request->set_business_data( is_business_data = ls_business_data
                                         it_provided_property = VALUE #( ( |SUPPLIER| ) ) ).

          " Execute the request and retrieve the business data
          lo_response = lo_request->execute( ).
*          ls_business_data-sales_order = is_sales_auto-SalesOrder.
          " Get updated entity
          CLEAR ls_business_data.
          lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

        CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
          " Handle remote Exception
          " It contains details about the problems of your http(s) connection
          RETURN.
        CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
          " Handle Exception
          RETURN.

        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          " Handle Exception
          RETURN.
        CATCH cx_root INTO DATA(lx_root).
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD clear_user_inputs_db.
    UPDATE zsales_auto_inp SET
                               quantity           = '',
*                               quantityunit       = '',
                               vehicleno          = '',
                               transportername    = '',
                               drivername         = '',
                               driverlicenceno    = '',
                               forwadingagent     = '',
                               packingdetails     = ''
    WHERE salesorder     = @is_sales_auto-salesorder
      AND salesorderitem = @is_sales_auto-salesorderitem.
  ENDMETHOD.


  METHOD constructor.
    mt_sales_auto = it_sales_auto.
    ms_crt_sucr_keys = is_crt_sucr_keys.
  ENDMETHOD.


  METHOD create_vehicle_text.
    DATA: ls_business_response_data TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_t_2.
    TRY.
*        mo_client_proxy->create_resource_for_entity_set( zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_header_tex )->navigate_with_key( VALUE zcl_sc_api_outbound_delivery=>tys_parameters_6( delivery_document = iv_delivery_no  )  ).
*        DATA(lo_child_resource) = lo_entity_resource->navigate_to_single( zcl_sc_api_outbound_delivery=>gcs_entity_type-a_outb_delivery_header_typ-navigation-to_delivery_document_text ).

        DATA(lo_request) =
        mo_client_proxy->create_resource_for_entity_set( zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_header_tex )->create_request_for_create( ).
        lo_request->set_business_data( is_business_data = VALUE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_t_2( delivery_document = iv_delivery_no
                                                                                                                            text_element = 'ZVEH'
                                                                                                                            language = 'EN'
                                                                                                                            text_element_text = is_sales_auto-vehicleno )
                                       it_provided_property = VALUE #( ( |DELIVERY_DOCUMENT| )
                                                                       ( |TEXT_ELEMENT| )
                                                                       ( |LANGUAGE| )
                                                                       ( |TEXT_ELEMENT_TEXT| ) ) ).
        DATA(lo_response) = lo_request->execute( ).

        lo_response->get_business_data(
          IMPORTING
            es_business_data = ls_business_response_data
        ).

      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.
    IF ls_business_response_data IS NOT INITIAL.
      DATA(lv_success_msg) = |Delivery vechile no updated { iv_delivery_no } | .
    ELSE.
      DATA(lv_fail_msg) = |Vechile create fail: { lv_error2 } |.
    ENDIF.
*  No message log need to generate for it.
*    prepare_message_reported( is_sales_auto = is_sales_auto
*                                iv_severity   = COND #( WHEN ls_business_response_data IS NOT INITIAL
*                                                        THEN if_abap_behv_message=>severity-success
*                                                        ELSE if_abap_behv_message=>severity-error )
*                                iv_text  = COND #( WHEN ls_business_response_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).

  ENDMETHOD.


  METHOD do_delivery_pgi.
    TYPES : BEGIN OF tys_parameter,
              name  TYPE string,
              value TYPE string,
            END OF tys_parameter.
    DATA: lt_response_data TYPE zcl_sc_api_outbound_delivery=>tyt_picking_report,
          lv_error2        TYPE string.

    CHECK iv_delivery_no IS NOT INITIAL AND is_sales_auto-goodsmovementstatus <> 'C'.
    TRY.
        DATA(lv_etag) = get_etag( iv_delivery_no = iv_delivery_no is_sales_auto = is_sales_auto ).
        IF lv_etag IS INITIAL.
          lv_error2 = |etag not found for { iv_delivery_no }|.
        ELSE.
          DATA(lo_request) = mo_client_proxy->create_resource_for_function( zcl_sc_api_outbound_delivery=>gcs_function_import-post_goods_issue ).
          lo_request->set_parameter(
            EXPORTING
              is_parameter = VALUE zcl_sc_api_outbound_delivery=>tys_parameters_6( delivery_document = iv_delivery_no ) ).

          DATA(lo_response) = lo_request->create_request( ).
          lo_response->set_if_match( iv_etag = lv_etag ).
          DATA(lo_res) = lo_response->execute( 'POST' ).
          lo_res->get_business_data(
            IMPORTING
              ea_response_data = lt_response_data
          ).
        ENDIF.
        IF lt_response_data IS INITIAL.
          lt_response_data = VALUE #( ( system_message_type = if_abap_behv_message=>severity-success ) ).
        ENDIF.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error)  = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        lv_error2       = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
    ENDTRY.

    IF lt_response_data IS NOT INITIAL.
      DATA(lv_success_msg) = |PGI done for { iv_delivery_no } | .
    ELSE.
      DATA(lv_fail_msg) = |Failed Note { lv_error2 } |.
    ENDIF.
    prepare_message_reported( is_sales_auto = is_sales_auto
                                iv_severity   = COND #( WHEN lt_response_data IS NOT INITIAL
                                                        THEN if_abap_behv_message=>severity-success
                                                        ELSE if_abap_behv_message=>severity-error )
                                iv_text  = COND #( WHEN lt_response_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).

  ENDMETHOD.


  METHOD fetch_credentials.
    SELECT SINGLE * FROM zc_api_user
            WHERE apiuser = @zif_apis=>c_api_custom_credentials-username
            INTO @ms_zc_api_usr.
  ENDMETHOD.


  METHOD get_etag.
    DATA ls_response_data TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_typ.
    TRY.
        DATA(lo_entity_resource) =
        mo_client_proxy->create_resource_for_entity_set( zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_header )->navigate_with_key( VALUE zcl_sc_api_outbound_delivery=>tys_parameters_6( delivery_document = iv_delivery_no  )  ).
        DATA(lo_request) = lo_entity_resource->create_request_for_read( ).
*
        " Execute the request

        DATA(lo_res) = lo_request->execute( ).
        lo_res->get_business_data(
          IMPORTING
            es_business_data = ls_response_data
        ).
*          CATCH /iwbep/cx_gateway.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.

    IF ls_response_data IS NOT INITIAL.
      DATA(lv_success_msg) = |etag returned for { iv_delivery_no } | .
      rv_etag = ls_response_data-etag.
    ELSE.
      DATA(lv_fail_msg) = |Failed Note { lv_error2 } |.
    ENDIF.
    prepare_message_reported( is_sales_auto = is_sales_auto
                                iv_severity   = COND #( WHEN lv_success_msg IS NOT INITIAL
                                                        THEN if_abap_behv_message=>severity-success
                                                        ELSE if_abap_behv_message=>severity-error )
                                iv_text  = COND #( WHEN lv_success_msg IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).

  ENDMETHOD.


  METHOD get_etag_delv_item.
    DATA ls_response_data TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_item_type.
    TRY.
        DATA(lo_entity_resource) =
        mo_client_proxy->create_resource_for_entity_set( zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_item )->navigate_with_key( VALUE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_item_type( delivery_document = iv_delivery_no
                                                                                                                                                                                                                delivery_document_item = iv_posnr )  ).
        DATA(lo_request) = lo_entity_resource->create_request_for_read( ).
*
        " Execute the request

        DATA(lo_res) = lo_request->execute( ).
        lo_res->get_business_data(
          IMPORTING
            es_business_data = ls_response_data
        ).
*          CATCH /iwbep/cx_gateway.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.

    IF ls_response_data IS NOT INITIAL.
      DATA(lv_success_msg) = |etag returned for { iv_delivery_no } | .
      rv_etag = ls_response_data-etag.
    ELSE.
      DATA(lv_fail_msg) = |Failed Note { lv_error2 } |.
    ENDIF.
    prepare_message_reported( is_sales_auto = is_sales_auto
                                iv_severity   = COND #( WHEN lv_success_msg IS NOT INITIAL
                                                        THEN if_abap_behv_message=>severity-success
                                                        ELSE if_abap_behv_message=>severity-error )
                                iv_text  = COND #( WHEN lv_success_msg IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).


  ENDMETHOD.


  METHOD get_new_message.
    ro_msg = new_message(
    id       = 'SABP_BEHV'
    number   = 100
    severity = CONV #( iv_severity )
    v1       = iv_text
  ).
  ENDMETHOD.


  METHOD if_abap_parallel~do.
    TRY.
        fetch_credentials( ).
        build_communication_with_api( ).
        LOOP AT mt_sales_auto ASSIGNING FIELD-SYMBOL(<ls_sales_auto>).
          check_n_update_so_partner( <ls_sales_auto> ).
          DATA(lv_delivery_no) = build_delivery_doc( is_sales_auto = <ls_sales_auto> ).

          update_delivery_header( iv_delivery_no = lv_delivery_no
                                  is_sales_auto = <ls_sales_auto> ).

*          update_delivery_header_text( iv_delivery_no = lv_delivery_no
*                                  is_sales_auto = <ls_sales_auto> ).

          do_delivery_pgi( iv_delivery_no = lv_delivery_no
                           is_sales_auto = <ls_sales_auto> ).

          DATA(lv_billing_doc) = build_billing_doc( is_sales_auto  = <ls_sales_auto>
                                                    iv_delivery_no = lv_delivery_no ).
*          IF lv_delivery_no IS NOT INITIAL.
          clear_user_inputs_db( is_sales_auto = <ls_sales_auto> ).
*          ENDIF.
          APPEND VALUE #( %cid = 'CID' && <ls_sales_auto>-%key-salesorder && lv_delivery_no
                          salesorder = <ls_sales_auto>-%key-salesorder
                          salesorderitem = <ls_sales_auto>-%key-salesorderitem
                          outbounddelivery = lv_delivery_no
                          outbounddeliveryitem  =  COND #( WHEN lv_delivery_no IS NOT INITIAL THEN '000010' )
                          billingdocument = lv_billing_doc
                          billingdocumentitem = COND #( WHEN lv_delivery_no IS NOT INITIAL THEN '000010' ) ) TO mt_sales_auto_ear_mapped-zc_sale_auto.
        ENDLOOP.
      CATCH zcx_sales_auto INTO DATA(lx_sales_auto).
        prepare_message_reported( iv_severity = CONV #( if_abap_behv_message=>severity-error )
                                    is_sales_auto = <ls_sales_auto>
                                    iv_text = lx_sales_auto->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD new_message.
    CONSTANTS ls LIKE if_abap_behv_message=>severity VALUE if_abap_behv_message=>severity ##NO_TEXT.

    obj = NEW lcl_abap_behv_msg(
      textid = VALUE #(
                 msgid = id
                 msgno = number
                 attr1 = COND #( WHEN v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                 attr2 = COND #( WHEN v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                 attr3 = COND #( WHEN v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                 attr4 = COND #( WHEN v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' )
      )
      msgty = SWITCH #( severity
                WHEN ls-error       THEN 'E'
                WHEN ls-warning     THEN 'W'
                WHEN ls-information THEN 'I'
                WHEN ls-success     THEN 'S' )

      msgv1 = |{ v1 }|
      msgv2 = |{ v2 }|
      msgv3 = |{ v3 }|
      msgv4 = |{ v4 }|
    ).

    obj->m_severity = severity.

  ENDMETHOD.


  METHOD prepare_ebilling_reported.
    ASSIGN ms_crt_sucr_keys[ salesorder = is_sales_auto-salesorder salesorderitem = is_sales_auto-salesorderitem ] TO FIELD-SYMBOL(<ls_crt_sucr_key>).
    IF sy-subrc = 0.
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                           FOR ls_billingdocument IN is_reported_modify-billingdocument
                                                           ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                             salesorder = <ls_crt_sucr_key>-salesorder
                                                             salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                             outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                             outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                             billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                             billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                             %msg                 = ls_billingdocument-%msg
*                                                            %update
                                                             %action-createsuccessordocs = if_abap_behv=>mk-on )   ).

      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                           FOR ls_billingdocumentitem IN is_reported_modify-billingdocumentitem
                                                           ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                             salesorder = <ls_crt_sucr_key>-salesorder
                                                             salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                             outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                             outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                             billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                             billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                             %msg                 = ls_billingdocumentitem-%msg
*                                                            %update
                                                             %action-createsuccessordocs = if_abap_behv=>mk-on )   ).
    ENDIF.
  ENDMETHOD.


  METHOD prepare_edelivery_reported.
    ASSIGN ms_crt_sucr_keys[ salesorder = is_sales_auto-salesorder salesorderitem = is_sales_auto-salesorderitem ] TO FIELD-SYMBOL(<ls_crt_sucr_key>).
    IF sy-subrc = 0.
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                        FOR ls_outbounddelivery IN is_reported_modify-outbounddelivery
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_outbounddelivery-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on ) ).
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                         FOR ls_salesorder IN is_reported_modify-salesorder
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_salesorder-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on )   ).

      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                         FOR ls_salesorderitem IN is_reported_modify-salesorderitem
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_salesorderitem-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on )   ).


    ENDIF.
  ENDMETHOD.


  METHOD prepare_lbilling_reported.
    ASSIGN ms_crt_sucr_keys[ salesorder = is_sales_auto-salesorder salesorderitem = is_sales_auto-salesorderitem ] TO FIELD-SYMBOL(<ls_crt_sucr_key>).
    IF sy-subrc = 0.
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                           FOR ls_billingdocument IN is_reported_modify-billingdocument
                                                           ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                             salesorder = <ls_crt_sucr_key>-salesorder
                                                             salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                             outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                             outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                             billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                             billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                             %msg                 = ls_billingdocument-%msg
*                                                            %update
                                                             %action-createsuccessordocs = if_abap_behv=>mk-on )   ).

      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                           FOR ls_billingdocumentitem IN is_reported_modify-billingdocumentitem
                                                           ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                             salesorder = <ls_crt_sucr_key>-salesorder
                                                             salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                             outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                             outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                             billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                             billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                             %msg                 = ls_billingdocumentitem-%msg
*                                                            %update
                                                             %action-createsuccessordocs = if_abap_behv=>mk-on )   ).
    ENDIF.
  ENDMETHOD.


  METHOD prepare_ldelivery_reported.
    ASSIGN ms_crt_sucr_keys[ salesorder = is_sales_auto-salesorder salesorderitem = is_sales_auto-salesorderitem ] TO FIELD-SYMBOL(<ls_crt_sucr_key>).
    IF sy-subrc = 0.
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                        FOR ls_outbounddelivery IN is_reported_modify-outbounddelivery
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_outbounddelivery-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on ) ).
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                         FOR ls_salesorder IN is_reported_modify-salesorder
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_salesorder-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on )   ).

      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                         FOR ls_salesorderitem IN is_reported_modify-salesorderitem
                                                         ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                           salesorder = <ls_crt_sucr_key>-salesorder
                                                           salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                           outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                           outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                           billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                           billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                           %msg                 = ls_salesorderitem-%msg
*                                                            %update
                                                           %action-createsuccessordocs = if_abap_behv=>mk-on )   ).


    ENDIF.
  ENDMETHOD.


  METHOD prepare_message_reported.
    ASSIGN ms_crt_sucr_keys[ salesorder = is_sales_auto-salesorder salesorderitem = is_sales_auto-salesorderitem ] TO FIELD-SYMBOL(<ls_crt_sucr_key>).
    IF sy-subrc = 0.
      mt_sales_auto_ear_reported-zc_sale_auto = VALUE #( BASE mt_sales_auto_ear_reported-zc_sale_auto
                                                           ( %cid = <ls_crt_sucr_key>-%cid_ref
                                                             salesorder = <ls_crt_sucr_key>-salesorder
                                                             salesorderitem  = <ls_crt_sucr_key>-salesorderitem
                                                             outbounddelivery = <ls_crt_sucr_key>-outbounddelivery
                                                             outbounddeliveryitem = <ls_crt_sucr_key>-outbounddeliveryitem
                                                             billingdocument      = <ls_crt_sucr_key>-billingdocument
                                                             billingdocumentitem  = <ls_crt_sucr_key>-billingdocumentitem
                                                             %msg                 = get_new_message( iv_severity = iv_severity
                                                                                                     iv_text = iv_text )
*                                                            %update
                                                             %action-createsuccessordocs = if_abap_behv=>mk-on )   ).
    ENDIF.
  ENDMETHOD.


  METHOD update_delivery_header.
*    TYPES: BEGIN OF tys_patch_data,
*             actual_goods_movement_date TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_typ-actual_goods_movement_date,
*             proposed_delivery_route    TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_typ-proposed_delivery_route,
*           END OF tys_patch_data.

*    DATA: ls_patch_data    TYPE tys_patch_data,
    DATA: ls_patch_data    TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_typ,
          ls_business_data TYPE string,
          lv_curr_tsl      TYPE timestampl.

    GET TIME STAMP FIELD DATA(lv_curr_ts).
    GET TIME STAMP FIELD lv_curr_tsl.
    ls_patch_data = VALUE #( actual_goods_movement_date = lv_curr_tsl        "cl_abap_context_info=>get_system_date( )
                             proposed_delivery_route = is_sales_auto-route
                             yy1_transportername_dlh = is_sales_auto-transportername
*                             yy1_driverlicenseno_dlh = is_sales_auto-driverlicenceno
                             yy1_drivername_dlh       = is_sales_auto-drivername
                             yy1_vehiclenumber_dlh    = is_sales_auto-vehicleno
                             yy1_packingdetails_dlh   = is_sales_auto-packingdetails ).
    TRY.
        DATA(lo_entity_resource) =
        mo_client_proxy->create_resource_for_entity_set( zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_header )->navigate_with_key( VALUE zcl_sc_api_outbound_delivery=>tys_parameters_6( delivery_document = iv_delivery_no  )  ).
        DATA(lo_update_request) = lo_entity_resource->create_request_for_update( iv_semantic = /iwbep/if_cp_request_update=>gcs_update_semantic-patch ).
        lo_update_request->set_if_match( get_etag(
                                           iv_delivery_no = iv_delivery_no
                                           is_sales_auto  = is_sales_auto )  ).

        lo_update_request->set_business_data( is_business_data = ls_patch_data
                                              it_provided_property = VALUE #( ( |ACTUAL_GOODS_MOVEMENT_DATE| )
                                                                              ( |PROPOSED_DELIVERY_ROUTE| )
                                                                              ( |YY1_TRANSPORTERNAME_DLH| )
*                                                                              ( |YY1_DRIVERLICENSENO_DLH| )
                                                                              ( |YY1_DRIVERNAME_DLH| )
                                                                              ( |YY1_VEHICLENUMBER_DLH| )
                                                                              ( |YY1_PACKINGDETAILS_DLH| ) ) ).

        DATA(lo_update_response) = lo_update_request->execute( ).

*        lo_update_response->get_business_data( IMPORTING es_business_data = ls_business_data ).
        ls_business_data = abap_true.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.

    IF ls_business_data IS NOT INITIAL.
      DATA(lv_success_msg) = |Delivery header updated { iv_delivery_no } | .
    ELSE.
      DATA(lv_fail_msg) = |Update fail: { lv_error2 } |.
    ENDIF.
*    prepare_message_reported( is_sales_auto = is_sales_auto
*                                iv_severity   = COND #( WHEN ls_business_data IS NOT INITIAL
*                                                        THEN if_abap_behv_message=>severity-success
*                                                        ELSE if_abap_behv_message=>severity-error )
*                                iv_text  = COND #( WHEN ls_business_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).
  ENDMETHOD.


  METHOD update_delivery_header_text.
    DATA(lv_update_flg) = update_vehicle_text( iv_delivery_no = iv_delivery_no is_sales_auto = is_sales_auto ).
    IF lv_update_flg = abap_false.
      create_vehicle_text( iv_delivery_no = iv_delivery_no is_sales_auto = is_sales_auto ).
    ENDIF.
  ENDMETHOD.


  METHOD update_delivery_item.
    DATA: ls_item_patch_data TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_item_type.
    ls_item_patch_data = VALUE #( batch = iv_batch
                                  actual_delivery_quantity = iv_batch_qty
                                  actual_delivered_qty_in_ba = iv_batch_qty ).
    TRY.
        DATA(lo_entity_resource) =
              mo_client_proxy->create_resource_for_entity_set(
              zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_item )->navigate_with_key(
              VALUE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_item_type( delivery_document = iv_delivery_no
                                                                                 delivery_document_item = iv_item_no ) ).
        DATA(lo_update_request) = lo_entity_resource->create_request_for_update( iv_semantic = /iwbep/if_cp_request_update=>gcs_update_semantic-patch ).
        lo_update_request->set_if_match( get_etag_delv_item(
                                           iv_delivery_no = iv_delivery_no
                                           iv_posnr       = iv_item_no
                                           is_sales_auto  = is_sales_auto ) ).
        lo_update_request->set_business_data( is_business_data = ls_item_patch_data
                                                  it_provided_property = VALUE #( ( |BATCH| )
                                                                                  ( |ACTUAL_DELIVERY_QUANTITY| )
                                                                                  ( |ACTUAL_DELIVERED_QTY_IN_BA| ) ) ).

        DATA(lo_update_response) = lo_update_request->execute( ).
        rv_update_flg = abap_true.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
    ENDTRY.
    IF rv_update_flg IS NOT INITIAL.
      DATA(lv_success_msg) = |Delivery item batch updated { iv_delivery_no }/{ iv_item_no } | .
    ELSE.
      DATA(lv_fail_msg) = |Delivery item batch update fail: { iv_delivery_no }/{ iv_item_no }|.
    ENDIF.
  ENDMETHOD.


  METHOD update_delivery_item_batch.
    DATA: lt_response_data TYPE zcl_sc_api_outbound_delivery=>tyt_picking_report,
          lv_error2        TYPE string.

    TRY.
        DATA(lo_request) = mo_client_proxy->create_resource_for_function( zcl_sc_api_outbound_delivery=>gcs_function_import-create_batch_split_item ).
        lo_request->set_parameter(
          EXPORTING
            is_parameter = VALUE zcl_sc_api_outbound_delivery=>tys_parameters_12( delivery_document = iv_delivery_no
                                                                                  delivery_document_item = iv_item_no
                                                                                  batch = iv_batch
                                                                                  actual_delivery_quantity = iv_batch_qty "&& 'M'
                                                                                  pick_quantity_in_sales_uom = iv_batch_qty "&& 'M'
                                                                                  delivery_quantity_unit = is_sales_auto-quantityunit ) ).

        DATA(lo_response) = lo_request->create_request( ).
        lo_response->set_if_match( get_etag_delv_item(
                                         iv_delivery_no = iv_delivery_no
                                         iv_posnr       = iv_item_no
                                         is_sales_auto  = is_sales_auto ) ).

        DATA(lo_res) = lo_response->execute( 'POST' ).
        lo_res->get_business_data( IMPORTING ea_response_data = lt_response_data ).

*    rv_update_flg = abap_true.
        IF lt_response_data IS INITIAL.
          lt_response_data = VALUE #( ( system_message_type = if_abap_behv_message=>severity-success ) ).
        ENDIF.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error)  = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        lv_error2       = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
    ENDTRY.

*    IF lt_response_data IS NOT INITIAL.
*      DATA(lv_success_msg) = |Batch updated for { iv_delivery_no } | .
*    ELSE.
*      DATA(lv_fail_msg) = |Batch update failed { lv_error2 } |.
*    ENDIF.
*    prepare_message_reported( is_sales_auto = is_sales_auto
*                                iv_severity   = COND #( WHEN lt_response_data IS NOT INITIAL
*                                                        THEN if_abap_behv_message=>severity-success
*                                                        ELSE if_abap_behv_message=>severity-error )
*                                iv_text  = COND #( WHEN lt_response_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).

  ENDMETHOD.


  METHOD update_vehicle_text.
    DATA: ls_patch_data TYPE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_t_2.

    ls_patch_data-text_element_text = is_sales_auto-vehicleno.
    TRY.
        DATA(lo_entity_resource) =
          mo_client_proxy->create_resource_for_entity_set(
          zcl_sc_api_outbound_delivery=>gcs_entity_set-a_outb_delivery_header_tex )->navigate_with_key(
          VALUE zcl_sc_api_outbound_delivery=>tys_a_outb_delivery_header_t_2( delivery_document = iv_delivery_no
                                                                            text_element = 'ZVEH'
                                                                            language = 'EN'  )  ).

        DATA(lo_update_request) = lo_entity_resource->create_request_for_update( iv_semantic = /iwbep/if_cp_request_update=>gcs_update_semantic-patch ).
*        lo_update_request->set_if_match( get_etag(
*                                           iv_delivery_no = iv_delivery_no
*                                           is_sales_auto  = is_sales_auto )  ).

        lo_update_request->set_business_data( is_business_data = ls_patch_data
                                              it_provided_property = VALUE #( ( |TEXT_ELEMENT_TEXT| ) ) ).

        DATA(lo_update_response) = lo_update_request->execute( ).

*        lo_update_response->get_business_data( IMPORTING es_business_data = ls_business_data ).
        rv_update_flg = abap_true.
      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error2 = lx_gateway->get_text( ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.
    IF rv_update_flg IS NOT INITIAL.
      DATA(lv_success_msg) = |Delivery vechile no updated { iv_delivery_no } | .
    ELSE.
      DATA(lv_fail_msg) = |Vechile update fail: { lv_error2 } |.
    ENDIF.
*  No message log need to generate for it.
*    IF lv_success_msg IS NOT INITIAL.
*      prepare_message_reported( is_sales_auto = is_sales_auto
*                                  iv_severity   = COND #( WHEN rv_update_flg IS NOT INITIAL
*                                                          THEN if_abap_behv_message=>severity-success
*                                                          ELSE if_abap_behv_message=>severity-error )
*                                  iv_text  = COND #( WHEN rv_update_flg IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ).
*    ENDIF.
  ENDMETHOD.


  METHOD check_advance_payment.
    SELECT SINGLE salesdocument, customerpaymentterms
    FROM i_salesdocument WITH PRIVILEGED ACCESS
    WHERE salesdocument = @iv_salesdocument
    INTO @DATA(ls_sales_doc).
    IF ls_sales_doc-customerpaymentterms = '0001' OR ls_sales_doc-customerpaymentterms = 'NT00'.
      SELECT SINGLE salesdocument, salesdocumentitem, netamount
      FROM i_salesdocumentitem WITH PRIVILEGED ACCESS
      WHERE salesdocument = @iv_salesdocument
        AND salesdocumentitem = @iv_salesdocumentitem
        INTO @DATA(ls_sales_doc_item).
      SELECT SINGLE salesdocument, salesdocumentitem, amountincompanycodecurrency
       FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
       WHERE salesdocument = @iv_salesdocument
         AND salesdocumentitem = @iv_salesdocumentitem
         INTO @DATA(ls_acct_item).
      IF sy-subrc <> 0.
        rs_message = VALUE #( messagetype = 'E' messagetext = |Advance payment is not received for the order { iv_salesdocument }|  ).
      ELSEIF ls_acct_item-amountincompanycodecurrency < ls_sales_doc_item-netamount.
        rs_message = VALUE #( messagetype = 'E' messagetext = |Advance payment received less for the order { iv_salesdocument }|  ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
