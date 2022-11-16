*&---------------------------------------------------------------------*
*& Include          ZEWM_DLV_PRD_C01
*&---------------------------------------------------------------------*
CLASS lcl_demo DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      tt_rng_itemid TYPE RANGE OF /scdl/db_proci_i-itemid.

    CLASS-METHODS:
      main
        IMPORTING iv_docid  TYPE  /scdl/db_proch_i-docid
                  ir_itemid TYPE tt_rng_itemid.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.
  METHOD main.
    DATA: lt_item_key TYPE zcl_ewm_dlv_prd=>tt_item_key.

    IF iv_docid IS INITIAL.
      RETURN.
    ENDIF.

    SELECT hdr~docid, items~itemid
      FROM /scdl/db_proch_i AS hdr
       INNER JOIN /scdl/db_proci_i AS items ON items~docid = hdr~docid
      INTO TABLE @lt_item_key
      WHERE hdr~docid    =  @iv_docid
        AND items~itemid IN @ir_itemid[].

    IF lt_item_key[] IS INITIAL.
      RETURN.
    ENDIF.

    zcl_ewm_dlv_prd=>read_items(
      EXPORTING
        it_item_key = lt_item_key[]
*        iv_lock     = abap_false
*        iv_doccat   = /scdl/if_dl_doc_c=>sc_doccat_inb_prd
      IMPORTING
        et_items    = DATA(lt_items)
        et_dlv_msg  = DATA(lt_dlv_msg) ).

    IF line_exists( lt_dlv_msg[ msgty = wmegc_severity_err ] ).
      cl_demo_output=>display_data( lt_dlv_msg[] ).
      RETURN.
    ENDIF.

    cl_demo_output=>display_data( lt_items[] ).

  ENDMETHOD.
ENDCLASS.
