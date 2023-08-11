@AbapCatalog.sqlViewName: 'zvep028_iaf_att'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IAF Attachment'

@ZABAP.virtualEntity: 'ZCL_EP028_IAF_ATTACHMENT'

@ObjectModel:{
    deleteEnabled: true
}


@UI.headerInfo: {
  typeName: 'Attachment',
  typeNamePlural: 'Attachments',
  title: {
    value: 'filename',
    type: #STANDARD
  }
}

define view ZI_EP0298_IAF_Attachment as select from t000 {
    key cast( ' ' as zde_hr204_iaf_guid) as guid,
    key cast( ' ' as text70 ) as atta_id,
        cast( ' ' as gos_atta_cat ) as atta_cat,
         
        cast( ' ' as so_cro_nam ) as cr_user,
        cast( ' ' as sgs_crname ) as cr_name,        
        @EndUserText.label: 'Created date'
        cast( '99991231' as abap.dats ) as cr_date,
        @EndUserText.label: 'Created time'
        cast( '120000' as abap.tims ) as cr_time,
        
        cast( ' ' as so_cho_nam ) as ch_user,        
        @EndUserText.label: 'Changed By'
        cast( ' ' as sgs_crname ) as ch_name,        
        @EndUserText.label: 'Changed date'
        cast( '99991231' as abap.dats ) as ch_date,
        @EndUserText.label: 'Changed time'
        cast( '120000' as abap.tims ) as ch_time,
        
        @EndUserText.label: 'File size'
        cast( 77777 as sytabix ) as filesize,
        
        cast( ' ' as bitm_filename ) as filename,
        cast( ' ' as bitm_type ) as tech_type,
        @EndUserText.label: 'File name'
        cast( ' ' as bitm_descr ) as descr,
        cast( ' ' as abap.lang ) as lang,
        
        // Result
        cast( ' ' as abap.char( 255 ) ) as message,
        cast( ' ' as os_boolean) as is_error
        
        
}
