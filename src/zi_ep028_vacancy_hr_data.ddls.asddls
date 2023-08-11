@AbapCatalog.sqlViewName: 'zvipa028vac_hr'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'HR Data of Internal Vacancy'
define view zi_ep028_vacancy_hr_data as select from hrp1000 as JPRF
left outer join hrp1001 as PosRelation
// Relation ZJ -> A 003 -> S
    on JPRF.objid = PosRelation.objid and PosRelation.plvar = '01' and PosRelation.istat = '1' and
      PosRelation.otype = 'ZJ' and PosRelation.sclas = 'S' and PosRelation.rsign = 'A' and PosRelation.relat = '003'
    
    // Additional JPRF Data
    left outer join hrp9005 as JPRFData on JPRF.objid = JPRFData.objid
    
    // Connection to Job (C)
    left outer join hrp1001 as JobRelation on JobRelation.objid = PosRelation.sobid and JobRelation.otype = 'S' and
      JobRelation.sclas = 'C' and  JobRelation.istat = '1' and JobRelation.plvar = '01' and 
      JobRelation.rsign = 'B' and JobRelation.relat = '007' 
{
  key JPRF.objid as JPRFId,
  
 // Position data
 cast( left(PosRelation.sobid, 8) as ABAP.numc( 8 ) ) as PosId,
 PosRelation.begda as PosBegda,
 PosRelation.endda as PosEndda,
 
 // Job data
 cast( left(JobRelation.sobid, 8) as ABAP.numc( 8 ) ) as JobId,
 JobRelation.begda as JobBegda,
 JobRelation.endda as JobEndda,
 
  JPRFData.posit   as JobDescription
}
where JPRF.otype = 'ZJ'
