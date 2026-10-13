CLASS lsc_zc_sale_auto DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zc_sale_auto IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_zsales_auto_inp TYPE STANDARD TABLE OF zsales_auto_inp,
           lv_nchar10(10)     TYPE n.

    IF update-zc_sale_auto IS NOT INITIAL.
      SELECT SalesOrder,
             SalesOrderItem,
             OutboundDelivery,
             OutboundDeliveryItem,
             BillingDocument,
             BillingDocumentItem,
             quantity,
             QuantityUnit,
             route,
             vehicleno,
             TransporterName,
             DriverName,
             DriverLicenceNo,
             ForwadingAgent,
             PackingDetails
   FROM zc_sale_auto
      FOR ALL ENTRIES IN @update-zc_sale_auto
      WHERE SalesOrder            = @update-zc_sale_auto-%key-SalesOrder
        AND SalesOrderItem        = @update-zc_sale_auto-%key-SalesOrderItem
        AND OutboundDelivery      = @update-zc_sale_auto-%key-OutboundDelivery
        AND OutboundDeliveryItem  = @update-zc_sale_auto-%key-OutboundDeliveryItem
        AND BillingDocument       = @update-zc_sale_auto-%key-BillingDocument
        AND BillingDocumentItem   = @update-zc_sale_auto-%key-BillingDocumentItem
   INTO TABLE @DATA(lt_zc_sales_auto).
      LOOP AT update-zc_sale_auto ASSIGNING FIELD-SYMBOL(<update_ls_sales_auto>).
        ASSIGN lt_zc_sales_auto[ SalesOrder            = <update_ls_sales_auto>-%key-SalesOrder
                                 SalesOrderItem        = <update_ls_sales_auto>-%key-SalesOrderItem
                                 OutboundDelivery      = <update_ls_sales_auto>-%key-OutboundDelivery
                                 OutboundDeliveryItem  = <update_ls_sales_auto>-%key-OutboundDeliveryItem
                                 BillingDocument       = <update_ls_sales_auto>-%key-BillingDocument
                                 BillingDocumentItem   = <update_ls_sales_auto>-%key-BillingDocumentItem   ] TO FIELD-SYMBOL(<ls_sales_auto>).
        IF sy-subrc = 0.
          lv_nchar10 = <update_ls_sales_auto>-ForwadingAgent.
          APPEND VALUE #( salesorder     = <update_ls_sales_auto>-SalesOrder
                          salesorderitem = <update_ls_sales_auto>-SalesOrderItem
                          quantity       = COND #( WHEN <update_ls_sales_auto>-%control-Quantity = '01'
                                                   THEN <update_ls_sales_auto>-Quantity ELSE <ls_sales_auto>-quantity  )
                          quantityunit   = COND #( WHEN <update_ls_sales_auto>-%control-quantityunit = '01'
                                                   THEN <update_ls_sales_auto>-quantityunit ELSE <ls_sales_auto>-quantityunit  )
                          route          = COND #( WHEN <update_ls_sales_auto>-%control-route = '01'
                                                   THEN <update_ls_sales_auto>-route ELSE <ls_sales_auto>-route  )
                          vehicleno      = COND #( WHEN <update_ls_sales_auto>-%control-vehicleno = '01'
                                                   THEN <update_ls_sales_auto>-vehicleno ELSE <ls_sales_auto>-vehicleno )
                          TransporterName = COND #( WHEN <update_ls_sales_auto>-%control-TransporterName = '01'
                                                    THEN <update_ls_sales_auto>-TransporterName ELSE <ls_sales_auto>-TransporterName )
                          DriverName      = COND #( WHEN <update_ls_sales_auto>-%control-DriverName = '01'
                                                    THEN <update_ls_sales_auto>-DriverName ELSE <ls_sales_auto>-DriverName )
                          DriverLicenceNo = COND #( WHEN <update_ls_sales_auto>-%control-DriverLicenceNo = '01'
                                                    THEN <update_ls_sales_auto>-DriverLicenceNo ELSE <ls_sales_auto>-DriverLicenceNo )
                          ForwadingAgent = COND #( WHEN <update_ls_sales_auto>-%control-ForwadingAgent = '01'
                                                   THEN lv_nchar10 ELSE <ls_sales_auto>-ForwadingAgent )
                          PackingDetails = COND #( WHEN <update_ls_sales_auto>-%control-PackingDetails = '01'
                                                   THEN <update_ls_sales_auto>-PackingDetails ELSE <ls_sales_auto>-PackingDetails ) ) TO lt_zsales_auto_inp.
        ENDIF.
