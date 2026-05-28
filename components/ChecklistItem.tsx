"use client";

interface Props {
  checked: boolean;
  onToggle: () => void;
  label: string;
  sublabel?: string;
  streak?: number;
  dimmed?: boolean;
}

export default function ChecklistItem({ checked, onToggle, label, sublabel, streak, dimmed }: Props) {
  return (
    <button
      onClick={dimmed ? undefined : onToggle}
      disabled={dimmed}
      className={`flex items-start gap-3 text-left w-full relative ${dimmed ? "opacity-40 cursor-not-allowed" : ""}`}
    >
      {/* Checkbox */}
      <span
        className={`w-5 h-5 rounded flex-shrink-0 border-2 mt-0.5 flex items-center justify-center transition-colors ${
          checked ? "bg-[#4a7fa5] border-[#4a7fa5]" : "border-gray-300 bg-white"
        }`}
      >
        {checked && (
          <svg viewBox="0 0 16 16" fill="none" className="w-3 h-3">
            <path
              d="M3 8l3.5 3.5L13 5"
              stroke="white"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        )}
      </span>

      {/* Text */}
      <div className="flex-1 min-w-0">
        <span
          className={`text-sm leading-snug block ${
            checked ? "line-through text-gray-400" : "text-[#1a2a3a]"
          }`}
        >
          {label}
        </span>
        {sublabel && (
          <span className="block text-xs text-gray-400 mt-0.5">{sublabel}</span>
        )}
      </div>

      {/* Streak badge */}
      {streak !== undefined && streak > 0 && (
        <span className="flex-shrink-0 flex items-center gap-0.5 bg-yellow-100 text-yellow-700 text-xs font-bold px-1.5 py-0.5 rounded-full">
          🔥 {streak}
        </span>
      )}
    </button>
  );
}
