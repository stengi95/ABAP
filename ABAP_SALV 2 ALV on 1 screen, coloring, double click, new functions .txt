REPORT z_two_salv_on_one_screen.

TYPES: BEGIN OF ty_sbook.
    INCLUDE STRUCTURE sbook.
TYPES: color TYPE lvc_t_scol, " For cell or row coloring
       END OF ty_sbook.

TYPES: BEGIN OF ty_sflight .
    INCLUDE STRUCTURE sflight.
TYPES: color TYPE lvc_t_scol, " For cell or row coloring
       END OF ty_sflight.

DATA: gt_sflight    TYPE TABLE OF ty_sflight,
      gs_sflight    LIKE LINE OF gt_sflight,
      gt_sbook      TYPE TABLE OF ty_sbook,
      gs_sbook      LIKE LINE OF gt_sbook,
      gv_ok_code    TYPE syucomm.


CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_double_click_select FOR EVENT if_salv_events_actions_table~double_click OF cl_salv_events_table
      IMPORTING row column,

      on_double_click_info FOR EVENT if_salv_events_actions_table~double_click OF cl_salv_events_table
        IMPORTING row column,

      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.

ENDCLASS.

CLASS lcl_events IMPLEMENTATION.

  METHOD on_double_click_select.

    PERFORM selected_row_color USING row.
    PERFORM bottom_refresh USING row.

  ENDMETHOD.

  METHOD on_double_click_info.

    PERFORM show_cell_info USING row column.

  ENDMETHOD.

  METHOD on_user_command.

    PERFORM handle_user_command USING e_salv_function.

  ENDMETHOD.

ENDCLASS.

SELECT-OPTIONS: so_carr FOR gs_sflight-carrid NO-EXTENSION NO INTERVALS,
                so_conn FOR gs_sflight-connid NO-EXTENSION NO INTERVALS,
                so_flda FOR gs_sflight-fldate NO-EXTENSION NO INTERVALS.


