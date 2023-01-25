DATA: gt_sflight TYPE TABLE OF sflight,
      gt_sbook   TYPE TABLE OF sbook.

START-OF-SELECTION.

  SELECT *
        FROM sflight
        INTO CORRESPONDING FIELDS OF TABLE gt_sflight.


  SELECT *
        FROM sbook
        INTO CORRESPONDING FIELDS OF TABLE gt_sbook.

  TRY.

      DATA: lo_splitter_main    TYPE REF TO cl_gui_splitter_container,
            lo_container_top    TYPE REF TO cl_gui_container,
            lo_container_bottom TYPE REF TO cl_gui_container,
            lo_salv_top         TYPE REF TO cl_salv_table,
            lo_salv_bottom      TYPE REF TO cl_salv_table,
            lo_top_salv_events  TYPE REF TO cl_salv_events_table.

      "Splitter object
      lo_splitter_main = NEW #( parent = cl_gui_container=>default_screen
                                no_autodef_progid_dynnr = abap_true
                                rows = 2
                                columns = 1 ).

      "Container for the two different SALV
      lo_container_top = lo_splitter_main->get_container( row = 1 column = 1 ).
      lo_container_bottom = lo_splitter_main->get_container( row = 2 column = 1 ).

      "First SALV
      cl_salv_table=>factory(  EXPORTING r_container = lo_container_top
                               IMPORTING r_salv_table = lo_salv_top
                               CHANGING  t_table = gt_sflight ).

      lo_top_salv_events = lo_salv_top->get_event( ).
      SET HANDLER lcl_events=>on_double_click FOR lo_top_salv_events.

      lo_salv_top->get_functions( )->set_all(  abap_true ).
      lo_salv_top->get_columns( )->set_optimize(  abap_true ).
      lo_salv_top->get_display_settings( )->set_list_header( 'Flights' ).
      lo_salv_top->get_display_settings( )->set_striped_pattern( abap_true ).
      lo_salv_top->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

      lo_salv_top->display( ).

      "Second SALV
      cl_salv_table=>factory(  EXPORTING r_container = lo_container_bottom
                               IMPORTING r_salv_table = lo_salv_bottom
                               CHANGING  t_table = gt_sbook ).

      lo_salv_bottom->get_functions( )->set_all(  abap_true ).
      lo_salv_bottom->get_columns( )->set_optimize(  abap_true ).
      lo_salv_bottom->get_display_settings( )->set_list_header( 'Bookings' ).
      lo_salv_bottom->get_display_settings( )->set_striped_pattern( abap_true ).
      lo_salv_bottom->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

      lo_salv_bottom->display( ).

    CATCH cx_salv_msg.
  ENDTRY.

  "It doesnt work without this:
  WRITE: ' '.
