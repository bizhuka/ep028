@AbapCatalog.sqlViewName: 'zvep028_vac_stat'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vacancy Status'

define view ZSH_EP028_VacancyStatus as select from dd07t as t {
    @ObjectModel.text.element: [ 'vac_status_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Vacancy Status'
    key domvalue_l as vac_status,
    
    
    @EndUserText.label: 'Text'
    ddtext as vac_status_text    
} where t.domname = 'ZDD_EP028_VAC_STATUS' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
