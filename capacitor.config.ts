import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "com.merve.gunlukplanlayici",
  appName: "Günlük Planlayıcı",
  webDir: "out",
  android: {
    backgroundColor: "#1a2a3a",
  },
  plugins: {
    LocalNotifications: {
      smallIcon: "ic_stat_icon_config_sample",
      iconColor: "#4a7fa5",
      sound: "beep.wav",
    },
  },
};

export default config;