START-OF-SELECTION.

  SELECT *
        FROM sflight
        INTO CORRESPONDING FIELDS OF TABLE gt_sflight.

  SELECT *
        FROM sbook
        INTO CORRESPONDING FIELDS OF TABLE gt_sbook
        WHERE carrid IN so_carr
        AND   connid IN so_conn
        AND   fldate IN so_flda.

  TRY.

      DATA: lo_splitter_main    TYPE REF TO cl_gui_splitter_container,
            lo_container_top    TYPE REF TO cl_gui_container,
            lo_container_bottom TYPE REF TO cl_gui_container.

      "Splitter object
      lo_splitter_main = NEW #( parent = cl_gui_container=>default_screen
                                no_autodef_progid_dynnr = 'X'
                                rows = 2
                                columns = 1 ).

      "Container for the two different SALV
      lo_container_top = lo_splitter_main->get_container( row = 1 column = 1 ).
      lo_container_bottom = lo_splitter_main->get_container( row = 2 column = 1 ).

      "First SALV
      DATA: lo_salv_top        TYPE REF TO cl_salv_table,
            lo_top_salv_events TYPE REF TO cl_salv_events_table.

      cl_salv_table=>factory(  EXPORTING r_container = lo_container_top
                               IMPORTING r_salv_table = lo_salv_top
                               CHANGING  t_table = gt_sflight ).

      lo_top_salv_events = lo_salv_top->get_event( ).
      SET HANDLER lcl_events=>on_double_click_select FOR lo_top_salv_events.

      "Basic alv
      lo_salv_top->get_functions( )->set_all(  'X' ).
      lo_salv_top->get_columns( )->set_optimize(  'X' ).
      lo_salv_top->get_display_settings( )->set_list_header( 'Flights' ).
      lo_salv_top->get_display_settings( )->set_striped_pattern( 'X' ).
      lo_salv_top->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

      "Row coloring
      LOOP AT gt_sflight ASSIGNING FIELD-SYMBOL(<ls_sflight>).
        IF <ls_sflight>-seatsmax = <ls_sflight>-seatsocc.

          <ls_sflight>-color = VALUE #( ( color-col = 6
                                          color-int = 1
                                          color-inv = 0 ) ).
        ENDIF.

      ENDLOOP.

      lo_salv_top->get_columns( )->set_color_column( 'COLOR' ).

      lo_salv_top->display( ).

      "Second SALV
      DATA: lo_salv_bottom        TYPE REF TO cl_salv_table,
            lo_bottom_salv_events TYPE REF TO cl_salv_events_table,
            lo_column             TYPE REF TO cl_salv_column_table,
            lo_functions          TYPE REF TO cl_salv_functions_list,
            ls_cell_color         TYPE        lvc_s_scol.


      cl_salv_table=>factory(  EXPORTING r_container = lo_container_bottom
                               IMPORTING r_salv_table = lo_salv_bottom
                               CHANGING  t_table = gt_sbook ).

      lo_bottom_salv_events = lo_salv_bottom->get_event( ).
      SET HANDLER lcl_events=>on_double_click_info FOR lo_bottom_salv_events.
      SET HANDLER lcl_events=>on_user_command FOR lo_bottom_salv_events.

      lo_functions = lo_salv_bottom->get_functions( ).
      lo_functions->set_all(  'X' ).

      TRY.
          DATA: lv_icon TYPE string.

          lv_icon = icon_sum.

          lo_functions->add_function( name     = 'SELECTALLBOOKINGS'
                                      icon     = lv_icon
                                      text     = 'ALL'
                                      tooltip  = 'Select all bookings'
                                      position = if_salv_c_function_position=>right_of_salv_functions ).
        CATCH cx_salv_wrong_call cx_salv_existing.
      ENDTRY.

      TRY.
          CLEAR lv_icon.
          lv_icon = icon_select_detail.

          lo_functions->add_function( name     = 'SEARCHFORPASSANGER'
                                      icon     = lv_icon
                                      text     = 'Search'
                                      tooltip  = 'Search for passanger'
                                      position = if_salv_c_function_position=>right_of_salv_functions ).
        CATCH cx_salv_wrong_call cx_salv_existing.
      ENDTRY.

      lo_salv_bottom->get_columns( )->set_optimize(  'X' ).
      lo_salv_bottom->get_display_settings( )->set_list_header( 'Bookings' ).
      lo_salv_bottom->get_display_settings( )->set_striped_pattern( 'X' ).
      lo_salv_bottom->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

      "Column coloring
      lo_column ?= lo_salv_bottom->get_columns( )->get_column( 'PASSNAME' ).

      lo_column->set_color( VALUE #( col = 5
                                     int = 1
                                     inv = 0 ) ).

      "Cell color
      PERFORM cell_color_for_smoker.

      lo_salv_bottom->get_columns( )->set_color_column( 'COLOR' ).

      lo_salv_bottom->display( ).

    CATCH cx_salv_msg.
  ENDTRY.

  WRITE: space.


FORM handle_user_command USING i_ucomm TYPE salv_de_function.

  CASE i_ucomm.
    WHEN 'SELECTALLBOOKINGS'.

      PERFORM select_all_bookings.

    WHEN 'SEARCHFORPASSANGER'.

      PERFORM search_for_passanger.

  ENDCASE.

ENDFORM.

FORM cell_color_for_smoker.

          LOOP AT gt_sbook ASSIGNING FIELD-SYMBOL(<ls_sbook>).
        IF <ls_sbook>-smoker = 'X'.

          ls_cell_color-fname = 'SMOKER'.
          ls_cell_color-color =  VALUE #(  col = 6
                                           int = 1
                                           inv = 0 ).

          APPEND ls_cell_color TO <ls_sbook>-color.

        ENDIF.
      ENDLOOP.

ENDFORM.

