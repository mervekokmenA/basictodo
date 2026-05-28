"use client";

import { useEffect, useState, useCallback } from "react";
import { DailyStudy } from "@/lib/types";
import { loadStudy, saveStudy, loadSettings, formatDateKey, formatDisplayDate } from "@/lib/storage";
import GunlukRutinler from "@/components/GunlukRutinler";
import DateNavigator from "@/components/DateNavigator";

function addDays(dateKey: string, days: number): string {
  const d = new Date(dateKey + "T00:00:00");
  d.setDate(d.getDate() + days);
  return formatDateKey(d);
}

export default function RutinlerPage() {
  const todayKey = formatDateKey(new Date());
  const [dateKey, setDateKey] = useState(todayKey);
  const [study, setStudy] = useState<DailyStudy | null>(null);
  const settings = loadSettings();

  useEffect(() => {
    setStudy(loadStudy(dateKey));
  }, [dateKey]);

  const handleChange = useCallback((updated: DailyStudy) => {
    setStudy(updated);
    saveStudy(updated);
  }, []);

  if (!study) return null;

  const routines = settings.routines;
  const doneCount = routines.filter((r) => study.routinesDone[r.id]).length;
  const total = routines.length;
  const progressPct = total > 0 ? Math.round((doneCount / total) * 100) : 0;

  return (
    <div className="min-h-screen pb-24" style={{ background: "var(--bg)" }}>
      {/* Header */}
      <div className="text-white px-5 pt-10 pb-4" style={{ background: "var(--header-bg)" }}>
        <div className="flex items-center justify-between">
          <span className="text-xs tracking-[0.2em] text-white/60 uppercase">TARİH</span>
          <h1 className="text-xl font-black tracking-[0.15em] uppercase">GÜNLÜK RUTİNLER</h1>
        </div>
      </div>

      <DateNavigator
        dateKey={dateKey}
        onPrev={() => setDateKey((d) => addDays(d, -1))}
        onNext={() => setDateKey((d) => addDays(d, 1))}
        onToday={() => setDateKey(todayKey)}
        isToday={dateKey === todayKey}
      />

      {/* Progress bar */}
      <div className="px-4 pt-4 pb-2">
        <div className="flex items-center justify-between mb-1">
          <span className="text-xs font-semibold text-[#6b8499]">İlerleme</span>
          <span className="text-xs font-bold text-[#4a7fa5]">{doneCount}/{total}</span>
        </div>
        <div className="w-full h-2 rounded-full bg-gray-200">
          <div
            className="h-2 rounded-full bg-[#4a7fa5] transition-all"
            style={{ width: `${progressPct}%` }}
          />
        </div>
      </div>

      <div className="px-4 pt-2">
        <div className="bg-white rounded-2xl p-4 border border-gray-100">
          <GunlukRutinler
            study={study}
            onChange={handleChange}
            routines={routines}
            currentDate={dateKey}
          />
        </div>
      </div>
    </div>
  );
}
