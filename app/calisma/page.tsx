"use client";

import { useEffect, useState, useCallback } from "react";
import { DailyStudy } from "@/lib/types";
import { loadStudy, saveStudy, loadSettings, formatDateKey } from "@/lib/storage";
import KategoriSecim from "@/components/KategoriSecim";
import DateNavigator from "@/components/DateNavigator";

function addDays(dateKey: string, days: number): string {
  const d = new Date(dateKey + "T00:00:00");
  d.setDate(d.getDate() + days);
  return formatDateKey(d);
}

export default function CalismaPage() {
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
    <div className="min-h-screen pb-24" style={{ background: "var(--bg)" }}>
      {/* Header */}
      <div className="text-white px-5 pt-10 pb-4" style={{ background: "var(--header-bg)" }}>
        <div className="flex items-center justify-between">
          <h1 className="text-lg font-black tracking-[0.1em] uppercase">Çalışmalar</h1>
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
          options={settings.hobiler}
          selected={study.selectedHobi}
          maxSelect={2}
          onToggle={(opt) => toggleOption("selectedHobi", opt, 2)}
        />
        <KategoriSecim
          label="YAZI"
          options={settings.yazilar}
          selected={study.selectedYazi}
          onToggle={(opt) => toggleOption("selectedYazi", opt)}
        />
        <KategoriSecim
          label="YABANCI DİL"
          options={settings.yabanciDiller}
          selected={study.selectedYabanciDil}
          maxSelect={1}
          onToggle={(opt) => toggleOption("selectedYabanciDil", opt, 1)}
        />
        <KategoriSecim
          label="GELİŞİM"
          options={settings.gelisimler}
          selected={study.selectedGelisim}
          onToggle={(opt) => toggleOption("selectedGelisim", opt)}
        />

        {/* Notes section */}
        <div className="bg-white rounded-2xl p-4 border border-gray-100 mt-2">
          <h3 className="text-xs font-black tracking-widest text-[#1a2a3a] mb-3 text-center">
            DÜŞÜNCE / NOT GÜNLÜĞÜ
          </h3>
          <textarea
            value={study.notes}
            onChange={(e) => handleChange({ ...study, notes: e.target.value })}
            placeholder="Düşüncelerini yaz..."
            className="w-full min-h-32 text-sm text-gray-700 bg-transparent resize-none outline-none leading-6 placeholder-gray-300"
          />
        </div>
      </div>
    </div>
  );
}
