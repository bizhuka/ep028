@AbapCatalog.sqlViewName: 'zvep028_iaf_h'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IAF History'

define view ZI_EP0298_IAF_History as select from zdhr204_iaf_ah
association[0..1] to ZC_PY000_UserInfo as _UserInfo on _UserInfo.uname = $projection.uname
association[0..1] to ZSH_EP028_IAF_APPR_STAGE as _IAF_APPR_STAGE on _IAF_APPR_STAGE.approval_stage_id = $projection.appr_stage
association[0..1] to ZSH_EP028_IAF_APPR_STAGE as _IAF_APPR_STAGE_NEW on _IAF_APPR_STAGE_NEW.approval_stage_id = $projection.new_appr_stage

{
    key guid,
    key timestamp,
    
    chain_num,        
    
    @EndUserText.label: 'New Approval Stage'
    @ObjectModel.text.element: [ 'new_appr_stage_text' ]
    new_appr_stage,
    _IAF_APPR_STAGE_NEW.approval_stage_text as new_appr_stage_text,
    
    @EndUserText.label: 'Previous Approval Stage'
    @ObjectModel.text.element: [ 'appr_stage_text' ]
    appr_stage,
    _IAF_APPR_STAGE.approval_stage_text as appr_stage_text,
    
    action,
    
    @ObjectModel.text.element: [ 'user_name' ]
    @EndUserText.label: 'User'
    uname,
    _UserInfo.UserName as user_name,
    
    @EndUserText.label: 'Action date'
    action_date,
    @EndUserText.label: 'Action time'
    action_time,
    
    @EndUserText.label: 'Notes'
    decision_note,
    
    @EndUserText.label: 'Archive'
    cast(archive as os_boolean) as archive
}
