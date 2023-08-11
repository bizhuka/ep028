@AbapCatalog.sqlViewName: 'zvcep028vachead'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Internal Vacancy List'
@VDM.viewType: #CONSUMPTION

@ObjectModel: {
    semanticKey: ['job_id'],
    compositionRoot: true,
    transactionalProcessingEnabled: true,
    createEnabled: true,
    
    updateEnabled: true, // @see -> is_updatable
    deleteEnabled: true, // @see -> is_deletable
    
    writeActivePersistence: 'ZDEP028_VAC_H',
    entityChangeStateId: ''
}        
@Search.searchable: true

@OData.publish: true
@ZABAP.virtualEntity: 'ZCL_EP028_HEAD'

@UI: {
    headerInfo: {
        typeName: 'Internal vacancy',
        typeNamePlural: 'Count',
        title: { type: #STANDARD, label: 'Vacancy' }
    }
}

// In -> *\webapp\annotations\annotation.xml
//@UI.facet: [ { id: 'VacancyTitle', purpose: #HEADER, type: #DATAPOINT_REFERENCE, position: 10, targetQualifier: 'VacTitle' },
//             { id: 'VacancyOrgData', purpose: #HEADER, type: #DATAPOINT_REFERENCE, position: 20, targetQualifier: 'OrgData' },
//             { id: 'GeneralData', type: #FIELDGROUP_REFERENCE, targetQualifier: 'GenData', label: 'General Data'}]

define view zc_ep028_vacancy_head as select from zdep028_vac_h

association[0..1] to ZSH_EP028_JPRF as _JPRF on _JPRF.jprf_id = $projection.jprf_id
association[0..1] to ZSH_EP028_Directorate as _Directorate on _Directorate.orgeh = $projection.directorate
association[0..1] to ZSH_EP028_Department  as _Department  on _Department.orgeh = $projection.department
association[0..1] to ZSH_EP028_VacancyStatus as _VacancyStatus on _VacancyStatus.vac_status = $projection.status
association[0..1] to ZSH_EP028_VacancyType as _VacancyType on _VacancyType.vac_type = $projection.vacancy_type
association[0..1] to ZSH_EP028_Grade as _Grade on _Grade.grade_id = $projection.grade
association[0..1] to ZSH_EP028_Grade as _Grad2 on _Grad2.grade_id = $projection.grad2
association[0..1] to ZSH_EP028_Slot as _Slot on _Slot.slot_id = $projection.comp_slot
association[0..1] to ZSH_EP028_WorkPattern as _WorkPattern on _WorkPattern.id_work_pattern = $projection.work_sched
association[0..1] to ZC_PY000_PersonnelArea as _PersonnelArea on _PersonnelArea.persa = $projection.location
association[0..1] to ZC_PY000_PersonnelSubArea as _PersonnelSubArea on _PersonnelSubArea.persa = $projection.location
                                                                   and _PersonnelSubArea.btrtl = $projection.subarea
association[0..1] to ZSH_EP028_Position as _Position on _Position.plans = $projection.pos_id
association[0..1] to ZSH_EP028_Job as _Job on _Job.stell = $projection.job_id
association[0..1] to ZC_PY000_UserInfo as _HrRepr on _HrRepr.UserName = $projection.hr_repr
association[0..1] to ZC_PY000_UserInfo as _UpdUsr on _UpdUsr.uname = $projection.update_user

// Fake connections
association[1..1] to ZI_EP0298_Current_User as _User on _User.pernr = $projection.pernr 
association[0..*] to ZI_EP0298_IAF as _IAF on _IAF.employee_id = $projection.pernr
association[0..*] to ZI_EP0298_IAF_History as _IAF_History on _IAF_History.appr_stage = $projection.grade
association[0..*] to ZI_EP0298_IAF_Attachment as _IAF_Attachment on _IAF_Attachment.ch_date = $projection.jprf_id
association[0..*] to ZI_EP0298_A_PRINT_JPRF_LETTER as _JprfLetter on _JprfLetter.jprf_id = $projection.jprf_id
{
        @UI.hidden: true
        key db_key,
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
        @UI.lineItem: [{ position: 25, type: #WITH_URL, url: 'link_job_descr', label: 'Vacancy and Job Description' }]        
        @ObjectModel: { text.element: ['vacancy_descr'], mandatory: true }
        @Consumption.valueHelp: '_JPRF'
        @UI.textArrangement: #TEXT_ONLY        
        jprf_id,    
        
        @UI.fieldGroup: [{ qualifier: 'State', position: '1' }]
        @ObjectModel: { readOnly: true }
        jprf_id as read_only_jprf_id,
        
//        @UI.lineItem: [{ position: 6, label: 'Vacancy and Job Description' }]
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        @UI.dataPoint: { qualifier: 'VacTitle', title: 'Vacancy Description'}
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '10', label: 'Vacancy Description' }]
        @UI.multiLineText: true
        vacancy_descr,
        
        @UI.lineItem: [{ position: 15, label: 'Directorate/Controllership' }]
        @ObjectModel: { text.element: ['directorate_text'], mandatory: true }  // directorate_name
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '10', label: 'Directorate/Controllership' }] //, targetElement: 'directorate_name' }]
        @Consumption.valueHelp: '_Directorate'
        @UI.textArrangement: #TEXT_ONLY
        directorate,        
        @UI.hidden: true
