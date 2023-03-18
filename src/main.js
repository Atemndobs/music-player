import Vue from "vue";
import App from "./App.vue";
import { library } from "@fortawesome/fontawesome-svg-core";
import InstantSearch from "vue-instantsearch";

import {
  faPlay,
  faPause,
  faStepForward,
  faStepBackward,
  faTimes
} from "@fortawesome/free-solid-svg-icons";
import { faGithub } from "@fortawesome/free-brands-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
import vuetify from "./plugins/vuetify";

library.add(faPlay, faPause, faStepForward, faStepBackward, faTimes, faGithub);

Vue.component("font-awesome-icon", FontAwesomeIcon);
Vue.use(InstantSearch);

Vue.config.productionTip = false;

new Vue({
  vuetify,
  render: h => h(App)
}).$mount("#app");
