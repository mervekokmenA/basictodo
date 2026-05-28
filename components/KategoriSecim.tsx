"use client";

interface Props {
  label: string;
  options: string[];
  selected: string[];
  maxSelect?: number;
  onToggle: (option: string) => void;
}

export default function KategoriSecim({ label, options, selected, maxSelect, onToggle }: Props) {
  return (
    <div className="bg-[#e8e4d8] rounded-xl px-4 py-3 mb-2">
      <div className="flex items-center gap-2 mb-2 flex-wrap">
        <span className="text-xs font-black tracking-wider text-[#1a2a3a]">{label}:</span>
        {maxSelect && (
          <span className="text-xs text-gray-500">(en fazla {maxSelect} seçim)</span>
        )}
      </div>
      <div className="flex flex-wrap gap-2">
        {options.map((opt) => {
          const isSelected = selected.includes(opt);
          return (
            <button
              key={opt}
              onClick={() => onToggle(opt)}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold tracking-wide transition-colors ${
                isSelected
                  ? "bg-[#4a7fa5] text-white"
                  : "bg-white text-[#4a7fa5] border border-[#4a7fa5]/30"
              }`}
            >
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}
