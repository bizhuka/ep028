@AbapCatalog.sqlViewName: 'zvep028_apr_stg'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IAF Approval Stage'

define view ZSH_EP028_IAF_APPR_STAGE as select from dd07t as t {
    @ObjectModel.text.element: [ 'approval_stage_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Approval Stage'
    key domvalue_l as approval_stage_id,
    
    
    @EndUserText.label: 'Text'
    ddtext as approval_stage_text    
} where t.domname = 'ZDD_HR204_IAF_APPR_STAGE' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
