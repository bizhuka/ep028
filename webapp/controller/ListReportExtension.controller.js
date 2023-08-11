sap.ui.define([
  "zep028lr/controller/MessageParser",
  "zep028lr/controller/Libs",
  "zep028lr/controller/CurrentUser",
  "zep028lr/controller/IAF_Handler",

  "sap/ui/model/json/JSONModel",
], function (MessageParser, Libs, CurrentUser, IAF_Handler, JSONModel) {
  "use strict";

  return {
    onInit: function () {
      CurrentUser.init(this)
      this._insert_main_view()
      this._setMessageParser()
      this.fill_grp_by_list()

      const listReportFilter = this.getView().byId('listReportFilter')
      listReportFilter.setLiveMode(true)
      listReportFilter.setShowClearOnFB(true)

      this.getView().byId('responsiveTable').attachItemPress(function (oEvent) {
        const obj = oEvent.getParameters().listItem.getBindingContext().getObject()
        window._objPageController.refresh_jprf_iaf_table(obj.jprf_id)
      }.bind(this))
    },

    onAfterRendering: function () {
      this._initCreateDialog()
      this.set_column_widths()
    },

    onCreateBlankPress: function () {
      this.getOwnerComponent().getModel().create(`/zc_ep028_vacancy_head`, {},
        {
          success: function (newItem) {
            //TODO this.getView().byId('listReportFilter-filterItemControl_BASIC-status').setSelectedKeys([])
            //this.getView().byId('listReport').rebindTable()
          }.bind(this)
        })
    },

    onApplyJobPress: function (oEvent) {
      Libs.onApplyJobPress(CurrentUser._usr, this, oEvent.getSource().getBindingContext().getObject())
    },

    fill_grp_by_list: function () {
      const model = new JSONModel()
      model.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay)
      model.setData({
        grp_items: [
          { key: '', value: 'None' },
          { key: 'directorate_name', value: 'Directorate short text' },
          { key: 'department_name', value: 'Department short text' },
          { key: 'directorate_text', value: 'Directorate system text' },
          { key: 'department_text', value: 'Department system text' },
          { key: 'vac_type_text', value: 'Work Type' },
        ]
      })
      this.getView().byId('id_group_by').setModel(model, 'grp_by')
      this.getView().byId('id_group_by').setSelectedKey('directorate_name')
    },

    onBeforeRebindTableExtension: function (oEvent) {
      const oBindingParams = oEvent.getParameter("bindingParams")
      oBindingParams.parameters = oBindingParams.parameters || {}

      const grpBy = this.getView().byId('id_group_by').getSelectedKey()
      if (grpBy) {
        oBindingParams.sorter.push(new sap.ui.model.Sorter(grpBy, null, true))
        return
      }
    },

    _insert_main_view: function () {
      const parLevel = this.getView().byId('page')
      const smartTable = parLevel.getContent()

      const iafHandler = new IAF_Handler({
        owner: this,
        prefix: 'my',

        handleBeforeRebindIAFTable: function (oBindingParams) {
          oBindingParams.filters.push(new sap.ui.model.Filter("employee_id", "EQ", CurrentUser._usr.pernr))  // TODO test "00052775"
        }
      })
      sap.ui.core.Fragment.load({ id: this.getView().getId(), name: "zep028lr.fragment.Main", controller: iafHandler })
        .then(function (oMainObjectPageLayout) {
          parLevel.setContent(oMainObjectPageLayout)

          // Insert to new place          
          this.getView().byId('idSmartTableParent').addBlock(smartTable)
        }.bind(this))
    },

    _setMessageParser: function () {
      const model = this.getOwnerComponent().getModel()
      const messageParser = new MessageParser(model.sServiceUrl, model.oMetadata, !!model.bPersistTechnicalMessages)
      //messageParser.set_owner(this)
      model.setMessageParser(messageParser)
    },

    _initCreateDialog: function () {
      const _this = this
      const _view = _this.getView()

      _view.byId('addEntry').attachPress(function () {
        const createDialog = _view.byId('CreateWithDialog')
        if (createDialog && !createDialog.mEventRegistry.afterOpen) createDialog.attachAfterOpen(function () {
          createDialog.setContentWidth('25em')
          const _byId = sap.ui.getCore().byId
          _byId('__form0').setTitle('Internal Posting')
          _byId('__field2-label').setText('Comments')
          _byId('__field2-textArea').setWidth('23em')

          // _byId('__field5').setMandatory(true)
          // _byId('__field7').setValue('KZT')
        })
      })
    },

    set_column_widths: function () {

      this.getView().byId('responsiveTable').getColumns().map((column) => {
        let parts = column.getId().split('-')
        let id = parts[parts.length - 1]
        switch (id) {
          case 'directorate': column.setWidth('14rem'); break
          case 'department': column.setWidth('14rem'); break
          case 'jprf_id': column.setWidth('14rem'); break
          case 'location': column.setWidth('8rem'); break
          case 'comp_slot': column.setWidth('7rem'); break
          case 'vacancy_type': column.setWidth('7rem'); break
          case 'hr_repr': column.setWidth('10rem'); break
          case 'comments': column.setWidth('15rem'); break

        }
      })
    }
  }
})