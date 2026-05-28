"use client";

import { DailyStudy, Routine } from "@/lib/types";
import { getRoutineStreak, isRoutineDoneRecently } from "@/lib/storage";
import ChecklistItem from "@/components/ChecklistItem";

interface Props {
  study: DailyStudy;
  onChange: (study: DailyStudy) => void;
  routines: Routine[];
  currentDate: string;
}

export default function GunlukRutinler({ study, onChange, routines, currentDate }: Props) {
  function toggle(routineId: string) {
    onChange({
      ...study,
      routinesDone: {
        ...study.routinesDone,
        [routineId]: !study.routinesDone[routineId],
      },
    });
  }

  const doneCount = routines.filter((r) => study.routinesDone[r.id]).length;

  return (
    <div className="flex-1">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-black tracking-widest text-[#1a2a3a]">GÜNLÜK RUTİNLER</h3>
        <span className="text-xs font-semibold text-[#4a7fa5] bg-[#e8f2fa] px-2 py-1 rounded-full">
          {doneCount}/{routines.length}
        </span>
      </div>

      <div className="flex flex-col gap-2">
        {routines.map((routine, i) => {
          const done = !!study.routinesDone[routine.id];
          const isThreeDayRoutine = routine.frequency === "3 günde 1";
          const doneRecently = isThreeDayRoutine
            ? isRoutineDoneRecently(routine.id, 3, currentDate)
            : false;
          const streak = getRoutineStreak(routine.id, currentDate);

          return (
            <div key={routine.id} className="relative">
              {doneRecently && !done && (
                <span className="block text-xs text-green-600 font-semibold mb-1 ml-8">
                  ✓ Son 3 günde yapıldı
                </span>
              )}
              <ChecklistItem
                checked={done}
                onToggle={() => toggle(routine.id)}
                label={`${i + 1}. ${routine.text}`}
                sublabel={routine.frequency || undefined}
                streak={streak > 1 ? streak : undefined}
                dimmed={doneRecently && !done}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