*      lt_zsales_auto_inp = CORRESPONDING #( <update_ls_sales_auto> ).
      ENDLOOP.
      IF lt_zsales_auto_inp IS NOT INITIAL.
        MODIFY zsales_auto_inp FROM TABLE @lt_zsales_auto_inp.
      ENDIF.
    ENDIF.
*    IF zcl_eway_integration_util=>mt_compliance[] IS NOT INITIAL.
*      MODIFY zzeinv_cockpit FROM TABLE @zcl_eway_integration_util=>mt_compliance.
*    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZC_SALE_AUTO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_sale_auto RESULT result.
    METHODS createsuccessordocs FOR MODIFY
      IMPORTING keys FOR ACTION zc_sale_auto~createsuccessordocs RESULT result.
    METHODS precheck_createsuccessordocs FOR PRECHECK
      IMPORTING keys FOR ACTION zc_sale_auto~createsuccessordocs.
    METHODS generateeinvoice FOR MODIFY
      IMPORTING keys FOR ACTION zc_sale_auto~generateeinvoice .
    METHODS generateewaybill FOR MODIFY
      IMPORTING keys FOR ACTION zc_sale_auto~generateewaybill .
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR zc_sale_auto RESULT result.

*    METHODS canceleinvoice FOR MODIFY
*      IMPORTING keys FOR ACTION zc_sale_auto~canceleinvoice.
*
*    METHODS downloadeinvoice FOR MODIFY
*      IMPORTING keys FOR ACTION zc_sale_auto~downloadeinvoice RESULT result.

ENDCLASS.

CLASS lhc_ZC_SALE_AUTO IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD CreateSuccessorDocs.
    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
    ENTITY zc_sale_auto
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_sales_auto)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).
    IF lt_sales_auto IS INITIAL.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
        APPEND VALUE #( %tky = <ls_key>-%tky
                                        %msg = new_message(
                                        id       = 'ZO2C_SALES_AUTO_MSG'
                                        number   = '000'
                                        severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.
      ENDLOOP.
    ENDIF.
    DATA:
      l_in_tab TYPE cl_abap_parallel=>t_in_inst_tab,
      l_inst   TYPE REF TO zcl_sales_auto_utility.

    APPEND NEW zcl_sales_auto_utility( it_sales_auto = lt_sales_auto
                                       is_crt_sucr_keys = keys ) TO l_in_tab.

    DATA(l_ref) = NEW cl_abap_parallel( ).
    l_ref->run_inst( EXPORTING p_in_tab = l_in_tab IMPORTING p_out_tab = DATA(l_out_tab) ).

    LOOP AT l_out_tab ASSIGNING FIELD-SYMBOL(<l_out>) WHERE inst IS NOT INITIAL.
      l_inst ?= <l_out>-inst.
      reported = l_inst->mt_sales_auto_ear_reported.
      mapped   = l_inst->mt_sales_auto_ear_mapped.
    ENDLOOP.
*    IF mapped IS NOT INITIAL.
*      READ ENTITIES OF zc_sale_auto IN LOCAL MODE
*      ENTITY zc_sale_auto
*      ALL FIELDS WITH CORRESPONDING #( mapped-zc_sale_auto )
*      RESULT DATA(lt_sales_auto_updated)
*      FAILED DATA(lt_rfailed)
*      REPORTED DATA(lt_rreported).
*    ENDIF.
    LOOP AT lt_sales_auto ASSIGNING FIELD-SYMBOL(<ls_result>).
      APPEND VALUE #(
      %key = <ls_result>-%key
      %param  = CORRESPONDING #( <ls_result> ) ) TO result.
    ENDLOOP.
    IF reported IS INITIAL.
      LOOP AT keys ASSIGNING <ls_key>.
        APPEND VALUE #( %tky = <ls_key>-%tky
                                        %msg = new_message(
                                        id       = 'ZO2C_SALES_AUTO_MSG'
                                        number   = '001'
                                        severity = if_abap_behv_message=>severity-success ) ) TO reported-zc_sale_auto.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD precheck_CreateSuccessorDocs.
    DATA: lv_reminder TYPE p LENGTH 10 DECIMALS 2.
    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
      ENTITY zc_sale_auto
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sales_auto).

    LOOP AT lt_sales_auto ASSIGNING FIELD-SYMBOL(<ls_sales_auto>).
      ASSIGN keys[ salesorder     = <ls_sales_auto>-SalesOrder
                   salesorderitem = <ls_sales_auto>-SalesOrderItem
                   outbounddelivery = <ls_sales_auto>-OutboundDelivery
                   outbounddeliveryitem = <ls_sales_auto>-OutboundDeliveryItem
                   billingdocument = <ls_sales_auto>-BillingDocument
                   billingdocumentitem = <ls_sales_auto>-BillingDocumentItem ] TO FIELD-SYMBOL(<ls_key>).
      IF sy-subrc = 0.
        SELECT SINGLE DeliveryBlockReason, HeaderBillingBlockReason
        FROM I_SalesDocument
        WHERE SalesDocument = @<ls_sales_auto>-SalesOrder
        INTO @DATA(ls_salesdoc_block).
        IF sy-subrc = 0.
          IF ( ls_salesdoc_block-DeliveryBlockReason IS NOT INITIAL OR
                                ls_salesdoc_block-HeaderBillingBlockReason IS NOT INITIAL ).
            APPEND VALUE #( %key = <ls_key>-%key
                                       %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                           number   = '000'
                                                           v1       = 'Sales order is blocked'
                                                           severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

            APPEND VALUE #( %key = <ls_key>-%key
                            %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
            RETURN.
          ENDIF.
        ENDIF.
        IF "<ls_sales_auto>-Route IS INITIAL OR
           <ls_sales_auto>-Quantity IS INITIAL OR
           <ls_sales_auto>-QuantityUnit IS INITIAL OR
           <ls_sales_auto>-VehicleNo IS INITIAL.
