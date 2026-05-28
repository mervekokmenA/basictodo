"use client";

import { useEffect, useState, useCallback } from "react";
import { DailyPlan } from "@/lib/types";
import { loadPlan, savePlan, formatDateKey } from "@/lib/storage";
import GunlukSaatPlani from "@/components/GunlukSaatPlani";
import YapilacaklarListesi from "@/components/YapilacaklarListesi";
import DateNavigator from "@/components/DateNavigator";

function addDays(dateKey: string, days: number): string {
  const d = new Date(dateKey + "T00:00:00");
  d.setDate(d.getDate() + days);
  return formatDateKey(d);
}

export default function DashboardPage() {
  const todayKey = formatDateKey(new Date());
  const [dateKey, setDateKey] = useState(todayKey);
  const [plan, setPlan] = useState<DailyPlan | null>(null);

  useEffect(() => {
    setPlan(loadPlan(dateKey));
  }, [dateKey]);

  const handleChange = useCallback(
    (updated: DailyPlan) => {
      setPlan(updated);
      savePlan(updated);
    },
    []
  );

  if (!plan) return null;

  return (
    <div className="min-h-screen pb-24" style={{ background: "var(--bg)" }}>
      {/* Header */}
      <div className="text-white px-5 pt-10 pb-4" style={{ background: "var(--header-bg)" }}>
        <div className="flex items-center justify-between">
          <span className="text-xs tracking-[0.2em] text-white/60 uppercase">TARİH</span>
          <h1 className="text-xl font-black tracking-[0.15em] uppercase">GÜNLÜK PLAN</h1>
        </div>
      </div>

      <DateNavigator
        dateKey={dateKey}
        onPrev={() => setDateKey((d) => addDays(d, -1))}
        onNext={() => setDateKey((d) => addDays(d, 1))}
        onToday={() => setDateKey(todayKey)}
        isToday={dateKey === todayKey}
      />

      <div className="px-4 pt-4">
        <GunlukSaatPlani plan={plan} onChange={handleChange} />
        <YapilacaklarListesi plan={plan} onChange={handleChange} />
      </div>
    </div>
  );
}
