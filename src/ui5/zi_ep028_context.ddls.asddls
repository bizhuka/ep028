@AbapCatalog.sqlViewName: 'zviep028glc'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Global context'
define view zi_ep028_context as select distinct from t000 {
      cast (substring( cast( tstmp_current_utctimestamp() as abap.char(17) ), 1, 8 ) as abap.dats) as CurrentDate,
      
      @UI.hidden: true
      '#' as dummy   
}
