    module.exports = {

        // event handlers and functions are defined here

        // this is an example of an event handler
        view_updated: function(ui, event) {
            this.setPanels(ui, event);
        },

        view_creating: function(ui, event) {
            this.setPanels(ui, event);
        },

        view_loaded: function(ui, event) {
            // do something
            this.setPanels(ui, event);
        },


        reference_sd_changed: function(ui, event) {
          this.set_sdiff(ui, event);
        },


        comparison_sd_changed: function(ui, event) {
          this.set_sdiff(ui, event);
        },


        correlation_changed: function(ui, event) {
          if (ui.enter_r_or_sdiff.getValue() == "enter_r")  {
            this.set_sdiff(ui, event);
          }
        },

        sdiff_changed: function(ui, event) {
          if (ui.enter_r_or_sdiff.getValue() == "enter_sdiff")  {
            this.set_sdiff(ui, event);
          }
        },

        raw_button_changed: function(ui, event) {
            this.setPanels(ui, event);
        },

        effect_size_changed: function(ui, event) {
            if (ui.effect_size.getValue() == "median_difference") {
                ui.error_layout.setValue("none");
            }
        },

        set_sdiff: function(ui, event) {
          var s1, s2, r, sdiff;
          s1 = Number(ui.reference_sd.value());
          s2 = Number(ui.comparison_sd.value());

          if (ui.enter_r_or_sdiff.getValue() == "enter_r") {
            r = Number(ui.correlation.value());
            if (isNaN(s1) | isNaN(s2) | isNaN(r)) return;
            if (r < -1) return;
            if (r > 1) return;
            sdiff = (s1**2 + s2**2 - 2*r*s1*s2)**0.5;
            ui.sdiff.setValue(sdiff.toString());
            return;
          }

          if (ui.enter_r_or_sdiff.getValue() == "enter_sdiff") {
            sdiff = Number(ui.sdiff.getValue());
            r = (sdiff**2 - s1**2 - s2**2)/(-2*s1*s2);
            if (isNaN(s1) | isNaN(s2) | isNaN(sdiff)) return;
            ui.correlation.setValue(r.toString());
            return;
          }
        },

        // this is an example of an auxiliary function
        setPanels: function(ui, event) {
            // check if summary or raw data option selected, and then set panel and enabled states appropriately
            if (ui.summary_button.value()){
              // summary data option - expand that panel and collapse the raw panel
              // also set all controls in summary panel to be enabled
              // would be nice to be able to disable the controls in the raw data panel and/or expand option for that panel
              ui.spanel.expand();
              ui.rpanel.collapse();
              ui.effect_size.setValue("mean_difference");
              ui.show_ratio.setValue(false)
            } else {
              // raw data selected, so expand that panel, collapse summary data panel and disable its controls
              // would be nice to disable collapse/expand options on the panels, but doesn't seem possible at the moment
              ui.spanel.collapse();
              ui.rpanel.expand();
            }

        }


    };
