@AbapCatalog.sqlViewName: 'zvep028_vac_type'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vacancy Type'

define view ZSH_EP028_VacancyType as select from dd07t as t {
    @ObjectModel.text.element: [ 'vac_type_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Vacancy Type'
    key domvalue_l as vac_type,
    
    
    @EndUserText.label: 'Text'
    ddtext as vac_type_text    
} where t.domname = 'ZDD_EP028_VAC_TYPE' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
