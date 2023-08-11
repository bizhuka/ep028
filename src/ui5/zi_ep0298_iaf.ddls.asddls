@AbapCatalog.sqlViewName: 'zvep028_iaf'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IAF HR_204'

//@ZABAP.virtualEntity: 'ZCL_EP028_IAF' moved to 'ZCL_EP028_IAF_ATTACHMENT'

define view ZI_EP0298_IAF as select from zdhr204_iaf_h
association[0..1] to ZSH_EP028_IT0001 as _IT0001 on _IT0001.pernr = $projection.employee_id
association[0..1] to ZSH_EP028_Release_Date_Type as _Release_Date_Type on _Release_Date_Type.rdt_id = $projection.transfer_date_type
association[0..1] to ZC_PY000_UserInfo as _UserInfo on _UserInfo.uname = $projection.created_by
association[0..1] to ZSH_EP028_Job as _Job on _Job.stell = $projection.vacancy_id
association[0..*] to ZI_EP0298_IAF_History as _IAF_History on _IAF_History.guid = $projection.guid
association[0..*] to ZI_EP0298_IAF_Attachment as _IAF_Attachment on _IAF_Attachment.guid = $projection.guid
{
    key guid,
    
        @ObjectModel.text.element: [ 'comments' ]
        @UI.textArrangement: #TEXT_LAST
        iaf_id,
        
        @ObjectModel.text.element: [ 'employee_name' ]
        employee_id,
        _IT0001.ename as employee_name,
        
        @ObjectModel.text.element: [ 'vacancy_text' ]
        @EndUserText.label: 'Applied position'
        vacancy_id,
        _Job.stltx as vacancy_text,
        
        transfer_date,
        
        @ObjectModel.text.element: [ 'release_date_type_text' ]
        transfer_date_type,
        _Release_Date_Type.release_date_type_text,
        
    //    @EndUserText.label: 'Comments'
        comments,
        
        @ObjectModel.text.element: [ 'created_by_name' ]
        @EndUserText.label: 'Created by'
        created_by,
        _UserInfo.UserName as created_by_name,
        
        created_date,
        
        @EndUserText.label: 'Created Time'
        created_time,
        
        jprf_id,
        
        _IAF_History,
        _IAF_Attachment
}