//        @UI.lineItem: [{ position: 15, label: 'Directorate/Controllership' }]
        _Directorate.orgeh_text as directorate_text,
        
        @UI.lineItem: [{ position: 210, label: 'Directorate short text', importance: #LOW }]
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        @UI.dataPoint: { qualifier: 'VacTitle', title: 'Directorate'}
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '11', label: 'Directorate/Controllership short text' }]
        @UI.multiLineText: true
        directorate_name,
        
        @UI.lineItem: [{ position: 20, label: 'Deparmtent' }]
        @ObjectModel: { text.element: ['department_text'], mandatory: true } // department_name
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '20', label: 'Department' }]
        @Consumption.valueHelp: '_Department'
        @UI.textArrangement: #TEXT_ONLY
        department,
        @UI.hidden: true
//        @UI.lineItem: [{ position: 20, label: 'Deparmtent' }]
        _Department.orgeh_text as department_text,
        
        @UI.lineItem: [{ position: 220, label: 'Department short text', importance: #LOW }]
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        @UI.dataPoint: { qualifier: 'VacTitle', title: 'Department'}
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '21', label: 'Department short text' }]
        @UI.multiLineText: true
        department_name,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
        @UI.lineItem: [{ position: 400, label: 'Applied Job' }]        
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '30', label: 'Applied Job' }]
        @ObjectModel: { text.element: ['stltx'], mandatory: true }
        @Consumption.valueHelp: '_Job'
        @UI.textArrangement: #TEXT_ONLY
        job_id,        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        _Job.stltx,
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        _Job.rus_text as job_rus_text,        
        
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
        @UI.lineItem: [{ position: 410 }]   
        @UI.fieldGroup: [{ qualifier: 'GenData', position: '40', label: 'Position' }]
        @ObjectModel: { text.element: ['plstx'], mandatory: true }
        @Consumption.valueHelp: '_Position'
        @UI.textArrangement: #TEXT_ONLY
        pos_id,
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        _Position.plstx, 
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8, ranking: #MEDIUM }
        _Position.rus_text as pos_rus_text, 
                
        @UI.lineItem: [{ position: 50, label: 'Location' }]
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '20', label: 'Location' }]
        @Consumption.valueHelp: '_PersonnelArea'
        @UI.selectionField: [{ position: 10 }]
        @ObjectModel.text.element: [ 'persa_text' ]
        @UI.textArrangement: #TEXT_ONLY
        location,
        _PersonnelArea.name1 as persa_text,  

        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '21' }]
        @Consumption.valueHelp: '_PersonnelSubArea'
        @UI.selectionField: [{ position: 11 }]
