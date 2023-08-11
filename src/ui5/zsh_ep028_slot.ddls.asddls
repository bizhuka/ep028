@AbapCatalog.sqlViewName: 'zvep028_slot'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Slot'

define view ZSH_EP028_Slot as select from dd07t as t {
    @ObjectModel.text.element: [ 'slot_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Company’s slot'
    key domvalue_l as slot_id,
    
    
    @EndUserText.label: 'Text'
    ddtext as slot_text    
} where t.domname = 'ZDD_HR013_COMP_SLOT' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
