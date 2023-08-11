class zcl_ep028_wd_styling definition
  public
  final
  create public .

  public section.
    methods: constructor importing io_style_manager type ref to if_wd_custom_style_manager.
    methods: init_styles.
  protected section.
    data: mo_style_manager type ref to if_wd_custom_style_manager.
  private section.
ENDCLASS.



CLASS ZCL_EP028_WD_STYLING IMPLEMENTATION.


  method constructor.
    mo_style_manager = io_style_manager.
  endmethod.


  method init_styles.
    data lo_btn_style_properties type if_wd_custom_style=>t_style_properties.

    lo_btn_style_properties = value #( ( name = `fontFamily` value = `"Segoe UI","Segoe",Tahoma,Helvetica,Arial,sans-serif;` )
                                          ( name = `fontSize` value = `13px;` )
                                          ( name = 'fontColor' value = 'black' )
                                          ( name = 'backgroundColor' value = 'white' )
                                                                                    ( name = 'margin' value = '0' ) ( name = 'padding' value = '0' )
    ).

    data(lo_custom_style) = mo_style_manager->create_custom_style( style_class_name = `ZMAINCONT`
                                                                        library_name     = 'STANDARD'
                                                                        element_type     = 'TRANSPARENT_CONTAINER'
                                                                        style_properties = lo_btn_style_properties ).
    mo_style_manager->add_custom_style( lo_custom_style ).


    lo_custom_style = mo_style_manager->create_custom_style( style_class_name = `ZTEXTVIEW`
                                                                        library_name     = 'STANDARD'
                                                                        element_type     = 'TEXT_VIEW'
                                                                        style_properties = lo_btn_style_properties ).
    mo_style_manager->add_custom_style( lo_custom_style ).

    lo_btn_style_properties = value #( ( name = `fontFamily` value = `"Segoe UI","Segoe",Tahoma,Helvetica,Arial,sans-serif;` )
                                          ( name = `fontSize` value = `13px;` )
                                          ( name = 'fontColor' value = 'black' )
                                          ( name = 'fontWeight' value = '700' )
    ).

    lo_custom_style = mo_style_manager->create_custom_style( style_class_name = `ZGROUPHEADER`
                                                                        library_name     = 'STANDARD'
                                                                        element_type     = 'TEXT_VIEW'
                                                                        style_properties = lo_btn_style_properties ).
    mo_style_manager->add_custom_style( lo_custom_style ).


    lo_btn_style_properties = value #( ( name = `fontFamily` value = `"Segoe UI","Segoe",Tahoma,Helvetica,Arial,sans-serif;` )
                                          ( name = `fontSize` value = `13px;` )
                                          ( name = 'fontColor' value = 'black' )
                                          ( name = 'backgroundColor' value = 'white' )
                                          ( name = 'fontWeight' value = 'bold' )
                                                                                    ( name = 'margin' value = '0' ) ( name = 'padding' value = '0' )
    ).

    lo_custom_style = mo_style_manager->create_custom_style( style_class_name = `ZTEXTVIEW_BOLD`
                                                                        library_name     = 'STANDARD'
                                                                        element_type     = 'TEXT_VIEW'
                                                                        style_properties = lo_btn_style_properties ).
    mo_style_manager->add_custom_style( lo_custom_style ).


" Style for Position Row
    lo_btn_style_properties = value #( ( name = `fontFamily` value = `"Segoe UI","Segoe",Tahoma,Helvetica,Arial,sans-serif;` )
                                          ( name = `fontSize` value = `13px;` )
                                          ( name = 'fontColor' value = 'black' )
                                          ( name = 'backgroundColor' value = 'white' )
                                          ( name = 'fontWeight' value = 'bold' )
                                                                                    ( name = 'margin' value = '0' ) ( name = 'padding' value = '0' )
    ).

    lo_custom_style = mo_style_manager->create_custom_style( style_class_name = `ZPOS_LINE`
                                                                        library_name     = 'STANDARD'
                                                                        element_type     = 'TEXT_VIEW'
                                                                        style_properties = lo_btn_style_properties ).
    mo_style_manager->add_custom_style( lo_custom_style ).

  endmethod.
ENDCLASS.
