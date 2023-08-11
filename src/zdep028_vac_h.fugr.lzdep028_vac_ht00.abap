*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDEP028_VAC_H...................................*
DATA:  BEGIN OF STATUS_ZDEP028_VAC_H                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDEP028_VAC_H                 .
CONTROLS: TCTRL_ZDEP028_VAC_H
            TYPE TABLEVIEW USING SCREEN '0101'.
*.........table declarations:.................................*
TABLES: *ZDEP028_VAC_H                 .
TABLES: ZDEP028_VAC_H                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
