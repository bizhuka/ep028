sap.ui.define([
    "zep028lr/controller/Libs",
    "sap/ui/base/Object",
    "sap/ui/model/json/JSONModel",
], function (Libs, Object, JSONModel) {
    "use strict";

    return Object.extend("zep028lr.controller.FileUploadDialog", {
        owner: null,
        dialog: null,

        _iaf_info: {
            is_new: false,
            employee: '',
            vacancy: '',
            comments: ''
        },

        constructor: function (owner, uploadOkCallback) {
            this.owner = owner
            this.uploadOkCallback = uploadOkCallback

            this.dialog = sap.ui.xmlfragment("zep028lr.fragment.FileUploadDialog", this)
            owner.getView().addDependent(this.dialog)

            this.iaf_info_model = new JSONModel()
            this.iaf_info_model.setDefaultBindingMode(sap.ui.model.BindingMode.TwoWay);
            this.iaf_info_model.setData(this._iaf_info)

            this.dialog.setModel(this.iaf_info_model, "iaf_info")
        },

        onBeforeDialogOpen: function (oEvent) {
            const dialog = oEvent.getSource()
            // TODO dynamic name
            this.oFileUploader = dialog.getContent()[0].getContent()[7]
            this.oFileUploader.setValue('')
        },

        apply_job: function (vacancy_info) {
            this._iaf_info.is_new = true
            this._iaf_info.employee = `${vacancy_info.ename} (${vacancy_info.pernr})`
            this._iaf_info.vacancy = `${vacancy_info.job_text} (${vacancy_info.job_id})`
            this._iaf_info.comments = ''

            this.iaf_info_model.updateBindings()

            this.slug_obj = {
                guid: this.get_new_guid(),
                file_name: '',
                employee_id: vacancy_info.pernr,
                vacancy_id: vacancy_info.job_id,
                // TODO pass to IAF
                jprf_id: vacancy_info.jprf_id
            }
            this.dialog.open()
        },

        get_new_guid: function () {
            const js_guid = ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
                (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16))

            // ABAP style
            return js_guid.replaceAll(`-`, ``).toUpperCase()
        },

        add_files: function (slug_obj) {
            this._iaf_info.is_new = false
            this.iaf_info_model.updateBindings()

            this.slug_obj = slug_obj
            this.dialog.open()
        },

        handleCancelPress: function () {
            this.dialog.close()
        },

        get_final_slug_object: function () {
            if (this._iaf_info.is_new)
                this.slug_obj.comments = this._iaf_info.comments

            return this.slug_obj
        },

        send_without_file: function () {
            const slug_obj = this.get_final_slug_object()
            this.owner.getView().getModel().create(`/ZI_EP0298_IAF_Attachment`, slug_obj,
                {
                    success: function (newItem) {
                        if (this.uploadOkCallback)
                            this.uploadOkCallback(newItem.message, newItem.is_error)
                    }.bind(this)
                })
        },

        handleUploadStart: function (oEvent) {
            const slug_obj = this.get_final_slug_object()
            slug_obj.file_name = oEvent.getParameter('fileName')

            oEvent.getParameter('requestHeaders').push({
                name: 'SLUG',
                value: Libs.get_as_slug(slug_obj)
            })
        },

        handleUploadComplete: function (oEvent) {
            //var oResourceBundle = this.getView().getModel("i18n").getResourceBundle();
            var oResponse = oEvent.getParameters("response");
            const xmlDoc = new DOMParser().parseFromString(oResponse.responseRaw, "text/xml")

            let is_error = false
            let sMsg = ''
            try {
                sMsg = xmlDoc.getElementsByTagName('d:message')[0].childNodes[0].nodeValue
                is_error = (xmlDoc.getElementsByTagName('d:is_error')[0].childNodes[0].nodeValue === 'true')
            } catch (error) {
                sMsg = xmlDoc.getElementsByTagName('message')[0].childNodes[0].nodeValue
                is_error = true
            }

            // refresh something
            if (this.uploadOkCallback)
                this.uploadOkCallback(sMsg, is_error)
        },

        handleUploadPress: function () {
            //check file has been entered
            var sFile = this.oFileUploader.getValue();
            if (!sFile) {

                // CV is not optional
                if (1 === 2 && this._iaf_info.is_new) {
                    this.send_without_file()
                    this.dialog.close()
                    return
                }

                Libs.showMessage("Please select a file first", true)
                return
            }

            this._addTokenToUploader()
            this.oFileUploader.upload()
            this.dialog.close()
        },

        _addTokenToUploader: function () {
            //Add header parameters to file uploader.
            var oDataModel = this.owner.getView().getModel()
            var sTokenForUpload = oDataModel.getSecurityToken()
            var oHeaderParameter = new sap.ui.unified.FileUploaderParameter({
                name: "X-CSRF-Token",
                value: sTokenForUpload
            })

            //Header parameter need to be removed then added.
            this.oFileUploader.removeAllHeaderParameters()
            this.oFileUploader.addHeaderParameter(oHeaderParameter)

            //set upload url
            var sUrl = oDataModel.sServiceUrl + "/ZI_EP0298_IAF_Attachment";
            this.oFileUploader.setUploadUrl(sUrl);
        }
    });
}
);