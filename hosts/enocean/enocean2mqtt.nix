{
  config,
  lib,
  pkgs,
  ...
}:
let
  configFile = pkgs.writeText "enocean2mqtt.kdl" ''
    serial {
        port "/dev/ttyAMA0"
        baud-rate 57600
    }

    devices {
        shutter_left {
            name "Rollladen-L"
            radio-id 0x05893D1F
            sender-offset 4

            profile {
                eep "D2-05-02"
                tilt-control #false
            }
            profile {
                eep "F6-02-01"            
            }
        }

        shutter_right {
            name "Rollladen-R"
            radio-id 0x05893D15
            sender-offset 5

            profile {
                eep "D2-05-02"
                tilt-control #false
            }

            profile {
                eep "F6-02-01"
            }
        }
    }

    mqtt {
        broker "mqtts://mqtt.home.marie.cologne:8883"
        credentials {
            username "enocean2mqtt"
            password {
                systemd-credential "mqtt-password"
            }
        }
    }
  '';
in
{
  systemd.services.enocean2mqtt = {
    after = [
      "network.target"
      "dev-ttyAMA0.device"
    ];
    wants = [ "network.target" ];
    bindsTo = [ "dev-ttyAMA0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.enocean2mqtt} run --config ${configFile}";
      DynamicUser = true;
      SupplementaryGroups = [ "dialout" ];
      DevicePolicy = "closed";
      DeviceAllow = [ "/dev/ttyAMA0 rw" ];
      LoadCredential = "mqtt-password:${config.age.secrets.mqtt-password.path}";
    };
  };

  age.secrets.mqtt-password.file = ./mqtt-password.age;
}
