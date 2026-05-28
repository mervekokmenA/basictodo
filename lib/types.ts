export interface Task {
  id: string;
  text: string;
  color: string;
}

export interface TimeSlot {
  id: string;
  startTime: string;
  endTime: string;
  tasks: Task[];
}

export interface TodoItem {
  id: string;
  text: string;
  completed: boolean;
}

export interface DailyPlan {
  date: string;
  timeSlots: TimeSlot[];
  todos: TodoItem[];
}

export interface Routine {
  id: string;
  text: string;
  frequency: string;
}

export interface DailyStudy {
  date: string;
  selectedHobi: string[];
  selectedYazi: string[];
  selectedYabanciDil: string[];
  selectedGelisim: string[];
  notes: string;
  routinesDone: { [routineId: string]: boolean };
}

export const DEFAULT_TIME_SLOTS: Omit<TimeSlot, "id">[] = [
  { startTime: "07:00", endTime: "08:10", tasks: [] },
  { startTime: "08:15", endTime: "09:15", tasks: [] },
  { startTime: "12:30", endTime: "13:30", tasks: [] },
  { startTime: "17:45", endTime: "18:20", tasks: [] },
  { startTime: "18:20", endTime: "20:20", tasks: [] },
  { startTime: "20:30", endTime: "21:45", tasks: [] },
  { startTime: "22:00", endTime: "23:00", tasks: [] },
  { startTime: "23:00", endTime: "24:00", tasks: [] },
  { startTime: "00:00", endTime: "01:00", tasks: [] },
  { startTime: "01:00", endTime: "02:00", tasks: [] },
  { startTime: "02:00", endTime: "03:00", tasks: [] },
];

export const DEFAULT_ROUTINES: Routine[] = [
  { id: "r1", text: "İmajinasyon", frequency: "10 dk" },
  { id: "r2", text: "Düşünce görselleştirme", frequency: "10 dk" },
  { id: "r3", text: "Altın Oran Nefes Egzersizi", frequency: "3 günde 1" },
  { id: "r4", text: "Adım çalışması", frequency: "günlük" },
  { id: "r5", text: "Ayna çalışması", frequency: "günlük" },
  { id: "r6", text: "Yeni kozmik sembol çalışması ve imajinasyonu", frequency: "günlük" },
  { id: "r7", text: "Renk meditasyonu, her gün yeni renk", frequency: "günlük" },
  { id: "r8", text: "Beyaz gürültü dinleme", frequency: "günlük" },
  { id: "r9", text: "Dokunma, his çalışması", frequency: "günlük" },
  { id: "r10", text: "Tat koku, his çalışması", frequency: "günlük" },
  { id: "r11", text: "Gölge ve korkularla yüzleşme", frequency: "" },
  { id: "r12", text: "Rüya, duyu değişimi, vizyon detaylı takip ve not alma", frequency: "günlük" },
  { id: "r13", text: "Verilen araştırma konularına bakma", frequency: "günlük" },
];

export const HOBI_OPTIONS = ["KİL", "ELMAS BOYAMA", "RESİM", "MÜZİK"];
export const YAZI_OPTIONS = ["İÇERİK METNİ", "AKIŞ", "İMJ KİTAP"];
export const YABANCI_DIL_OPTIONS = ["İBRANİCE", "RUSÇA", "İNGİLİZCE"];
export const GELISIM_OPTIONS = ["VİBE CODİNG", "ASTROLOJİ", "CREATİVE DİRECTİNG"];

export const TASK_COLORS = [
  { label: "Mavi", value: "#4a7fa5" },
  { label: "Altın", value: "#c9a227" },
  { label: "Kırmızı", value: "#c0392b" },
  { label: "Turuncu", value: "#e08030" },
  { label: "Mor", value: "#7b5ea7" },
  { label: "Yeşil", value: "#2e8b57" },
  { label: "Pembe", value: "#c06080" },
  { label: "Lacivert", value: "#2c3e7a" },
];
