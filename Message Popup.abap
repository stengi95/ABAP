* Global Data Declaration
DATA: gt_log    TYPE STANDARD TABLE OF esp1_message_wa_type,
      gv_log_id TYPE i VALUE 1.

* Using Work area.
DATA: ls_log TYPE esp1_message_wa_type.
ls_log-msgid  = 'E4'.
ls_log-msgty  = 'S'.
ls_log-msgv1  = 'Success Message'.
ls_log-lineno = gv_log_id.
gv_log_id = gv_log_id + 1.
APPEND ls_log TO gt_log.

* Using Work area (inline declaration) and VALUE #.
DATA(ls_log_wa) = VALUE esp1_message_wa_type( msgid = 'E4' msgty = 'A' msgv1 = 'Termination Message' lineno = gv_log_id ).
gv_log_id = gv_log_id + 1.
APPEND ls_log_wa TO gt_log.

* Field symbol
FIELD-SYMBOLS <ls_log_fs> TYPE esp1_message_wa_type.
APPEND INITIAL LINE TO gt_log ASSIGNING <ls_log_fs>.
<ls_log_fs>-msgid  = 'E4'.
<ls_log_fs>-msgty  = 'W'.
<ls_log_fs>-msgv1  = 'Warning Message'.
<ls_log_fs>-lineno = gv_log_id.
gv_log_id = gv_log_id + 1.

* Field symbol (inline declaration) and using VALUE #.
APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<ls_log>).
<ls_log> = VALUE #( msgid = 'E4' msgty = 'E' msgv1 = 'Error Message' lineno = gv_log_id ).
*This is the same but with declaring the value type.
*<ls_log> = VALUE esp1_message_wa_type( msgid = 'E4' msgty = 'E' msgv1 = 'Error Message' lineno = gv_log_id ).
gv_log_id = gv_log_id + 1.

* Using Message short form
APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<ls_log_msg>).
MESSAGE ID 'OO' TYPE 'E'  NUMBER 000 WITH 'Error' 'Message' space space INTO DATA(gv_msg).
<ls_log_msg> = VALUE #( msgid = sy-msgid msgty = sy-msgty msgno = sy-msgno  lineno = gv_log_id
                        msgv1 = sy-msgv1 msgv2 = sy-msgv2 msgv3 = sy-msgv3  msgv4  = sy-msgv4 ).
gv_log_id = gv_log_id + 1.

* Using Message short form
APPEND INITIAL LINE TO gt_log ASSIGNING <ls_log_msg>.
MESSAGE s000(OO) WITH 'Success' 'Message' space space INTO gv_msg.
<ls_log_msg> = VALUE #( msgid = sy-msgid msgty = sy-msgty msgno = sy-msgno  lineno = gv_log_id
                        msgv1 = sy-msgv1 msgv2 = sy-msgv2 msgv3 = sy-msgv3  msgv4  = sy-msgv4 ).
gv_log_id = gv_log_id + 1.

* Using Message real example 1
APPEND INITIAL LINE TO gt_log ASSIGNING <ls_log_msg>.
MESSAGE e303(PP) INTO gv_msg.
<ls_log_msg> = VALUE #( msgid = sy-msgid msgty = sy-msgty msgno = sy-msgno  lineno = gv_log_id
                        msgv1 = sy-msgv1 msgv2 = sy-msgv2 msgv3 = sy-msgv3  msgv4  = sy-msgv4 ).
gv_log_id = gv_log_id + 1.

* Using Message real example 2
DATA gv_message TYPE TEXT200.
APPEND INITIAL LINE TO gt_log ASSIGNING <ls_log_msg>.
MESSAGE e303(PP) INTO gv_message.
<ls_log_msg> = VALUE #( msgid = sy-msgid msgty = sy-msgty msgno = sy-msgno  lineno = gv_log_id
                        msgv1 = gv_message+000(50) msgv2 = gv_message+050(50)
                        msgv3 = gv_message+100(50) msgv4 = gv_message+150(50) ).
gv_log_id = gv_log_id + 1.

CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
  TABLES
    i_message_tab = gt_log.