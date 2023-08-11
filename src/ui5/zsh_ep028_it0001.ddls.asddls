@AbapCatalog.sqlViewName: 'zvep028_it0001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IT 0001'

define view ZSH_EP028_IT0001 as select from ZC_PY000_OrgAssignment {
    key pernr,
        ename
} where begda <= datum and endda >= datum
