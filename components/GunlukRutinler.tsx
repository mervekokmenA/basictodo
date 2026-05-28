"use client";

import { DailyStudy, DEFAULT_ROUTINES } from "@/lib/types";

interface Props {
  study: DailyStudy;
  onChange: (study: DailyStudy) => void;
}

export default function GunlukRutinler({ study, onChange }: Props) {
  function toggle(routineId: string) {
    onChange({
      ...study,
      routinesDone: {
        ...study.routinesDone,
        [routineId]: !study.routinesDone[routineId],
      },
    });
  }

  const doneCount = DEFAULT_ROUTINES.filter((r) => study.routinesDone[r.id]).length;

  return (
    <div className="flex-1">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-black tracking-widest text-[#1a2a3a]">GÜNLÜK RUTİNLER</h3>
        <span className="text-xs font-semibold text-[#4a7fa5] bg-[#e8f2fa] px-2 py-1 rounded-full">
          {doneCount}/{DEFAULT_ROUTINES.length}
        </span>
      </div>

      <div className="flex flex-col gap-2">
        {DEFAULT_ROUTINES.map((routine, i) => {
          const done = !!study.routinesDone[routine.id];
          return (
            <button
              key={routine.id}
              onClick={() => toggle(routine.id)}
              className="flex items-start gap-3 text-left w-full"
            >
              <span
                className={`w-5 h-5 rounded flex-shrink-0 border-2 mt-0.5 flex items-center justify-center transition-colors ${
                  done ? "bg-[#4a7fa5] border-[#4a7fa5]" : "border-gray-300 bg-white"
                }`}
              >
                {done && (
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
              <div className="flex-1">
                <span
                  className={`text-sm leading-snug ${
                    done ? "line-through text-gray-400" : "text-[#1a2a3a]"
                  }`}
                >
                  <span className="font-bold text-xs text-[#4a7fa5] mr-1">{i + 1}.</span>
                  {routine.text}
                </span>
                {routine.frequency && (
                  <span className="block text-xs text-gray-400 mt-0.5">{routine.frequency}</span>
                )}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
