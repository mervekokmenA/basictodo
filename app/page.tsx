"use client";

import { useEffect, useState, useCallback } from "react";
import { DailyPlan } from "@/lib/types";
import { loadPlan, savePlan, formatDateKey } from "@/lib/storage";
import GunlukSaatPlani from "@/components/GunlukSaatPlani";
import YapilacaklarListesi from "@/components/YapilacaklarListesi";
import DateNavigator from "@/components/DateNavigator";
import Navigation from "@/components/Navigation";

function addDays(dateKey: string, days: number): string {
  const d = new Date(dateKey + "T00:00:00");
  d.setDate(d.getDate() + days);
  return formatDateKey(d);
}

export default function GunlukPlanPage() {
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
    <div className="min-h-screen bg-[#f0f4f7] pb-24">
      {/* Header */}
      <div className="bg-[#1a2a3a] text-white px-5 pt-10 pb-4">
        <div className="flex items-center justify-between">
          <span className="text-xs tracking-[0.2em] text-white/60 uppercase">TARİH</span>
          <h1 className="text-xl font-black tracking-[0.15em] uppercase">Günlük Plan</h1>
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

      <Navigation />
    </div>
  );
}
