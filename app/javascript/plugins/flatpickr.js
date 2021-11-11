// import flatpickr from "flatpickr";

// const initFlatpickr = () => {
//   flatpickr(".datepicker", {});
// }

// export { initFlatpickr };

import flatpickr from "flatpickr";
import { Portuguese } from "flatpickr/dist/l10n/pt.js"
import rangePlugin from "flatpickr/dist/plugins/rangePlugin";

const initFlatpickr = () => {
  flatpickr("#range_start", {
    altInput: true,
    plugins: [new rangePlugin({ input: "#range_end" })],
    locale: Portuguese,
    format: "d/m/Y",
    altFormat: "d/m/Y",
    dateFormat: 'd/m/Y'
  });

}

export { initFlatpickr };