*           <ls_sales_auto>-TransporterName IS INITIAL OR
*           <ls_sales_auto>-DriverName IS INITIAL OR
*           <ls_sales_auto>-DriverLicenceNo IS INITIAL OR
*           <ls_sales_auto>-ForwadingAgent IS INITIAL.
          APPEND VALUE #( %key = <ls_key>-%key
                                 %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                     number   = '000'
                                                     v1       = 'Please first fill all mandatory fields in editmode'
                                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.

        ENDIF.

        DATA(lv_conditionrecordrate) = zcl_query_cond_record_rate=>get_conditionratevalue( iv_material            = <ls_sales_auto>-material
                                                                                           iv_salesorganization   = <ls_sales_auto>-salesorganization
                                                                                           iv_soldtoparty         = <ls_sales_auto>-soldtoparty
                                                                                           iv_distributionchannel = <ls_sales_auto>-distributionchannel
                                                                                           iv_salesordertype      = <ls_sales_auto>-salesordertype
                                                                                           iv_division            = <ls_sales_auto>-Division
*                                                                                           iv_yy1_ablad_sdi       = <ls_sales_auto>-yy1_ablad_sdi
                                                                                            ).
        IF <ls_sales_auto>-NetPriceAmount <> lv_conditionrecordrate.
          IF NOT ( <ls_sales_auto>-SalesOrganization = '1000' AND
                   <ls_sales_auto>-DistributionChannel = '10' AND
                   <ls_sales_auto>-Division = '90' ).
            APPEND VALUE #( %key = <ls_key>-%key
                               %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                   number   = '000'
                                                   v1       = 'SO rate not matched with condition record rate'
                                                   severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

            APPEND VALUE #( %key = <ls_key>-%key
                            %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
            RETURN.
          ENDIF.
        ENDIF.

        IF <ls_sales_auto>-OutboundDelivery IS NOT INITIAL.
          APPEND VALUE #( %key = <ls_key>-%key
                                 %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                     number   = '000'
                                                     v1       = 'Outbound delivery already created'
                                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.
        ENDIF.

        IF <ls_sales_auto>-quantity > <ls_sales_auto>-MaterialCurrentStock.
          APPEND VALUE #( %key = <ls_key>-%key
                               %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                   number   = '000'
                                                   v1       = 'Stock is not avaliable at current location'
                                                   severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.
        ENDIF.
        IF <ls_sales_auto>-MaxQty IS NOT INITIAL AND <ls_sales_auto>-quantity > <ls_sales_auto>-MaxQty.
          APPEND VALUE #( %key = <ls_key>-%key
                                 %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                     number   = '000'
                                                     v1       = |Quantity { <ls_sales_auto>-quantity } is more than max. allow qty { <ls_sales_auto>-MaxQty }|
                                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.
        ENDIF.
        IF <ls_sales_auto>-UnitPer IS NOT INITIAL.
          lv_reminder = <ls_sales_auto>-quantity MOD <ls_sales_auto>-UnitPer.
          IF lv_reminder IS NOT INITIAL.
            APPEND VALUE #( %key = <ls_key>-%key
                                   %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                       number   = '000'
                                                       v1       = 'Please maintain quantity in multiply of '
                                                       v2       = | { <ls_sales_auto>-UnitPer }.|
