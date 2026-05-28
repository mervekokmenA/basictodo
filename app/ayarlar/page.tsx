"use client";

import { useState, useEffect } from "react";
import { AppSettings } from "@/lib/types";
import { loadSettings, saveSettings } from "@/lib/storage";

export default function AyarlarPage() {
  const [settings, setSettings] = useState<AppSettings | null>(null);

  // New time slot state
  const [newStart, setNewStart] = useState("");
  const [newEnd, setNewEnd] = useState("");

  // New category inputs
  const [newHobi, setNewHobi] = useState("");
  const [newYazi, setNewYazi] = useState("");
  const [newDil, setNewDil] = useState("");
  const [newGelisim, setNewGelisim] = useState("");

  // New routine inputs
  const [newRoutineText, setNewRoutineText] = useState("");
  const [newRoutineFreq, setNewRoutineFreq] = useState("");

  useEffect(() => {
    setSettings(loadSettings());
  }, []);

  function update(next: AppSettings) {
    setSettings(next);
    saveSettings(next);
  }

  function setTheme(theme: "light" | "dark") {
    if (!settings) return;
    const next = { ...settings, theme };
    update(next);
    document.documentElement.classList.toggle("dark", theme === "dark");
  }

  function removeTimeSlot(index: number) {
    if (!settings) return;
    const next = { ...settings, defaultTimeSlots: settings.defaultTimeSlots.filter((_, i) => i !== index) };
    update(next);
  }

  function addTimeSlot() {
    if (!settings || !newStart || !newEnd) return;
    const next = { ...settings, defaultTimeSlots: [...settings.defaultTimeSlots, { startTime: newStart, endTime: newEnd }] };
    update(next);
    setNewStart("");
    setNewEnd("");
  }

  function removeCategory(field: "hobiler" | "yazilar" | "yabanciDiller" | "gelisimler", index: number) {
    if (!settings) return;
    const next = { ...settings, [field]: settings[field].filter((_: string, i: number) => i !== index) };
    update(next);
  }

  function addCategory(field: "hobiler" | "yazilar" | "yabanciDiller" | "gelisimler", value: string, clear: () => void) {
    if (!settings || !value.trim()) return;
    const next = { ...settings, [field]: [...settings[field], value.trim().toUpperCase()] };
    update(next);
    clear();
  }

  function removeRoutine(id: string) {
    if (!settings) return;
    const next = { ...settings, routines: settings.routines.filter((r) => r.id !== id) };
    update(next);
  }

  function addRoutine() {
    if (!settings || !newRoutineText.trim()) return;
    const id = "r" + Date.now();
    const next = { ...settings, routines: [...settings.routines, { id, text: newRoutineText.trim(), frequency: newRoutineFreq.trim() }] };
    update(next);
    setNewRoutineText("");
    setNewRoutineFreq("");
  }

  if (!settings) return null;

  return (
    <div className="min-h-screen pb-24" style={{ background: "var(--bg)" }}>
      {/* Header */}
      <div className="text-white px-5 pt-10 pb-4" style={{ background: "var(--header-bg)" }}>
        <h1 className="text-xl font-black tracking-[0.15em] uppercase text-center">AYARLAR</h1>
      </div>

      <div className="px-4 pt-4 space-y-4">

        {/* Section 1: Theme */}
        <div className="bg-white rounded-2xl p-4 border border-gray-100">
          <h2 className="text-sm font-black tracking-widest text-[#1a2a3a] mb-3">TEMA</h2>
          <div className="flex gap-3">
            <button
              onClick={() => setTheme("light")}
              className={`flex-1 py-2.5 rounded-xl font-semibold text-sm transition-colors ${
                settings.theme === "light"
                  ? "bg-[#4a7fa5] text-white"
                  : "bg-gray-100 text-gray-600"
              }`}
            >
              Açık
            </button>
            <button
              onClick={() => setTheme("dark")}
              className={`flex-1 py-2.5 rounded-xl font-semibold text-sm transition-colors ${
                settings.theme === "dark"
                  ? "bg-[#4a7fa5] text-white"
                  : "bg-gray-100 text-gray-600"
              }`}
            >
              Koyu
            </button>
          </div>
        </div>

        {/* Section 2: Time Slots */}
        <div className="bg-white rounded-2xl p-4 border border-gray-100">
          <h2 className="text-sm font-black tracking-widest text-[#1a2a3a] mb-3">SAAT ARALIKLARI</h2>
          <div className="flex flex-col gap-2 mb-3">
            {settings.defaultTimeSlots.map((slot, i) => (
              <div key={i} className="flex items-center justify-between py-1">
                <span className="text-sm font-medium text-[#1a2a3a]">
                  {slot.startTime} – {slot.endTime}
                </span>
                <button
                  onClick={() => removeTimeSlot(i)}
                  className="text-gray-400 active:text-red-500 p-1"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                  </svg>
                </button>
              </div>
            ))}
          </div>
          <div className="flex gap-2 mb-2">
            <div className="flex-1">
              <label className="text-xs text-[#4a7fa5] font-semibold">Başlangıç</label>
              <input
                type="time"
                value={newStart}
                onChange={(e) => setNewStart(e.target.value)}
                className="w-full mt-1 px-2 py-1.5 rounded-lg border border-gray-200 text-sm bg-gray-50"
              />
            </div>
            <div className="flex-1">
              <label className="text-xs text-[#4a7fa5] font-semibold">Bitiş</label>
              <input
                type="time"
                value={newEnd}
                onChange={(e) => setNewEnd(e.target.value)}
                className="w-full mt-1 px-2 py-1.5 rounded-lg border border-gray-200 text-sm bg-gray-50"
              />
            </div>
          </div>
          <button
            onClick={addTimeSlot}
            className="w-full py-2 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm"
          >
            Ekle
          </button>
        </div>

        {/* Section 3: Categories */}
        {(
          [
            { field: "hobiler" as const, label: "HOBİ", value: newHobi, set: setNewHobi },
            { field: "yazilar" as const, label: "YAZI", value: newYazi, set: setNewYazi },
            { field: "yabanciDiller" as const, label: "YABANCI DİL", value: newDil, set: setNewDil },
            { field: "gelisimler" as const, label: "GELİŞİM", value: newGelisim, set: setNewGelisim },
          ] as const
        ).map(({ field, label, value, set }) => (
          <div key={field} className="bg-white rounded-2xl p-4 border border-gray-100">
            <h2 className="text-sm font-black tracking-widest text-[#1a2a3a] mb-3">{label}</h2>
            <div className="flex flex-wrap gap-2 mb-3">
              {settings[field].map((item: string, i: number) => (
                <div key={i} className="flex items-center gap-1 bg-[#e8f2fa] rounded-lg px-2 py-1">
                  <span className="text-xs font-semibold text-[#4a7fa5]">{item}</span>
                  <button
                    onClick={() => removeCategory(field, i)}
                    className="text-[#4a7fa5]/60 active:text-red-500"
                  >
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
            <div className="flex gap-2">
              <input
                type="text"
                value={value}
                onChange={(e) => set(e.target.value)}
                placeholder="Yeni ekle..."
                className="flex-1 px-3 py-1.5 rounded-xl border border-gray-200 text-sm bg-gray-50"
                onKeyDown={(e) => e.key === "Enter" && addCategory(field, value, () => set(""))}
              />
              <button
                onClick={() => addCategory(field, value, () => set(""))}
                className="px-4 py-1.5 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm"
              >
                Ekle
              </button>
            </div>
          </div>
        ))}

        {/* Section 4: Routines */}
        <div className="bg-white rounded-2xl p-4 border border-gray-100">
          <h2 className="text-sm font-black tracking-widest text-[#1a2a3a] mb-3">RUTİNLER</h2>
          <div className="flex flex-col gap-2 mb-3">
            {settings.routines.map((routine) => (
              <div key={routine.id} className="flex items-start justify-between gap-2 py-1">
                <div className="flex-1 min-w-0">
                  <span className="text-sm text-[#1a2a3a] font-medium block">{routine.text}</span>
                  {routine.frequency && (
                    <span className="text-xs text-gray-400">{routine.frequency}</span>
                  )}
                </div>
                <button
                  onClick={() => removeRoutine(routine.id)}
                  className="text-gray-400 active:text-red-500 p-1 flex-shrink-0"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                  </svg>
                </button>
              </div>
            ))}
          </div>
          <div className="flex flex-col gap-2">
            <input
              type="text"
              value={newRoutineText}
              onChange={(e) => setNewRoutineText(e.target.value)}
              placeholder="Rutin adı..."
              className="w-full px-3 py-1.5 rounded-xl border border-gray-200 text-sm bg-gray-50"
            />
            <input
              type="text"
              value={newRoutineFreq}
              onChange={(e) => setNewRoutineFreq(e.target.value)}
              placeholder="Frekans (örn: günlük, 3 günde 1)..."
              className="w-full px-3 py-1.5 rounded-xl border border-gray-200 text-sm bg-gray-50"
            />
            <button
              onClick={addRoutine}
              className="w-full py-2 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm"
            >
              Rutin Ekle
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
