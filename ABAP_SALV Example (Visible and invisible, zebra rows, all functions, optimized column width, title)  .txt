FORM alv_output.

  DATA: lo_salv     TYPE REF TO  cl_salv_table,
        lo_function TYPE REF TO  cl_salv_functions,
        lo_column   TYPE REF TO  cl_salv_column,
        lt_cols     TYPE         salv_t_column_ref,
        ls_cols     LIKE LINE OF lt_cols.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv
                              CHANGING  t_table      = t_mat ).

      "Set columns visible or invisible
      lt_cols = lo_salv->get_columns( )->get( ).

      LOOP AT lt_cols INTO ls_cols.
        lo_column ?= ls_cols-r_column.    "Narrow casting
        CASE ls_cols-columnname.
          WHEN 'MATNR' OR 'MAKTX' OR 'MTART' OR 'SPART' OR 'ZZKLS' OR 'LVORM' OR 'DISPO' OR 'ERSDA' OR 'LOSGR' OR
               'AAGBB' OR 'MGVBR' OR 'STPRS' OR 'LBKUM' OR 'SALK3'.
            lo_column->set_visible( 'X' ).
          WHEN OTHERS.
            lo_column->set_visible( space ).
        ENDCASE.
      ENDLOOP.

      lo_salv->get_functions( )->set_all( 'X' ).                                 "All AlV function enabled
      lo_salv->get_columns( )->set_optimize( ).                                  "Optimized column width
      lo_salv->get_display_settings( )->set_striped_pattern( 'X' ).              "Zebra rows
      lo_salv->get_display_settings( )->set_list_header( 'Z_MARCI_ZCSVLICO' ).   "Title

      lo_salv->display( ).

    CATCH cx_salv_msg.

      RETURN.

  ENDTRY.

ENDFORM.