*                                                       v3       = CONV #( lv_reminder )
                                                       severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

            APPEND VALUE #( %key = <ls_key>-%key
                            %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
            RETURN.
          ENDIF.
        ENDIF.
        IF <ls_sales_auto>-IGST_rate IS NOT INITIAL AND ( <ls_sales_auto>-SGST_rate IS NOT INITIAL OR <ls_sales_auto>-CGST_rate IS NOT INITIAL ).
          APPEND VALUE #( %key = <ls_key>-%key
                                 %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                     number   = '000'
                                                     v1       = 'IGST rate is maintained along with S/CGST rate'
                                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.
        ENDIF.
        IF  <ls_sales_auto>-SGST_rate <> <ls_sales_auto>-CGST_rate.
          APPEND VALUE #( %key = <ls_key>-%key
                                 %msg = new_message( id       = 'ZO2C_SALES_AUTO'
                                                     number   = '000'
                                                     v1       = 'SGST rate not matching with CGST rate'
*                                                       v2       = | { <ls_sales_auto>-UnitPer }.|
*                                                       v3       = CONV #( lv_reminder )
                                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_sale_auto.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD GenerateEinvoice.

    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
          ENTITY zc_sale_auto
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_sales_einvoice)
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).

    IF lt_sales_einvoice IS INITIAL.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
        APPEND VALUE #( %tky = <ls_key>-%tky
                        %msg = new_message(
                                 id       = 'ZO2C_SALES_AUTO_MSG'
                                 number   = '000'
                                 severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.
      ENDLOOP.
    ELSE.
*      DATA:ls_ewaybill TYPE zzewaybill.commented by trupti7

*      zcl_eway_integration_util=>get_instance(
*        RECEIVING
*          ro_eway_util = DATA(lo_eway_util)
*      ).
*
*      lo_eway_util->get_token(
*        IMPORTING
*          ev_token  = DATA(lv_token)
*          et_return = DATA(lt_return)
*      ).

*      IF lv_token IS NOT INITIAL.
*
*        " --- LOOP START ---
*        LOOP AT lt_sales_einvoice INTO DATA(ls_sales_einvoice).
*
*          lo_eway_util->get_einv_data(
*            EXPORTING
*              token                  = lv_token
*              iv_company_code        = '0000'
*              iv_fiscal_year         = '0000'
*              iv_billingdocument     = ls_sales_einvoice-BillingDocument
*            IMPORTING
*              einv_payload           = DATA(LS_einv_payload)
*              einv_payload_structure = DATA(LS_einv_payload_structure)
*              BillingDocument    = DATA(ls_BillingDocument)
*              et_return              = DATA(lt_report)
*          ).
*
*          IF LS_einv_payload IS NOT INITIAL AND lt_return IS INITIAL.
*            lo_eway_util->generate_einv(
*              EXPORTING
*                einv_payload = LS_einv_payload
*                einv_payload_structure = LS_einv_payload_structure
*              IMPORTING
*                einv_number  = DATA(Ls_einv_number)
*                et_return    = DATA(LT_einv_return)
*            ).
*            APPEND LINES OF LT_einv_return TO lt_return.
*          ELSE.
*            LOOP AT lt_return INTO DATA(ls_return).
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*
*          IF Ls_einv_number-results-message-irn IS NOT INITIAL.
*            " --- Map Response to Compliance Table Structure ---
*            DATA: ls_compliance TYPE zzeinv_cockpit.
*            ls_compliance-docno         = ls_sales_einvoice-BillingDocument.
*            ls_compliance-bukrs         = ls_BillingDocument-CompanyCode.
*            ls_compliance-doc_year      = ls_BillingDocument-BillingDocumentDate+0(4).
*            ls_compliance-doc_type      = ls_BillingDocument-BillingDocumentType.
*            ls_compliance-odn           = ls_BillingDocument-DocumentReferenceID.
*            ls_compliance-odn_date      = ls_BillingDocument-BillingDocumentDate.
*            ls_compliance-ack_no        = Ls_einv_number-results-message-AckNo.
*            ls_compliance-irn           = Ls_einv_number-results-message-Irn.
*            ls_compliance-irn_status    = Ls_einv_number-results-message-Status.
*            ls_compliance-signed_inv    = Ls_einv_number-results-message-SignedInvoice.
*            ls_compliance-signed_qrcode = Ls_einv_number-results-message-SignedQRCode.
*            ls_compliance-einv_ernam    = sy-uname.
*            GET TIME STAMP FIELD ls_compliance-einv_erdat.
*
*            " Date Conversion: API (YYYY-MM-DD HH:MM:SS) -> SAP (YYYYMMDD)
*            IF Ls_einv_number-results-message-AckDt IS NOT INITIAL.
*              DATA(lv_ack_ts) = Ls_einv_number-results-message-AckDt.
*              REPLACE ALL OCCURRENCES OF '-' IN lv_ack_ts WITH ''.
*              REPLACE ALL OCCURRENCES OF ':' IN lv_ack_ts WITH ''.
*              ls_compliance-ack_date = lv_ack_ts(8).
*            ENDIF.
*
*            " E-Way Bill Mapping
*            IF Ls_einv_number-results-message-EwbNo IS NOT INITIAL.
*              ls_compliance-eway_bill_no = Ls_einv_number-results-message-EwbNo.
*              ls_compliance-eway_status  = 'A'. " Active
*              ls_compliance-eway_ernam   = sy-uname.
*
*              " EWB Date Conversion
*              IF Ls_einv_number-results-message-EwbDt IS NOT INITIAL.
*                DATA(lv_ewb_ts) = Ls_einv_number-results-message-EwbDt.
*                REPLACE ALL OCCURRENCES OF '-' IN lv_ewb_ts WITH ''.
*                ls_compliance-eway_erdat = lv_ewb_ts(8).
*              ENDIF.
*
*              " EWB Validity Date Conversion
*              IF Ls_einv_number-results-message-EwbValidTill IS NOT INITIAL.
*                DATA(lv_valid_ts) = Ls_einv_number-results-message-EwbValidTill.
*                REPLACE ALL OCCURRENCES OF '-' IN lv_valid_ts WITH ''.
*                ls_compliance-vdtodate = lv_valid_ts(8).
*              ENDIF.
*            ENDIF.
*
*            APPEND ls_compliance TO zcl_eway_integration_util=>MT_compliance.
*
*            APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                             %msg             = new_message_with_text(
*                                     text     = Ls_einv_number-results-message-alert
*                                     severity = if_abap_behv_message=>severity-information
*                                    )
*                           ) TO reported-zc_sale_auto.
*          ELSE.
*            LOOP AT lt_return INTO ls_return.
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*        ENDLOOP. " <--- THIS WAS MISSING
*        " --- LOOP END ---
*
*      ENDIF. " Closes IF lv_token IS NOT INITIAL
    ENDIF. " Closes IF lt_sales_einvoice IS INITIAL
  ENDMETHOD.

  METHOD GenerateEwayBill.
