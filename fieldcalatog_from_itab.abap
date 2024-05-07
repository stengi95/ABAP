REPORT zca_r_fieldcatalog_from_itab.

CLASS zca_cl_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS create_fieldcatalog_from_itab IMPORTING it_table               TYPE ANY TABLE
                                                RETURNING VALUE(rt_fieldcatalog) TYPE lvc_t_fcat.
ENDCLASS.

CLASS zca_cl_alv IMPLEMENTATION.
  METHOD create_fieldcatalog_from_itab.
    DATA lo_table_desc TYPE REF TO cl_abap_structdescr.
    DATA ls_table_line       TYPE REF TO data.
    DATA lt_field_list TYPE ddfields.

    "Create a line of the input table
    CREATE DATA ls_table_line LIKE LINE OF it_table.
    "Get table description from the the line of the input table
    lo_table_desc = cl_abap_structdescr=describe_by_data_ref( ls_table_line ).
    "Read the structure of the table from table description
    lt_field_list = cl_salv_data_descr=read_structdescr( lo_table_desc ).

    LOOP AT lt_field_list ASSIGNING FIELD-SYMBOL(ls_field_list).

      "Fill Returning field catalog table (TYPE lvc_t_fcat) from the field list.
      APPEND INITIAL LINE TO rt_fieldcatalog ASSIGNING FIELD-SYMBOL(ls_fieldcatalog).
      MOVE-CORRESPONDING ls_field_list TO ls_fieldcatalog.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  "Get data from any table
  SELECT  FROM sflight INTO TABLE @DATA(gt_sflight) UP TO 50 ROWS.

  "Create field catalog from an internal table
  DATA(gt_fieldcatalog) = zca_cl_alv=create_fieldcatalog_from_itab( gt_sflight ).
  "Create and connect GUI container with the custom container of screen 0100.
  DATA(go_container)  = NEW cl_gui_custom_container( container_name = 'GV_CONTAINER_0100' ).
  "Create and connect ALV to GUI container.
  DATA(go_alv_grid) = NEW cl_gui_alv_grid( i_parent = go_container ).
  "Display ABAP List Viewer
  go_alv_grid-set_table_for_first_display( CHANGING it_outtab       = gt_sflight
                                                    it_fieldcatalog = gt_fieldcatalog ).
  "Call Screen 0100 to see the ALV.
  CALL SCREEN 0100.
