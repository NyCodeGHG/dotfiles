{ config, inputs, ... }:
{
  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "alertmanager";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.alertmanager.port}" ];
            labels = {
              instance = config.networking.hostName;
            };
          }
        ];
      }
    ];
    alertmanagers = [{
      scheme = "http";
      path_prefix = "/";
      static_configs = [
        {
          targets = [
            "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
          ];
        }
      ];
    }];
    alertmanager = {
      enable = true;
      webExternalUrl = "https://am.marie.cologne";
      environmentFile = config.age.secrets.discord-webhook.path;
      configuration = {
        receivers = [{
          name = "discord";
          discord_configs = [
            {
              webhook_url = "https://discord.com/api/webhooks/1113658991696953374/$DISCORD_WEBHOOK";
              title = ''
                [{{ .Status | toUpper }}:{{ if eq .Status "firing" }}{{ .Alerts.Firing | len }}{{ else }}{{ .Alerts.Resolved | len }}{{ end }}]
              '';
              message = ''
                {{- range .Alerts }}
                  **{{ .Labels.alertname }} {{ if ne .Labels.severity "" }}({{ .Labels.severity | title }}){{ end }} **
                  {{- if ne .Annotations.description "" }}
                    **Description:** {{ .Annotations.description }}
                  {{- else if ne .Annotations.summary "" }}
                    **Summary:** {{ .Annotations.summary }}
                  {{- else if ne .Annotations.message "" }}
                    **Message:** {{ .Annotations.message }}
                  {{- else }}
                    **Description:** N/A
                  {{- end }}
                {{- end }}
              '';
            }
          ];
        }];
        route = {
          receiver = "discord";
        };
      };
    };
  };
  age.secrets.discord-webhook.file = "${inputs.self}/secrets/discord-webhook.age";
  services.nginx.virtualHosts = {
    "am.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.prometheus.alertmanager.port}";
        proxyWebsockets = true;
        extraConfig = ''
          allow 127.0.0.1/24;
          allow 10.69.0.1/24;
          deny all;
        '';
      };
    };
  };
}
