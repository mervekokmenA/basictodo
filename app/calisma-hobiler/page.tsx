"use client";

import { useEffect, useState, useCallback } from "react";
import { DailyStudy, HOBI_OPTIONS, YAZI_OPTIONS, YABANCI_DIL_OPTIONS, GELISIM_OPTIONS } from "@/lib/types";
import { loadStudy, saveStudy, formatDateKey } from "@/lib/storage";
import KategoriSecim from "@/components/KategoriSecim";
import GunlukRutinler from "@/components/GunlukRutinler";
import DateNavigator from "@/components/DateNavigator";
import Navigation from "@/components/Navigation";

function addDays(dateKey: string, days: number): string {
  const d = new Date(dateKey + "T00:00:00");
  d.setDate(d.getDate() + days);
  return formatDateKey(d);
}

export default function CalismaHobilerPage() {
  const todayKey = formatDateKey(new Date());
  const [dateKey, setDateKey] = useState(todayKey);
  const [study, setStudy] = useState<DailyStudy | null>(null);

  useEffect(() => {
    setStudy(loadStudy(dateKey));
  }, [dateKey]);

  const handleChange = useCallback((updated: DailyStudy) => {
    setStudy(updated);
    saveStudy(updated);
  }, []);

  function toggleOption(
    field: "selectedHobi" | "selectedYazi" | "selectedYabanciDil" | "selectedGelisim",
    option: string,
    max?: number
  ) {
    if (!study) return;
    const current = study[field];
    let next: string[];
    if (current.includes(option)) {
      next = current.filter((o) => o !== option);
    } else {
      if (max && current.length >= max) {
        next = [...current.slice(1), option];
      } else {
        next = [...current, option];
      }
    }
    handleChange({ ...study, [field]: next });
  }

  if (!study) return null;

  return (
    <div className="min-h-screen bg-[#f0f4f7] pb-24">
      {/* Header */}
      <div className="bg-[#1a2a3a] text-white px-5 pt-10 pb-4">
        <div className="flex items-center justify-between">
          <h1 className="text-lg font-black tracking-[0.1em] uppercase">Çalışmalar–Hobiler</h1>
          <span className="text-xs tracking-[0.2em] text-white/60 uppercase">TARİH</span>
        </div>
        <p className="text-xs text-white/50 mt-1">GÜNLÜK İKİ SEÇİLİR TANE YAPILIR</p>
      </div>

      <DateNavigator
        dateKey={dateKey}
        onPrev={() => setDateKey((d) => addDays(d, -1))}
        onNext={() => setDateKey((d) => addDays(d, 1))}
        onToday={() => setDateKey(todayKey)}
        isToday={dateKey === todayKey}
      />

      <div className="px-4 pt-4 space-y-1">
        {/* Categories */}
        <KategoriSecim
          label="HOBİ"
          options={HOBI_OPTIONS}
          selected={study.selectedHobi}
          maxSelect={2}
          onToggle={(opt) => toggleOption("selectedHobi", opt, 2)}
        />
        <KategoriSecim
          label="YAZI"
          options={YAZI_OPTIONS}
          selected={study.selectedYazi}
          onToggle={(opt) => toggleOption("selectedYazi", opt)}
        />
        <KategoriSecim
          label="YABANCI DİL"
          options={YABANCI_DIL_OPTIONS}
          selected={study.selectedYabanciDil}
          maxSelect={1}
          onToggle={(opt) => toggleOption("selectedYabanciDil", opt, 1)}
        />
        <KategoriSecim
          label="GELİŞİM"
          options={GELISIM_OPTIONS}
          selected={study.selectedGelisim}
          onToggle={(opt) => toggleOption("selectedGelisim", opt)}
        />

        {/* Bottom section */}
        <div className="flex gap-3 pt-2">
          {/* Notes */}
          <div className="flex-1 bg-white rounded-2xl p-3 border border-gray-100">
            <h3 className="text-xs font-black tracking-widest text-[#1a2a3a] mb-2 text-center">
              DÜŞÜNCE / NOT GÜNLÜĞÜ
            </h3>
            <div className="flex flex-col gap-1 mb-2">
              {Array.from({ length: 12 }).map((_, i) => (
                <div key={i} className="w-2 h-2 rounded-full bg-gray-200 mx-auto" />
              ))}
            </div>
            <textarea
              value={study.notes}
              onChange={(e) => handleChange({ ...study, notes: e.target.value })}
              placeholder="Düşüncelerini yaz..."
              className="w-full h-40 text-xs text-gray-700 bg-transparent resize-none outline-none leading-6 placeholder-gray-300"
            />
          </div>

          {/* Routines */}
          <div className="flex-1 bg-white rounded-2xl p-3 border border-gray-100 overflow-y-auto max-h-[500px]">
            <GunlukRutinler study={study} onChange={handleChange} />
          </div>
        </div>
      </div>

      <Navigation />
    </div>
  );
}
