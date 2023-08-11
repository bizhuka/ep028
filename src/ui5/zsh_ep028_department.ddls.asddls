@AbapCatalog.sqlViewName: 'zvep028_dep'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department'
@Search.searchable: true

define view ZSH_EP028_Department as select from zi_ep028_orgunit 
{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
    @UI.lineItem: [{ position: 10 }]  
    @ObjectModel:{ mandatory: true, readOnly: true, text.element: ['Name'] }
    @UI.fieldGroup: [{ qualifier: 'DepartmentGroup', position: 05 }]
    @UI.selectionField.position: 10
    key orgeh,

    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    @UI.lineItem: [{ position: 20 }]  
    @Semantics.text: true
    @UI.selectionField.position: 20
    orgeh_text
} where is_department = 'X'
