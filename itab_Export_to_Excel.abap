**************************************************
**      Form  EXPORT_TO_EXCEL
**************************************************
FORM export_to_excel.
  DATA:
    lv_filename     TYPE string,
    lv_fullpath     TYPE string,
    lv_path         TYPE string,
    lv_user_action  TYPE i,
    lv_window_title TYPE string.
**********************************************************************

  TRY.
      cl_gui_frontend_services=>file_save_dialog(
        EXPORTING
          window_title              =   'Export to Excel'
          default_extension         =   'XLSX'
          default_file_name         =   |{ sy-repid }_{ sy-datlo }_{ sy-uzeit }.xlsx|
          file_filter               =   '(*.xls,*.xlsx)|*.xls*'
        CHANGING
          filename                  =    lv_filename
          path                      =    lv_path
          fullpath                  =    lv_fullpath
          user_action               =    lv_user_action
        EXCEPTIONS
          cntl_error                = 1
          error_no_gui              = 2
          not_supported_by_gui      = 3
          invalid_default_file_name = 4
          OTHERS                    = 5   ).
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CASE lv_user_action.
        WHEN 0. "Action OK.
        WHEN 9. "Action cancel.
          MESSAGE TEXT-e01 TYPE 'E'. "Export canceled!
      ENDCASE.


      DATA lo_excel TYPE REF TO zcl_excel.

      DATA(lo_converter) = NEW zcl_excel_converter( ).

      lo_converter->convert( EXPORTING  it_table      =     gt_excel
                             CHANGING   co_excel      =     lo_excel ).

      DATA(lo_excel_worksheet) = lo_excel->get_active_worksheet( ).
      "Overwrite first the header
      lo_excel_worksheet->set_cell( ip_column = 'A' ip_row = 1 ip_value = TEXT-h01 ). "Material
      lo_excel_worksheet->set_cell( ip_column = 'B' ip_row = 1 ip_value = TEXT-h02 ). "Description
      lo_excel_worksheet->set_cell( ip_column = 'C' ip_row = 1 ip_value = TEXT-h03 ). "Material type
      lo_excel_worksheet->set_cell( ip_column = 'D' ip_row = 1 ip_value = TEXT-h04 ). "Base Unit of Measure
      lo_excel_worksheet->set_cell( ip_column = 'E' ip_row = 1 ip_value = TEXT-h05 ). "Plant
      lo_excel_worksheet->set_cell( ip_column = 'F' ip_row = 1 ip_value = TEXT-h06 ). "Row type
      lo_excel_worksheet->set_cell( ip_column = 'G' ip_row = 1 ip_value = jahr1    ).
      lo_excel_worksheet->set_cell( ip_column = 'H' ip_row = 1 ip_value = jahr2    ).
      lo_excel_worksheet->set_cell( ip_column = 'I' ip_row = 1 ip_value = jahr3    ).
      lo_excel_worksheet->set_cell( ip_column = 'J' ip_row = 1 ip_value = jahr4    ).
      lo_excel_worksheet->set_cell( ip_column = 'K' ip_row = 1 ip_value = jahr5    ).
      lo_excel_worksheet->set_cell( ip_column = 'L' ip_row = 1 ip_value = jahr6    ).
      lo_excel_worksheet->set_cell( ip_column = 'M' ip_row = 1 ip_value = jahr7    ).
      lo_excel_worksheet->set_cell( ip_column = 'N' ip_row = 1 ip_value = TEXT-h14 ). "First Class
      lo_excel_worksheet->set_cell( ip_column = 'O' ip_row = 1 ip_value = TEXT-h15 ). "Number of classes

      lo_excel_worksheet->freeze_panes( EXPORTING ip_num_rows = 1 ).

      DATA(lo_excel_writer) = CAST zif_excel_writer( NEW zcl_excel_writer_2007( ) ). "xlsx
      DATA(lv_excel_xdata)  = lo_excel_writer->write_file( lo_excel ).
      DATA(lt_raw_data)     = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_excel_xdata ).

      cl_gui_frontend_services=>gui_download(
        EXPORTING
          filename                  =  lv_filename
          filetype                  = 'BIN'
          bin_filesize              =  xstrlen( lv_excel_xdata )
        CHANGING
          data_tab                  =  lt_raw_data ).

    CATCH cx_root INTO DATA(error_text).

      MESSAGE error_text TYPE 'E'.

  ENDTRY.

  MESSAGE TEXT-s01 TYPE 'S'. "Successful Excel download!

ENDFORM.