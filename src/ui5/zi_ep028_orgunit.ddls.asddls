@AbapCatalog.sqlViewName: 'zviep028o'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OrgUnits'

define view zi_ep028_orgunit as select from hrp1000
left outer join hrp1222 as attrh on 
    hrp1000.plvar = attrh.plvar and hrp1000.otype = attrh.otype and
    hrp1000.objid = attrh.objid and attrh.subty = 'Z002'
     
    left outer join hrt1222 as attrv on 
    attrv.tabnr = attrh.tabnr and attrv.attrib = 'HLEVEL'
    
    join zi_ep028_context as sy on 
      hrp1000.begda <= sy.CurrentDate and
      attrh.begda <= sy.CurrentDate and
      hrp1000.endda >= sy.CurrentDate and
      attrh.endda >= sy.CurrentDate
{
    key hrp1000.objid as orgeh,
        hrp1000.stext as orgeh_text,
    
    cast( case attrv.low when 'DIRECTORATE' then 'X' else ' ' end as os_boolean ) as is_directorate,
    cast( case attrv.low when 'DEPARTMENT'  then 'X' else ' ' end as os_boolean ) as is_department               
} where hrp1000.plvar = '01'