FORM selected_row_color USING i_row TYPE i.


  PERFORM zebra_and_occupied_colors.

  READ TABLE gt_sflight ASSIGNING FIELD-SYMBOL(<ls_sflight_color>) INDEX i_row.

  <ls_sflight_color>-color = VALUE #( ( color-col = 3
                                        color-int = 1
                                        color-inv = 1 ) ). "Highlight

  lo_salv_top->refresh( ).

ENDFORM.

FORM bottom_refresh USING i_row TYPE i.

  CLEAR gt_sbook.

  READ TABLE gt_sflight
   INTO gs_sflight
   INDEX i_row.

  SELECT * FROM sbook INTO CORRESPONDING FIELDS OF TABLE gt_sbook
    WHERE carrid EQ gs_sflight-carrid
      AND connid EQ gs_sflight-connid
      AND fldate EQ gs_sflight-fldate.

  lo_salv_bottom->refresh( ).

ENDFORM.

FORM show_cell_info USING i_row    TYPE i
                          i_column TYPE lvc_fname.

  MESSAGE i000(0k) WITH 'Column: ' i_column' Row: ' i_row.

ENDFORM.

FORM select_all_bookings.

  PERFORM zebra_and_occupied_colors.

  lo_salv_top->refresh( ).

  CLEAR gt_sbook.

  SELECT *
   FROM sbook
   INTO CORRESPONDING FIELDS OF TABLE gt_sbook.

   PERFORM cell_color_for_smoker.

  lo_salv_bottom->refresh( ).

ENDFORM.

FORM zebra_and_occupied_colors.

  LOOP AT gt_sflight ASSIGNING FIELD-SYMBOL(<ls_sflight>).
    IF sy-tabix MOD 2 EQ 0 AND <ls_sflight>-seatsmax NE <ls_sflight>-seatsocc.

      <ls_sflight>-color = VALUE #( ( color-col = 2
                                      color-int = 1
                                      color-inv = 1 ) ). "Zebra 1

    ELSEIF <ls_sflight>-seatsmax EQ <ls_sflight>-seatsocc.

      <ls_sflight>-color = VALUE #( ( color-col = 6
                                      color-int = 1
                                      color-inv = 0 ) ). "Red

    ELSE.
      <ls_sflight>-color = VALUE #( ( color-col = 2
                                      color-int = 0
                                      color-inv = 0 ) ). "Zebra 2

    ENDIF.

  ENDLOOP.

ENDFORM.

FORM search_for_passanger.

  DATA: gt_sbook_copy TYPE TABLE OF ty_sbook,
        lt_fields TYPE STANDARD TABLE OF sval,
        ls_field  LIKE LINE OF lt_fields,
        lv_answer TYPE c LENGTH 1.

  ls_field = VALUE #( tabname = 'SBOOK'
                      fieldname = 'PASSNAME' ).

  INSERT ls_field INTO TABLE lt_fields.

  CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
    EXPORTING
      popup_title     = 'Passanger search'
      start_column    = '5'
      start_row       = '5'
    IMPORTING
      returncode      = lv_answer
    TABLES
      fields          = lt_fields
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF lv_answer NE 'A'.

    CLEAR ls_field.

    READ TABLE lt_fields INTO ls_field WITH KEY tabname = 'SBOOK' fieldname = 'PASSNAME'.

    CLEAR gt_sbook_copy.

    LOOP AT gt_sbook ASSIGNING FIELD-SYMBOL(<ls_sbook>).

      IF <ls_sbook>-passname = ls_field-value.
        APPEND <ls_sbook> TO gt_sbook_copy.
      ENDIF.

    ENDLOOP.

    IF gt_sbook_copy IS INITIAL. "sy-subrc NE 0.

      MESSAGE i000(0k) WITH 'There is no ' ls_field-value ' in the current selection'.
      RETURN.

    ELSE.

      CLEAR gt_sbook.

      gt_sbook = gt_sbook_copy.

      lo_salv_bottom->refresh(  ).

    ENDIF.

  ELSE. "A'
    RETURN.

  ENDIF.

ENDFORM.