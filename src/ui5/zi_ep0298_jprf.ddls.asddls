@AbapCatalog.sqlViewName: 'ziep028_jprf'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JPRF'

define view ZI_EP0298_JPRF as select from hrp9005{
    @UI.lineItem: [{ position: 1 } ]
    key objid as jprf_id,
    @UI.lineItem: [{ position: 2 } ]
    key begda,
    @UI.lineItem: [{ position: 3 } ]
    key endda,
        
        // order in SH moved to -> /annotations/annotation.xml
        @UI.lineItem: [{ position: 20 } ]
        posit,
        
        @UI.lineItem: [{ position: 30 } ]
        wkptr,
        
        @UI.lineItem: [{ position: 40 } ]
        persa,
        
        @UI.lineItem: [{ position: 50 } ]
        stat1,
        
        @UI.lineItem: [{ position: 301 } ]
        pnew,
        @UI.lineItem: [{ position: 302 } ]
        prepl,
        @UI.lineItem: [{ position: 303 } ]
        trepl,
        
        prnew,
        @UI.lineItem: [{ position: 304 } ]
        prrep,
        @UI.lineItem: [{ position: 305 } ]
        extp,
        
        @UI.lineItem: [{ position: 306 } ]
        intp,
        @UI.lineItem: [{ position: 307 } ]
        exps,
        @UI.lineItem: [{ position: 308 } ]
        nats,
        
        @UI.hidden: true
        // 31 * 6 day before
        cast (substring( cast( tstmp_add_seconds(tstmp_current_utctimestamp(), cast( -31 * 6 *    60 * 60 * 24 as abap.dec(15,0) ) , 'FAIL')  as abap.char(17) ), 1, 8 ) as abap.dats)
         as date_from                
} where plvar = '01' and otype = 'ZJ' and istat = '1'
    and pnew = 'X'
    and stat1 <> 'E'
