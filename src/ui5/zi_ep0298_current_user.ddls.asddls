@AbapCatalog.sqlViewName: 'zvep028_cur_user'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Current User'


@ZABAP.virtualEntity: 'ZCL_EP028_CURRENT_USER'

define view ZI_EP0298_Current_User as select from alcsmconf {
    key cast( '00000000' as pernr_d ) as pernr,
        cast( ' ' as xubname )        as login,
        cast( ' ' as emnam )          as ename,
        cast( ' ' as os_boolean )     as is_admin,
        
        csmconf as v_about_info 
}
