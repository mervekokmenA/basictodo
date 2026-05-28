import { DailyPlan, DailyStudy, AppSettings, DEFAULT_SETTINGS, TimeSlot } from "./types";

const PLANS_KEY = "gunluk_planlar";
const STUDIES_KEY = "calisma_hobiler";
const SETTINGS_KEY = "app_settings";

function generateId(): string {
  return Math.random().toString(36).substr(2, 9);
}

export function generateTaskId(): string {
  return generateId();
}

export function formatDateKey(date: Date): string {
  return date.toISOString().split("T")[0];
}

export function formatDisplayDate(dateKey: string): string {
  const [y, m, d] = dateKey.split("-");
  return `${d}.${m}.${y}`;
}

export function loadSettings(): AppSettings {
  if (typeof window === "undefined") return DEFAULT_SETTINGS;
  try {
    const raw = localStorage.getItem(SETTINGS_KEY);
    if (!raw) return DEFAULT_SETTINGS;
    const parsed = JSON.parse(raw);
    // Merge with defaults to ensure all keys are present
    return {
      ...DEFAULT_SETTINGS,
      ...parsed,
    };
  } catch {
    return DEFAULT_SETTINGS;
  }
}

export function saveSettings(settings: AppSettings): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
}

export function createDefaultPlan(date: string, settings?: AppSettings): DailyPlan {
  const s = settings ?? loadSettings();
  return {
    date,
    timeSlots: s.defaultTimeSlots.map((slot) => ({
      ...slot,
      id: generateId(),
      tasks: [],
    })) as TimeSlot[],
    todos: [],
  };
}

export function createDefaultStudy(date: string): DailyStudy {
  return {
    date,
    selectedHobi: [],
    selectedYazi: [],
    selectedYabanciDil: [],
    selectedGelisim: [],
    notes: "",
    routinesDone: {},
  };
}

export function loadPlans(): { [date: string]: DailyPlan } {
  if (typeof window === "undefined") return {};
  try {
    const raw = localStorage.getItem(PLANS_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function savePlan(plan: DailyPlan): void {
  if (typeof window === "undefined") return;
  const all = loadPlans();
  all[plan.date] = plan;
  localStorage.setItem(PLANS_KEY, JSON.stringify(all));
}

export function loadPlan(date: string): DailyPlan {
  const all = loadPlans();
  return all[date] ?? createDefaultPlan(date);
}

export function loadStudies(): { [date: string]: DailyStudy } {
  if (typeof window === "undefined") return {};
  try {
    const raw = localStorage.getItem(STUDIES_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function saveStudy(study: DailyStudy): void {
  if (typeof window === "undefined") return;
  const all = loadStudies();
  all[study.date] = study;
  localStorage.setItem(STUDIES_KEY, JSON.stringify(all));
}

export function loadStudy(date: string): DailyStudy {
  const all = loadStudies();
  return all[date] ?? createDefaultStudy(date);
}

/**
 * Returns how many consecutive days the routine was done, counting backwards
 * from the day BEFORE currentDate (max 60 days).
 */
export function getRoutineStreak(routineId: string, currentDate: string): number {
  const all = loadStudies();
  let streak = 0;
  const base = new Date(currentDate + "T00:00:00");
  for (let i = 1; i <= 60; i++) {
    const d = new Date(base);
    d.setDate(d.getDate() - i);
    const key = formatDateKey(d);
    const study = all[key];
    if (study && study.routinesDone[routineId]) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/**
 * Returns true if the routine was done at least once in the last `daysBack` days
 * (not counting currentDate itself).
 */
export function isRoutineDoneRecently(
  routineId: string,
  daysBack: number,
  currentDate: string
): boolean {
  const all = loadStudies();
  const base = new Date(currentDate + "T00:00:00");
  for (let i = 1; i <= daysBack; i++) {
    const d = new Date(base);
    d.setDate(d.getDate() - i);
    const key = formatDateKey(d);
    const study = all[key];
    if (study && study.routinesDone[routineId]) {
      return true;
    }
  }
  return false;
}
