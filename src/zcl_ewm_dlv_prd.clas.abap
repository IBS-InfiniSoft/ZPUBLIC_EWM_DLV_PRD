class ZCL_EWM_DLV_PRD definition
  public
  final
  create public .

public section.

  types:
    tt_item_key TYPE SORTED TABLE OF /scdl/s_sp_k_item
                   WITH UNIQUE KEY docid itemid .

  class-methods READ_ITEMS
    importing
      !IT_ITEM_KEY type TT_ITEM_KEY
      !IV_LOCK type BOOLE_D default ABAP_FALSE
      !IV_DOCCAT type /SCDL/DL_DOCCAT default /SCDL/IF_DL_DOC_C=>SC_DOCCAT_INB_PRD
    exporting
      !ET_ITEMS type /SCWM/DLV_ITEM_OUT_PRD_TAB
      !ET_DLV_MSG type /SCDL/DM_MESSAGE_TAB .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EWM_DLV_PRD IMPLEMENTATION.


METHOD READ_ITEMS.
* Read Delivery Item ( by default - inbound delivery )
  CLEAR: et_items[],
         et_dlv_msg[].

  IF it_item_key[] IS INITIAL.
    RETURN.
  ENDIF.

  TRY.
      DATA(lo_dlv_manag) = /scwm/cl_dlv_management_prd=>get_instance( ).
      DATA(ls_include) = VALUE /scwm/dlv_query_incl_str_prd(
        item_addmeas  = abap_true
        item_date     = abap_true
        item_partyloc = abap_true
        item_refdoc   = abap_true
        item_status   = abap_true ).

      DATA(ls_options) = VALUE /scwm/dlv_query_contr_str(
        item_part_select = abap_true
        lock_result      = iv_lock
        read_only_locked = COND #( WHEN iv_lock = abap_true THEN abap_true ELSE abap_false )
        ).

      DATA(lt_docid) = CORRESPONDING /scwm/dlv_docid_item_tab( it_item_key ).
      LOOP AT lt_docid ASSIGNING FIELD-SYMBOL(<ls_docid>).
        <ls_docid>-doccat = iv_doccat.
      ENDLOOP.

      lo_dlv_manag->query(
        EXPORTING
          is_include_data = ls_include
          is_read_options = ls_options
          it_docid        = lt_docid[]
          iv_doccat       = iv_doccat
        IMPORTING
          et_items        = DATA(lt_items)
          eo_message      = DATA(lo_message) ).

      et_items[]   = lt_items[].
      et_dlv_msg[] = lo_message->get_messages( ).

    CATCH /scdl/cx_delivery.
      CLEAR et_items[].
      RETURN.
  ENDTRY.

ENDMETHOD.
ENDCLASS.
