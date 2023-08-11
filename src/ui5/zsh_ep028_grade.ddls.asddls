@AbapCatalog.sqlViewName: 'zvep028_grade'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Grade'

define view ZSH_EP028_Grade as select from dd07t as t {
    @ObjectModel.text.element: [ 'grade_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Grade'
    key domvalue_l as grade_id,
    
    
    @EndUserText.label: 'Text'
    ddtext as grade_text    
} where t.domname = 'ZDD_HR013_GRADE' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
