"use client";

import { formatDisplayDate } from "@/lib/storage";

interface Props {
  dateKey: string;
  onPrev: () => void;
  onNext: () => void;
  onToday: () => void;
  isToday: boolean;
}

export default function DateNavigator({ dateKey, onPrev, onNext, onToday, isToday }: Props) {
  return (
    <div className="flex items-center justify-between py-3 px-4 bg-white/80 backdrop-blur-sm sticky top-0 z-10 border-b border-gray-100">
      <button
        onClick={onPrev}
        className="w-9 h-9 flex items-center justify-center rounded-full bg-[#e8f2fa] text-[#4a7fa5] active:bg-[#4a7fa5] active:text-white"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <polyline points="15 18 9 12 15 6" />
        </svg>
      </button>

      <button
        onClick={onToday}
        className="flex flex-col items-center"
      >
        <span className="text-sm font-bold text-[#1a2a3a]">{formatDisplayDate(dateKey)}</span>
        {!isToday && (
          <span className="text-xs text-[#4a7fa5] font-semibold">Bugüne dön</span>
        )}
        {isToday && (
          <span className="text-xs text-gray-400">Bugün</span>
        )}
      </button>

      <button
        onClick={onNext}
        className="w-9 h-9 flex items-center justify-center rounded-full bg-[#e8f2fa] text-[#4a7fa5] active:bg-[#4a7fa5] active:text-white"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <polyline points="9 18 15 12 9 6" />
        </svg>
      </button>
    </div>
  );
}
