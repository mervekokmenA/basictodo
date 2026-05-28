let capacitorAvailable = false;

async function getLocalNotifications() {
  if (typeof window === "undefined") return null;
  try {
    const { LocalNotifications } = await import("@capacitor/local-notifications");
    capacitorAvailable = true;
    return LocalNotifications;
  } catch {
    return null;
  }
}

export async function requestPermission(): Promise<boolean> {
  const ln = await getLocalNotifications();
  if (ln) {
    const result = await ln.requestPermissions();
    return result.display === "granted";
  }
  if ("Notification" in window) {
    const result = await Notification.requestPermission();
    return result === "granted";
  }
  return false;
}

export async function scheduleNotification(
  id: number,
  title: string,
  body: string,
  atDate: Date
): Promise<boolean> {
  const ln = await getLocalNotifications();

  if (ln && capacitorAvailable) {
    await ln.schedule({
      notifications: [
        {
          id,
          title,
          body,
          schedule: { at: atDate, allowWhileIdle: true },
          sound: undefined,
          attachments: undefined,
          actionTypeId: "",
          extra: null,
        },
      ],
    });
    return true;
  }

  // Web fallback: setTimeout (works while tab is open)
  const delay = atDate.getTime() - Date.now();
  if (delay < 0) return false;
  setTimeout(() => {
    if (Notification.permission === "granted") {
      new Notification(title, { body, icon: "/icon-192.png" });
    }
  }, delay);
  return true;
}

export async function cancelNotification(id: number): Promise<void> {
  const ln = await getLocalNotifications();
  if (ln && capacitorAvailable) {
    await ln.cancel({ notifications: [{ id }] });
  }
}

export function todoIdToNotifId(todoId: string): number {
  let hash = 0;
  for (let i = 0; i < todoId.length; i++) {
    hash = (hash << 5) - hash + todoId.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash) % 2_000_000;
}
