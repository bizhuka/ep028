
sap.ui.define([
    "zep028lr/controller/Libs",
], function (Libs) {
    "use strict";

    return {

        _usr: {
            pernr: '',
            login: '',
            ename: '',
            is_admin: false,

            menu: []
        },

        read_now: function (owner, callback) {
            owner.getOwnerComponent().getModel().read("/ZI_EP0298_Current_User", {
                filters: [new sap.ui.model.Filter("pernr", sap.ui.model.FilterOperator.EQ, `99999999`)], // ${Math.floor(Math.random() * 99999999)}

                success: function (data) {
                    callback(data.results[0])
                }
            })
        },

        init: function (owner) {
            this.owner = owner

            // Hide variant selection
            owner.getView().byId('template::PageVariant').setVisible(false)
            sap.ui.core.BusyIndicator.show(0)

            this._model = new sap.ui.model.json.JSONModel(this._usr)
            owner.getView().setModel(this._model, 'usr')

            this.read_now(owner, function (userInfo) {
                sap.ui.core.BusyIndicator.hide()

                this._usr.pernr = userInfo.pernr
                this._usr.login = userInfo.login
                this._usr.ename = userInfo.ename
                this._usr.is_admin = userInfo.is_admin
                this._usr.v_about_info = userInfo.v_about_info
                this._model.updateBindings()

                owner.byId('listReportFilter-filterItemControl_BASIC-status').setEnabled(this._usr.is_admin)
                owner.byId('addEntry').setVisible(this._usr.is_admin)
                owner.byId('addEntry').setText('Create by JPRF')
                owner.byId('bt_create_blank').setVisible(this._usr.is_admin)
                owner.byId('deleteEntry').setVisible(this._usr.is_admin)
                owner.byId('listReportFilter-btnClear').setVisible(this._usr.is_admin)
                owner.byId('template:::ListReportAction:::MultiEdit').setVisible(this._usr.is_admin)

                this._set_new_menu()
            }.bind(this))
        },

        _set_new_menu: function () {
            const menuButton = this.owner.byId('template::Share')
            // menuButton.setIcon('sap-icon://person-placeholder')
            menuButton.setIcon(Libs.get_avatar_url(this._usr.pernr))
            menuButton.setText(this._usr.ename)

            const internalBtn = this.owner.getView().byId('template::Share-internalBtn')

            for (let ind = internalBtn.mEventRegistry.press.length - 1; ind >= 0; ind--) {
                const handler = internalBtn.mEventRegistry.press[ind]
                internalBtn.detachPress(handler.fFunction, handler.oListener)
            }

            internalBtn.attachPress(function () {
                const nPernr = this._usr.pernr.replace(/^0+/, '')
                this._usr.menu = [
                    { key: "LOGIN", description: this._usr.login + (this._usr.is_admin ? ' (Admin)' : ''), icon: 'sap-icon://key' },
                    { key: "PERNR", description: `Person ID ${nPernr}`, icon: 'sap-icon://person-placeholder' },
                    // { key: "ABOUT", description: "About", icon: 'sap-icon://hint' }
                ]
                const oMenu1 = new sap.ui.unified.Menu({
                    items: {
                        path: "usr>/menu",
                        template: new sap.ui.unified.MenuItem({
                            icon: '{usr>icon}',
                            text: "{usr>description}"
                        })
                    },
                    itemSelect: function (oEvent) {
                        switch (oEvent.getParameter('item').getBindingContext('usr').getObject().key) {
                            case "PERNR":
                                window.open(`http://pas/ViewPersonDetails.aspx?PersonId=${nPernr}`)
                                return
                            case "ABOUT":
                                return
                        }
                    }.bind(this)
                })
                oMenu1.setModel(this._model, 'usr')
                oMenu1.openAsContextMenu({ offsetX: 0, offsetY: 30 }, internalBtn)
            }.bind(this))
        },

    }
})

