import { LightningElement, api, wire, track } from "lwc";
import getAttendances from "@salesforce/apex/WFTAttendanceTableController.getAttendances";

export default class WftAttendanceTable2 extends LightningElement {
  @api recordId;
  @track attendances = [];
  noData;
  error;

  @wire(getAttendances, { recordId: "$recordId" })
  getAttendances({ data, error }) {
    if (data) {
      // eslint-disable-next-line guard-for-in
      for (let key in data) {
        this.attendances.push({ key: key, value: data[key] });
      }

      if (this.attendances.length > 0) {
        this.error = undefined;
        this.noData = undefined;
      } else {
        this.error = undefined;
        this.attendances = undefined;
        this.noData = "There are no Attendance records for this class";
      }
    } else if (error) {
      this.attendances = undefined;
      this.noData = undefined;
      this.error = error;
    }
  }
}