@AbapCatalog.sqlViewName: 'zvep028_position'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Position'
@Search.searchable: true

define view ZSH_EP028_Position as select from t528b as _main

association[0..1] to t528t as _Text on _Text.sprsl = $session.system_language
                                   and _Text.otype = 'S' // _main.otype
                                   and _Text.plans = _main.plans
                                   and _Text.endda = '99991231'
                                   --and _Text.endda >= _main.begda and _Text.begda <= _main.endda
                                   
// zc_py000_longtext
association[0..1] to hrv1002a as   _LongEngText on _LongEngText.otype     = 'S'
                                               and _LongEngText.objid     = _main.plans
                                               and _LongEngText.subty     = '0001'
                                               //and _LongEngText.begda    <= _main.endda and _LongEngText.endda    >= _main.begda
                                               and _LongEngText.endda     = '99991231'
                                               and _LongEngText.tabseqnr = '000001'
                                                                                  
association[0..1] to hrv1002a as   _LongRusText on _LongRusText.otype     = 'S'
                                               and _LongRusText.objid     = _main.plans
                                               and _LongRusText.subty     = 'ZR02'
                                               //and _LongRusText.begda    <= _main.endda and _LongRusText.endda    >= _main.begda
                                               and _LongRusText.endda     = '99991231'
                                               and _LongRusText.tabseqnr = '000001'
{
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
    key plans,
    
    @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
    _Text.plstx,
    
     @EndUserText.label: 'Position long text in English'
     @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    _LongEngText.tline as eng_text,    
    
     @EndUserText.label: 'Position long text in Russian'
     @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
    _LongRusText.tline as rus_text
    
}where _main.endda = '99991231'