*    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
*        ENTITY zc_sale_auto
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_sales_einvoice)
*        FAILED DATA(lt_failed)
*        REPORTED DATA(lt_reported).
*
*    IF lt_sales_einvoice IS INITIAL.
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
*        APPEND VALUE #( %tky = <ls_key>-%tky
*                        %msg = new_message(
*                                 id       = 'ZO2C_SALES_AUTO_MSG'
*                                 number   = '000'
*                                 severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.
*      ENDLOOP.
*    ELSE.
*      DATA:ls_ewaybill TYPE zzewaybill.
*      SELECT bukrs,docno,docyear,doctype,irn,ewaybillno,ewaystatus FROM zzeinv_cockpit_i
*      FOR ALL ENTRIES IN @lt_sales_einvoice
*      WHERE docno = @lt_sales_einvoice-billingdocument
*      INTO TABLE @DATA(lt_einv_cockpit).
*      zcl_eway_integration_util=>get_instance(
*        RECEIVING
*          ro_eway_util = DATA(lo_eway_util)
*      ).
*
*      lo_eway_util->get_token(
*        IMPORTING
*          ev_token  = DATA(lv_token)
*          et_return = DATA(lt_return)
*      ).
*
*      IF lv_token IS NOT INITIAL.
*
*        " --- LOOP START ---
*        LOOP AT lt_sales_einvoice INTO DATA(ls_sales_einvoice).
*          READ  TABLE lt_einv_cockpit INTO DATA(ls_cockpit) WITH KEY docno = ls_sales_einvoice-billingdocument.
*          lo_eway_util->get_ewaybill_by_irn_data(
*            EXPORTING
*              iv_billing_doc  = ls_sales_einvoice-BillingDocument
*              iv_irn          = CONV #( ls_cockpit-irn )
*              iv_token        = lv_token
*            IMPORTING
*              rs_input        = DATA(LS_eway_input)
*              eway_payload    = DATA(LS_eway_payload)
*          ).
*
*          IF LS_eway_payload IS NOT INITIAL AND lt_return IS INITIAL.
*            lo_eway_util->generate_ewaybill_by_irn_data(
*              EXPORTING
*                ewaybill_by_irn_payload = LS_eway_payload
*                IMPORTING
*                einv_number  = DATA(Ls_einv_number)
*                et_return    = DATA(LT_einv_return)
*            ).
*            APPEND LINES OF LT_einv_return TO lt_return.
*          ELSE.
*            LOOP AT lt_return INTO DATA(ls_return).
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*
*          IF Ls_einv_number-results-message-irn IS NOT INITIAL.
*            " --- Map Response to Compliance Table Structure ---
*            DATA: ls_compliance TYPE zzeinv_cockpit.
**            ls_compliance-docno         = ls_sales_einvoice-BillingDocument.
**            ls_compliance-bukrs         = ls_BillingDocument-CompanyCode.
**            ls_compliance-doc_year      = ls_BillingDocument-BillingDocumentDate+0(4).
**            ls_compliance-doc_type      = ls_BillingDocument-BillingDocumentType.
**            ls_compliance-odn           = ls_BillingDocument-DocumentReferenceID.
**            ls_compliance-odn_date      = ls_BillingDocument-BillingDocumentDate.
**            ls_compliance-ack_no        = Ls_einv_number-results-message-AckNo.
**            ls_compliance-irn           = Ls_einv_number-results-message-Irn.
**            ls_compliance-irn_status    = Ls_einv_number-results-message-Status.
**            ls_compliance-signed_inv    = Ls_einv_number-results-message-SignedInvoice.
**            ls_compliance-signed_qrcode = Ls_einv_number-results-message-SignedQRCode.
**            ls_compliance-einv_ernam    = sy-uname.
**            GET TIME STAMP FIELD ls_compliance-einv_erdat.
**
**            " Date Conversion: API (YYYY-MM-DD HH:MM:SS) -> SAP (YYYYMMDD)
**            IF Ls_einv_number-results-message-AckDt IS NOT INITIAL.
**              DATA(lv_ack_ts) = Ls_einv_number-results-message-AckDt.
**              REPLACE ALL OCCURRENCES OF '-' IN lv_ack_ts WITH ''.
**              REPLACE ALL OCCURRENCES OF ':' IN lv_ack_ts WITH ''.
**              ls_compliance-ack_date = lv_ack_ts(8).
**            ENDIF.
*
*            " E-Way Bill Mapping
*            IF Ls_einv_number-results-message-EwbNo IS NOT INITIAL.
*              ls_compliance-eway_bill_no = Ls_einv_number-results-message-EwbNo.
*              ls_compliance-eway_status  = 'A'. " Active
*              ls_compliance-eway_ernam   = sy-uname.
*
*              " EWB Date Conversion
*              IF Ls_einv_number-results-message-EwbDt IS NOT INITIAL.
*                DATA(lv_ewb_ts) = Ls_einv_number-results-message-EwbDt.
*                REPLACE ALL OCCURRENCES OF '-' IN lv_ewb_ts WITH ''.
*                ls_compliance-eway_erdat = lv_ewb_ts(8).
*              ENDIF.
*
*              " EWB Validity Date Conversion
*              IF Ls_einv_number-results-message-EwbValidTill IS NOT INITIAL.
*                DATA(lv_valid_ts) = Ls_einv_number-results-message-EwbValidTill.
*                REPLACE ALL OCCURRENCES OF '-' IN lv_valid_ts WITH ''.
*                ls_compliance-vdtodate = lv_valid_ts(8).
*              ENDIF.
*            ENDIF.
*
*            APPEND ls_compliance TO zcl_eway_integration_util=>MT_compliance.
*
*            APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                             %msg             = new_message_with_text(
*                                     text     = Ls_einv_number-results-message-alert
*                                     severity = if_abap_behv_message=>severity-information
*                                    )
*                           ) TO reported-zc_sale_auto.
*          ELSE.
*            LOOP AT lt_return INTO ls_return.
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*
*          IF lt_return[] IS NOT INITIAL.
*            MOVE-CORRESPONDING lt_return TO zmm_cl_creditnotegr=>mt_return .
*          ENDIF.
*
*        ENDLOOP. " <--- THIS WAS MISSING
*        " --- LOOP END ---
*
*      ENDIF. " Closes IF lv_token IS NOT INITIAL
*    ENDIF. " Closes IF lt_sales_einvoice IS INITIAL
*  ENDMETHOD.
*
*  METHOD get_instance_features.
  ENDMETHOD.

