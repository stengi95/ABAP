REPORT z_write LINE-SIZE  75  LINE-COUNT 107(3). "100 line with content 4 header and 3 footer
* REPORT name LINE-SIZE report_width LINE-COUNT page_lines[(footer_lines)]
TYPES:
  BEGIN OF gty_sflight.
    INCLUDE TYPE sflight.
TYPES: icon TYPE char20,
       END OF gty_sflight.

DATA:
  gt_sflight TYPE STANDARD TABLE OF gty_sflight,
  gs_sflight LIKE LINE OF gt_sflight,
  gv_rownr   TYPE i.

SELECT-OPTIONS: so_carr FOR gs_sflight-carrid NO-EXTENSION NO INTERVALS,
                so_conn FOR gs_sflight-connid NO-EXTENSION NO INTERVALS,
                so_flda FOR gs_sflight-fldate NO-EXTENSION NO INTERVALS,
                so_rwnr FOR gv_rownr DEFAULT 500 OBLIGATORY  NO-EXTENSION NO INTERVALS.

* Header
TOP-OF-PAGE. "Line count 4

  WRITE:
   AT  1 '|',
   AT  9 'Nr.'                      COLOR 1,
   AT 13 'Airline Code'             COLOR 2,
   AT 26 'Flight Connection Number' COLOR 3,
   AT 51 'Flight Date'              COLOR 4,
   AT 63 'Availability'             COLOR 5,
   AT 75 '|'.

  ULINE. " or   WRITE / sy-uline.

* Footer
END-OF-PAGE. "Line count: 3 ( uline, content, uline)
    ULINE.
    WRITE:
     AT  1 '|',
     AT 16 'This is the end of the page, languange: ',  sy-langu, '.',
     AT 75 '|',
     sy-uline.

* Selection from database
START-OF-SELECTION.

  SELECT * FROM sflight
  INTO CORRESPONDING FIELDS OF TABLE gt_sflight
  UP TO so_rwnr-low ROWS
      WHERE carrid IN so_carr
        AND connid IN so_conn
        AND fldate IN so_flda.

* Modifying the table
  LOOP AT gt_sflight ASSIGNING FIELD-SYMBOL(<ls_sflight>).

    IF <ls_sflight>-seatsmax EQ <ls_sflight>-seatsocc.
      <ls_sflight>-icon = icon_led_red.
    ELSEIF ( <ls_sflight>-seatsmax - <ls_sflight>-seatsocc ) LE 10.
      <ls_sflight>-icon = icon_led_yellow.
    ELSE.
      <ls_sflight>-icon = icon_led_green.
    ENDIF.

  ENDLOOP.

* Output
  LOOP AT gt_sflight ASSIGNING <ls_sflight>.

* Write a line with content
    NEW-LINE.

    WRITE:
     AT  1 '|', "FRAME
     AT  2 sy-tabix,
     AT 13 <ls_sflight>-carrid,
     AT 26 <ls_sflight>-connid,
     AT 51 <ls_sflight>-fldate,
     AT 68 <ls_sflight>-icon AS ICON,
     AT 75 '|'. "FRAME

  ENDLOOP.

* Last line
  DO sy-linsz TIMES.
    WRITE '~' NO-GAP.
  ENDDO.