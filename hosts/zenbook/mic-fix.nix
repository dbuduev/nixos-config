# Microphone fixes for ASUS Zenbook S16 (ALC294 codec)
# - Lowers internal mic boost from +30dB to +10dB to reduce distortion
# - Optional: RNNoise-based noise suppression (uncomment to enable)
{pkgs, ...}: {
  # Lower internal mic boost (timer runs after WirePlumber settles)
  systemd.user.services.alsa-mic-boost = {
    description = "Set internal mic boost to reasonable level";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.alsa-utils}/bin/amixer -c 1 sset 'Internal Mic Boost',0 1";
    };
  };
  systemd.user.timers.alsa-mic-boost = {
    description = "Set internal mic boost after login";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnStartupSec = "3s";
      Unit = "alsa-mic-boost.service";
    };
  };

  # Optional: RNNoise-based noise suppression
  # Uncomment below to add a "Noise Canceling Source" virtual mic
  # Note: This keeps the mic icon red (filter always connected)

  # services.pipewire.wireplumber.extraConfig."51-mic-settings" = {
  #   "wireplumber.settings" = {
  #     "default.audio.source" = "rnnoise_source";
  #   };
  # };
  #
  # services.pipewire.extraConfig.pipewire."99-noise-suppression" = {
  #   "context.modules" = [
  #     {
  #       name = "libpipewire-module-filter-chain";
  #       args = {
  #         "node.description" = "Noise Canceling Source";
  #         "media.name" = "Noise Canceling Source";
  #         "filter.graph" = {
  #           nodes = [
  #             {
  #               type = "ladspa";
  #               name = "rnnoise";
  #               plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
  #               label = "noise_suppressor_stereo";
  #               control = {
  #                 "VAD Threshold (%)" = 50.0;
  #                 "VAD Grace Period (ms)" = 200;
  #                 "Retroactive VAD Grace (ms)" = 0;
  #               };
  #             }
  #           ];
  #         };
  #         "capture.props" = {
  #           "node.name" = "capture.rnnoise_source";
  #           "node.passive" = true;
  #           "audio.rate" = 48000;
  #           "audio.channels" = 2;
  #           "audio.position" = ["FL" "FR"];
  #         };
  #         "playback.props" = {
  #           "node.name" = "rnnoise_source";
  #           "media.class" = "Audio/Source";
  #           "audio.rate" = 48000;
  #           "audio.channels" = 2;
  #           "audio.position" = ["FL" "FR"];
  #         };
  #       };
  #     }
  #   ];
  # };
}