//        @ObjectModel.text.element: [ 'btrtl_text' ]
        @UI.textArrangement: #TEXT_ONLY        
        subarea,
        _PersonnelSubArea.btext as btrtl_text,     
        
        @UI.lineItem: [{ position: 60 , label: 'Work Schedule' }] 
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '30' }] // , label: 'Work Schedule'
        @Consumption.valueHelp: '_WorkPattern'
        @UI.selectionField: [{ position: 9 }]        
        work_sched,        
        
        @UI.lineItem: [{ position: 70 }]
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '40', label: 'Grade from' }] 
        @Consumption.valueHelp: '_Grade'
        @ObjectModel.text.element: [ 'grade_text' ]
        @UI.textArrangement: #TEXT_SEPARATE
        grade,
        _Grade.grade_text,

        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '41', label: 'Grade to' }] 
        @Consumption.valueHelp: '_Grad2'
        @ObjectModel.text.element: [ 'grad2_text' ]
        @UI.textArrangement: #TEXT_SEPARATE
        grad2,
        _Grad2.grade_text as grad2_text,                
                
        @UI.lineItem: [{ position: 80, label: '# Slot' }] 
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '50', label: '# Slot' }]
        @Consumption.valueHelp: '_Slot'
        @ObjectModel.text.element: [ 'slot_text' ]
        @UI.textArrangement: #TEXT_ONLY
        comp_slot,
        _Slot.slot_text,
        
        @UI.lineItem: [{ position: 90, label: 'Work Type', importance: #MEDIUM  }]
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '40', label: 'Work Type' }] 
        @Consumption.valueHelp: '_VacancyType'
        @UI.selectionField: [{ position: 6 }]
        @ObjectModel.text.element: [ 'vac_type_text' ]
        @UI.textArrangement: #TEXT_ONLY
        vacancy_type,
        _VacancyType.vac_type_text,
                        
//        @UI.lineItem: [{ position: 11, type: #WITH_URL, url: 'link_job_descr', label: 'Link to Job Description' }]
//        'Link' as JobDescrUrl,        
        @UI.fieldGroup: [{ qualifier: 'VacancyData', position: '70', label: 'Link to Job Description' }]
        @UI.multiLineText: true
        link_job_descr,
        
        @UI.lineItem: [{ position: 100, label: 'HR Representative' }]
        @UI.fieldGroup: [{ qualifier: 'AuxData', position: '10', label: 'HR Representative' }]
        @Consumption.valueHelp: '_HrRepr'
        hr_repr,        
        
        @UI.lineItem: [{ position: 350, importance: #LOW }]        
        @UI.fieldGroup: [{ qualifier: 'State', position: '20' }] // , label: 'Status'
        @Consumption.valueHelp: '_VacancyStatus'
        @UI.selectionField: [{ position: 5 }]
        @Consumption.filter : { defaultValue: 'VISIBLE' }        
        @ObjectModel.text.element: [ 'vac_status_text' ]
        @UI.textArrangement: #TEXT_ONLY
        status,                
        @UI.lineItem: [{ position: 201, importance: #LOW }]
        _VacancyStatus.vac_status_text,
        
        // is string ... @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }       
        @UI.lineItem: [{ position: 110, label: 'Comments' }]
        @UI.fieldGroup: [{ qualifier: 'AuxData', position: '30', label: 'Comments' }]
        @UI.multiLineText: true
        comments,
        
        @ObjectModel: { readOnly: true }
        @EndUserText.label: 'Last changed at'
        @UI.fieldGroup: [{ qualifier: 'State', position: '30' }]
        update_date_time,
        
        @ObjectModel: { text.element: ['update_user_name'], readOnly: true }
        @EndUserText.label: 'Last changed by'
        @UI.fieldGroup: [{ qualifier: 'State', position: '40' }]
        update_user,
        _UpdUsr.UserName as update_user_name,
        
        @UI.hidden: true
        cast( '00000000' as pernr_d ) as pernr,

        @UI.hidden: true
        cast( ' ' as os_boolean ) as is_deletable,
        @UI.hidden: true
        cast( ' ' as os_boolean ) as is_updatable,
        
        
        /* Associations */         
        _JPRF,
        _Directorate,
        _Department,      
        _VacancyStatus,
        _VacancyType,
        _Grade,
        _Grad2,
        _Slot,
        _WorkPattern,
        _PersonnelArea,
        _PersonnelSubArea,
        _Position,
        _Job,
        _User,
        _HrRepr,
        
        _IAF,
        _IAF_History,
        _IAF_Attachment,
        _JprfLetter
}
