@AbapCatalog.sqlViewName: 'zvep028_reldt'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Release date type'

define view ZSH_EP028_Release_Date_Type as select from dd07t as t {
    @ObjectModel.text.element: [ 'release_date_type_text' ]
    @UI.textArrangement: #TEXT_ONLY  
    @EndUserText.label: 'Release date type'
    key domvalue_l as rdt_id,
    
    
    @EndUserText.label: 'Text'
    ddtext as release_date_type_text    
} where t.domname = 'ZDD_HR204_RELEASE_DATE_TYPE' and t.ddlanguage = $session.system_language and t.as4local = 'A' and t.as4vers = '0000'
