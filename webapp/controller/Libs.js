
sap.ui.define([
    "sap/m/MessageToast",
], function (MessageToast) {
    "use strict";

    return {

        showMessage: function (message, error) {
            MessageToast.show(message, { duration: 3500 })
            if (error)
                $(".sapMMessageToast").css("background", "#cc1919")
        },

        get_avatar_url: function (pernr, size) {
            const urlBig = `${document.location.origin}/sap/opu/odata/sap/ZC_PY000_REPORT_CDS/ZC_PY000_PernrPhoto(pernr='${pernr}')/$value`
            if (size) return `${urlBig}?$filter=${encodeURIComponent(`img_size eq ${size}`)}`
            return urlBig
        },

        send_request: function (theUrl, callback) {
            var xmlHttp = new XMLHttpRequest()

            if (callback)
                xmlHttp.onreadystatechange = function () {
                    if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                        callback(xmlHttp.responseText)
                }
            xmlHttp.open("GET", theUrl, true) // true for asynchronous 
            xmlHttp.send(null)
        },

        get_as_slug: function (obj) {
            const arr_pairs = []
            for (const key in obj)
                if (obj.hasOwnProperty(key)) {
                    let value = obj[key]

                    // special delimeters
                    if (typeof value === 'string')
                        value = value.replaceAll(`|`, ``).replaceAll(`:`, ``)

                    arr_pairs.push(key + ':' + value)
                }

            return arr_pairs.join('|')
        },

        onApplyJobPress: function (userInfo, owner, vacancy_obj) {
            if (vacancy_obj.status !== 'VISIBLE') {
                this.showMessage(`The vancany is not visible yet`, true)
                return
            }

            if (userInfo.is_admin) {
                this.showMessage(`'Apply on job' is not available for admin roles`, true)
                return
            }

            const vacancy_info = {
                pernr: userInfo.pernr,
                ename: userInfo.ename,

                job_id: vacancy_obj.job_id,
                job_text: vacancy_obj.stltx,

                // TODO pass to IAF
                jprf_id: vacancy_obj.jprf_id,
            }

            const _this = this
            sap.ui.require(["zep028lr/controller/FileUploadDialog"], function (FileUploadDialog) {
                if (!owner._fileUploadDialog)
                    owner._fileUploadDialog = new FileUploadDialog(owner, function (sMsg, is_error) {
                        _this.showMessage(sMsg, is_error)
                    }.bind(owner))

                owner._fileUploadDialog.apply_job(vacancy_info)
            })

        },
    };
});