*  METHOD CancelEinvoice.
*    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
*          ENTITY zc_sale_auto
*          ALL FIELDS WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_sales_einvoice)
*          FAILED DATA(lt_failed)
*          REPORTED DATA(lt_reported).
*
*    IF lt_sales_einvoice IS INITIAL.
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
*        APPEND VALUE #( %tky = <ls_key>-%tky
*                        %msg = new_message(
*                                 id       = 'ZO2C_SALES_AUTO_MSG'
*                                 number   = '000'
*                                 severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.
*      ENDLOOP.
*    ELSE.
*
*      SELECT bukrs,docno,docyear,doctype,irn,ewaybillno,ewaystatus FROM zzeinv_cockpit_i
*      FOR ALL ENTRIES IN @lt_sales_einvoice
*      WHERE docno = @lt_sales_einvoice-billingdocument
*      INTO TABLE @DATA(lt_einv_cockpit).
*      zcl_eway_integration_util=>get_instance(
*        RECEIVING
*          ro_eway_util = DATA(lo_eway_util)
*      ).
*
*      lo_eway_util->get_token(
*        IMPORTING
*          ev_token  = DATA(lv_token)
*          et_return = DATA(lt_return)
*      ).
*
*      IF lv_token IS NOT INITIAL.
*
*        " --- LOOP START ---
*        LOOP AT keys INTO DATA(ls_key).
*          READ  TABLE lt_einv_cockpit INTO DATA(ls_cockpit) WITH KEY docno = ls_key-BillingDocument.
*          lo_eway_util->get_cancellation_data(
*            EXPORTING
*              is_input = VALUE #( access_token    = lv_token
*                                  user_gstin      = ''
*                                  irn             = ls_cockpit-irn
*                                  cancel_reason   = ls_key-%param-CancelRsn
*                                  cancel_remarks  = ls_key-%param-CancelRemark
*                                  action          = ls_key-%param-CancelType )
*                                  RECEIVING
*                                  rv_json  = DATA(Einvoice_cancel_payload)
*                                              ).
*          IF Einvoice_cancel_payload IS NOT INITIAL AND lt_return IS INITIAL.
*            lo_eway_util->cancel_einv(
*              EXPORTING
*                einv_cancel_payload = Einvoice_cancel_payload
*              IMPORTING
*                einv_number         = DATA(ls_einv_cancel)
*                et_return           = DATA(lt_cancel_return)
*            ).
*            APPEND LINES OF lt_cancel_return TO lt_return.
*          ELSE.
*            LOOP AT lt_return INTO DATA(ls_return).
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*
*          IF ls_einv_cancel-results-message-irn IS NOT INITIAL.
*            " --- Map Response to Compliance Table Structure ---
*            DATA: ls_compliance TYPE zzeinv_cockpit.
**            ls_compliance-docno         = ls_sales_einvoice-BillingDocument.
**            ls_compliance-bukrs         = ls_BillingDocument-CompanyCode.
**            ls_compliance-doc_year      = ls_BillingDocument-BillingDocumentDate+0(4).
**            ls_compliance-doc_type      = ls_BillingDocument-BillingDocumentType.
**            ls_compliance-odn           = ls_BillingDocument-DocumentReferenceID.
**            ls_compliance-odn_date      = ls_BillingDocument-BillingDocumentDate.
**            ls_compliance-ack_no        = Ls_einv_number-results-message-AckNo.
**            ls_compliance-irn           = Ls_einv_number-results-message-Irn.
**            ls_compliance-irn_status    = Ls_einv_number-results-message-Status.
**            ls_compliance-signed_inv    = Ls_einv_number-results-message-SignedInvoice.
**            ls_compliance-signed_qrcode = Ls_einv_number-results-message-SignedQRCode.
**            ls_compliance-einv_ernam    = sy-uname.
**            GET TIME STAMP FIELD ls_compliance-einv_erdat.
**
**            " Date Conversion: API (YYYY-MM-DD HH:MM:SS) -> SAP (YYYYMMDD)
**            IF Ls_einv_number-results-message-AckDt IS NOT INITIAL.
**              DATA(lv_ack_ts) = Ls_einv_number-results-message-AckDt.
**              REPLACE ALL OCCURRENCES OF '-' IN lv_ack_ts WITH ''.
**              REPLACE ALL OCCURRENCES OF ':' IN lv_ack_ts WITH ''.
**              ls_compliance-ack_date = lv_ack_ts(8).
**            ENDIF.
*
*            " E-Way Bill Mapping
**            IF Ls_einv_number-results-message-EwbNo IS NOT INITIAL.
**              ls_compliance-eway_bill_no = Ls_einv_number-results-message-EwbNo.
**              ls_compliance-eway_status  = 'A'. " Active
**              ls_compliance-eway_ernam   = sy-uname.
**
**              " EWB Date Conversion
**              IF Ls_einv_number-results-message-EwbDt IS NOT INITIAL.
**                DATA(lv_ewb_ts) = Ls_einv_number-results-message-EwbDt.
**                REPLACE ALL OCCURRENCES OF '-' IN lv_ewb_ts WITH ''.
**                ls_compliance-eway_erdat = lv_ewb_ts(8).
**              ENDIF.
**
**              " EWB Validity Date Conversion
**              IF Ls_einv_number-results-message-EwbValidTill IS NOT INITIAL.
**                DATA(lv_valid_ts) = Ls_einv_number-results-message-EwbValidTill.
**                REPLACE ALL OCCURRENCES OF '-' IN lv_valid_ts WITH ''.
**                ls_compliance-vdtodate = lv_valid_ts(8).
**              ENDIF.
**            ENDIF.
**
**            APPEND ls_compliance TO zcl_eway_integration_util=>MT_compliance.
*
*            APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                             %msg             = new_message_with_text(
*                                     text     = ls_einv_cancel-results-message-alert
*                                     severity = if_abap_behv_message=>severity-information
*                                    )
*                           ) TO reported-zc_sale_auto.
*          ELSE.
*            LOOP AT lt_return INTO ls_return.
*              APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                              %msg = new_message_with_text(
*                                       severity = if_abap_behv_message=>severity-error
*                                       text     = ls_return-message
*                                     )
*                            ) TO reported-zc_sale_auto.
*            ENDLOOP.
*          ENDIF.
*
*          IF lt_return[] IS NOT INITIAL.
*            MOVE-CORRESPONDING lt_return TO zmm_cl_creditnotegr=>mt_return .
*          ENDIF.
*
*        ENDLOOP. " <--- THIS WAS MISSING
*        " --- LOOP END ---
*
*      ENDIF. " Closes IF lv_token IS NOT INITIAL
*    ENDIF. " Closes IF lt_sales_einvoice IS INITIAL
*  ENDMETHOD.

