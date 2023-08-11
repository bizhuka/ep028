@AbapCatalog.sqlViewName: 'zvep028_work_pat'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Pattern'

define view ZSH_EP028_WorkPattern as select from ZC_PY000_STVARV {
    key low as id_work_pattern
}where name = 'ZTS034_BASIC_WP'
