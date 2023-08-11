@AbapCatalog.sqlViewName: 'zvep028_jprf'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JPRF'
@Search.searchable: true

define view ZSH_EP028_JPRF as select from ZI_EP0298_JPRF {
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
    key jprf_id,
    key begda,
    key endda,
    
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        posit,        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
        wkptr,        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        persa,
        
        stat1,
        
        pnew,
        prepl,
        trepl,
        
        prnew,
        prrep,
        extp,
        
        intp,
        exps,
        nats
} where begda >= date_from
