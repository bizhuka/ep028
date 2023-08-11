
sap.ui.define([
    "zep028lr/controller/CurrentUser",
    "zep028lr/controller/Libs",
    "sap/ui/base/Object"
], function (CurrentUser, Libs, SapObject) {
    "use strict";

    return SapObject.extend("zep028lr.controller.IAF_Handler", {
        constructor: function (ext) {
            this.ext = ext
        },

        onSectionChange: function (oEvent) {
            switch (oEvent.getParameter('section')) {
                case this.ext.owner.byId('idIafSection'):
                    this.ext.owner.byId(`${this.ext.prefix}--idIafTable`).rebindTable()
                    this.update_if_visible(false)
                    return

                case this.ext.owner.byId('idAboutSection'):
                    const aboutSubSection = this.ext.owner.byId('idAboutSubSection')
                    if (!aboutSubSection._1_time) {
                        aboutSubSection._1_time = true
                        sap.ui.core.Fragment.load({ fragmentContent: CurrentUser._usr.v_about_info, controller: this })
                            .then(function (fragment) {
                                aboutSubSection.removeAllBlocks()
                                aboutSubSection.addBlock(fragment)
                            }.bind(this))
                    }
                    return
            }
        },


        onBeforeRebindIAFTable: function (oEvent) {
            const oBindingParams = oEvent.getParameter("bindingParams")
            oBindingParams.parameters = oBindingParams.parameters || {}

            this.ext.handleBeforeRebindIAFTable(oBindingParams)
            oBindingParams.sorter.push(new sap.ui.model.Sorter("created_date", true))
            oBindingParams.sorter.push(new sap.ui.model.Sorter("created_time", true))
        },

        onIafDrillDown: function (oEvent, idTabeId) {
            const smartTable = this.ext.owner.byId(`${this.ext.prefix}--${idTabeId}`)
            smartTable.setVisible(!smartTable.getVisible() || this._prev_value !== oEvent.getSource().getTarget())
            this._prev_value = oEvent.getSource().getTarget()

            const arr = this._prev_value.split('|')
            this.curr_iaf_file = {
                guid: arr[0],
                iaf_id: arr[1]
            }

            this.update_if_visible(null)
        },

        update_if_visible: function (visible) {
            for (let idTabeId of [`${this.ext.prefix}--idIafAttachmentTable`, `${this.ext.prefix}--idIafHistoryTable`]) {
                const smartTable = this.ext.owner.byId(idTabeId)

                if (visible !== null) smartTable.setVisible(visible)

                if (smartTable.getVisible()) {
                    const prevHeader = smartTable.getHeader().split(' - ')
                    smartTable.setHeader(prevHeader[0] + ' - IAF ID ' + this.curr_iaf_file.iaf_id.replace(/^0+/, ''))

                    smartTable.rebindTable()
                }
            }
        },

        onBeforeRebindIafHistoryTable: function (oEvent) {
            const oBindingParams = oEvent.getParameter("bindingParams")
            oBindingParams.parameters = oBindingParams.parameters || {}
            oBindingParams.filters.push(new sap.ui.model.Filter("guid", "EQ", this.curr_iaf_file.guid))
            oBindingParams.sorter.push(new sap.ui.model.Sorter("timestamp", true))
        },

        onBeforeRebindIafAttachmentTable: function (oEvent) {
            const oBindingParams = oEvent.getParameter("bindingParams")
            oBindingParams.parameters = oBindingParams.parameters || {}
            oBindingParams.filters.push(new sap.ui.model.Filter("guid", "EQ", this.curr_iaf_file.guid))
            oBindingParams.sorter.push(new sap.ui.model.Sorter("cr_date", true))
            oBindingParams.sorter.push(new sap.ui.model.Sorter("cr_time", true))
        },

        onIafAttachmentFileClick: function (oEvent) {
            const arr = oEvent.getSource().getTarget().split('|')
            const url = document.location.origin + `/sap/opu/odata/sap/ZC_EP028_VACANCY_HEAD_CDS/ZI_EP0298_IAF_Attachment(guid=guid'${arr[0]}',atta_id='${arr[1]}')/$value`
            window.open(url)
        },

        onAddAttachment: function () {
            const _this = this
            sap.ui.require(["zep028lr/controller/FileUploadDialog"], function (FileUploadDialog) {
                if (!this._fileUploadDialog)
                    this._fileUploadDialog = new FileUploadDialog(this, function (sMsg, is_error) {
                        Libs.showMessage(sMsg, is_error)
                        this.byId(`${_this.ext.prefix}--idIafAttachmentTable`).rebindTable()
                    }.bind(this))

                const slug_obj = {
                    // ABAP style
                    guid: _this.curr_iaf_file.guid.replaceAll(`-`, ``).toUpperCase()
                }
                this._fileUploadDialog.add_files(slug_obj)
            }.bind(this.ext.owner))
        },

        onDeleteAttachment: function () {
            const files = this.ext.owner.byId(`${this.ext.prefix}--idIafAttachmentInnerTable`).getSelectedItems()

            sap.m.MessageBox.confirm(`Delete ${files.length} files ?`, {
                title: "Are you sure",

                onClose: function (action) {
                    if (action === "OK")
                        for (const item of files)
                            this._deleteOneFile(item.getBindingContext().getObject())
                }.bind(this)
            })
        },

        _deleteOneFile: function (object) {
            this.ext.owner.getOwnerComponent().getModel().remove(`/ZI_EP0298_IAF_Attachment(guid=guid'${object.guid}',atta_id='${object.atta_id}')`,
                {
                    success: function () {
                        this.ext.owner.byId(`${this.ext.prefix}--idIafAttachmentTable`).rebindTable()
                        Libs.showMessage(`File ${object.descr} was deleted!`)
                    }.bind(this)
                })
        },
    })
});

