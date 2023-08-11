@AbapCatalog.sqlViewName: 'zviep028_prnt_13'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Action print JPRF letter'

@ZABAP.virtualEntity: 'ZCL_A_EP028_PRINT_JPRF_LETTER'

define view ZI_EP0298_A_PRINT_JPRF_LETTER as select from t000 {
    key cast( '55555555' as HROBJID) as jprf_id
}
