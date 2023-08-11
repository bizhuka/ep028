@AbapCatalog.sqlViewName: 'zvep028_job'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Job'
@Search.searchable: true

define view ZSH_EP028_Job as select from t513 as _main

association[0..1] to t513s as _Text on _Text.sprsl = $session.system_language
                                   and _Text.stell =  _main.stell
                                   and _Text.endda = '99991231'
                                   --and _Text.endda >= _main.begda and _Text.begda <= _main.endda
                                   
// zc_py000_longtext
association[0..1] to hrv1002a as   _LongEngText on _LongEngText.otype     = 'C'
                                               and _LongEngText.objid     = _main.stell
                                               and _LongEngText.subty     = '0001'
                                               //and _LongEngText.begda    <= _main.endda and _LongEngText.endda    >= _main.begda
                                               and _LongEngText.endda     = '99991231'
                                               and _LongEngText.tabseqnr = '000001'
                                                                                  
association[0..1] to hrv1002a as   _LongRusText on _LongRusText.otype     = 'C'
                                               and _LongRusText.objid     = _main.stell
                                               and _LongRusText.subty     = 'ZR02'
                                               //and _LongRusText.begda    <= _main.endda and _LongRusText.endda    >= _main.begda
                                               and _LongRusText.endda     = '99991231'
                                               and _LongRusText.tabseqnr = '000001'
{  
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
    key _main.stell,
    
    
    // cast (substring( cast( tstmp_current_utctimestamp() as abap.char(17) ), 1, 8 ) as abap.dats) as datum
    
            
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7, ranking: #MEDIUM }
        _Text.stltx,
        
         @EndUserText.label: 'Position long text in English'
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        _LongEngText.tline as eng_text,    
        
         @EndUserText.label: 'Position long text in Russian'
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
        _LongRusText.tline as rus_text      
} where _main.endda = '99991231'
