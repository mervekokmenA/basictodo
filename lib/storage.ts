import { DailyPlan, DailyStudy, DEFAULT_TIME_SLOTS, TimeSlot } from "./types";

const PLANS_KEY = "gunluk_planlar";
const STUDIES_KEY = "calisma_hobiler";

function generateId(): string {
  return Math.random().toString(36).substr(2, 9);
}

export function createDefaultPlan(date: string): DailyPlan {
  return {
    date,
    timeSlots: DEFAULT_TIME_SLOTS.map((slot) => ({
      ...slot,
      id: generateId(),
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
