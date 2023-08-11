sap.ui.define([
	"zep028lr/controller/CurrentUser",
	"zep028lr/controller/Libs",
	"zep028lr/controller/IAF_Handler",

	"sap/uxap/ObjectPageSection",
	"sap/uxap/ObjectPageSubSection",
], function (CurrentUser, Libs, IAF_Handler, ObjectPageSection, ObjectPageSubSection) {
	"use strict";

	return {
		onInit: function () {
			window._objPageController = this
			
			this.getView().byId("objectPage").setUseIconTabBar(true)

			this.getView().byId(`action::bt_apply_job`).setIcon('sap-icon://workflow-tasks')
			this.getView().byId(`action::bt_print_jprf_letter`).setIcon('sap-icon://print')

			CurrentUser.read_now(this, this._after_read_current_user.bind(this))			
		},

		refresh_jprf_iaf_table: function (jprf_id) {
			this._jprf_id = jprf_id
			this.byId('jprf--idIafTable').rebindTable()
		},

		_after_read_current_user: function (userInfo) {
			if (!userInfo.is_admin) return

			const objectPageLayout = this.getView().byId('objectPage')
			objectPageLayout.attachSectionChange(function (oEvent) {

				switch (oEvent.getParameter('section').getId()) {
					case 'jprfSection':
						this.refresh_jprf_iaf_table(this.getView().byId('GenData::Section').getBindingContext().getObject().jprf_id)
						return
				}

			}.bind(this))

			//this.getView().byId(`AfterFacet::zc_ep028_vacancy_head::TechData::Section`).setVisible()
			const appliedSubSection = new ObjectPageSubSection({})
			const appliedSection = new ObjectPageSection({
				id: 'jprfSection',
				title: 'Applied Application Forms',
				subSections: [appliedSubSection]
			})
			objectPageLayout.addSection(appliedSection)


			const iafHandler = new IAF_Handler({
				owner: this,
				prefix: 'jprf',

				handleBeforeRebindIAFTable: function (oBindingParams) {
					oBindingParams.filters.push(new sap.ui.model.Filter("jprf_id", "EQ", this._jprf_id))
				}.bind(this)
			})

			sap.ui.core.Fragment.load({ id: this.getView().getId() + "--jprf", name: "zep028lr.fragment.IAF_frag", controller: iafHandler })
				.then(function (iafFragment) {
					appliedSubSection.addBlock(iafFragment)
				}.bind(this))
		},

		onApplyJobPress: function () {
			Libs.onApplyJobPress(CurrentUser._usr, this, this.getView().byId('GenData::Section').getBindingContext().getObject())
		},

		onPrintJprfLetter: function () {
			const obj = this.getView().getBindingContext().getObject()
			const url = document.location.origin + `/sap/opu/odata/sap/ZC_EP028_VACANCY_HEAD_CDS/ZI_EP0298_A_PRINT_JPRF_LETTER('${obj.jprf_id}')/$value`
			window.open(url)
		},

	}
})