*  METHOD DownloadEinvoice.
*    READ ENTITIES OF zc_sale_auto IN LOCAL MODE
*            ENTITY zc_sale_auto
*            ALL FIELDS WITH CORRESPONDING #( keys )
*            RESULT DATA(lt_sales_einvoice)
*            FAILED DATA(lt_failed)
*            REPORTED DATA(lt_reported).
*
*    IF lt_sales_einvoice IS INITIAL.
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
*        APPEND VALUE #( %tky = <ls_key>-%tky
*                        %msg = new_message(
*                                 id       = 'ZO2C_SALES_AUTO_MSG'
*                                 number   = '000'
*                                 severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_sale_auto.
*      ENDLOOP.
*    ELSE.
*
*      zcl_eway_integration_util=>get_instance(
*        RECEIVING
*          ro_eway_util = DATA(lo_eway_util)
*      ).
*      " --- LOOP START ---
*      LOOP AT lt_sales_einvoice INTO DATA(ls_sales_einvoice).
*
*        lo_eway_util->get_einv_data(
*          EXPORTING
*            token                  = ''
*            iv_company_code        = '0000'
*            iv_fiscal_year         = '0000'
*            iv_billingdocument     = ls_sales_einvoice-BillingDocument
*          IMPORTING
*            einv_payload           = DATA(LS_einv_payload)
*            einv_payload_structure = DATA(LS_einv_payload_structure)
*            et_return              = DATA(lt_return)
*        ).
*
*        IF LS_einv_payload IS NOT INITIAL AND lt_return IS INITIAL.
*          APPEND VALUE #(
*           SalesOrder     = ls_sales_einvoice-SalesOrder
*           SalesOrderItem         = ls_sales_einvoice-SalesOrderItem
*           OutboundDelivery     = ls_sales_einvoice-OutboundDelivery
*           OutboundDeliveryItem                  = ls_sales_einvoice-OutboundDeliveryItem
*           BillingDocument              = ls_sales_einvoice-BillingDocument
*           BillingDocumentItem              = ls_sales_einvoice-BillingDocumentItem
*           %param = VALUE #( EwayPayloaddwnld   = LS_einv_payload  )  ) TO result .
*        ELSE.
*          LOOP AT lt_return INTO DATA(ls_return).
*            APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                            %msg = new_message_with_text(
*                                     severity = if_abap_behv_message=>severity-error
*                                     text     = ls_return-message
*                                   )
*                          ) TO reported-zc_sale_auto.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.

ENDCLASS.
