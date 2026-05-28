"use client";

import { useState } from "react";
import { DailyPlan, Task, TimeSlot, TASK_COLORS } from "@/lib/types";
import { generateTaskId } from "@/lib/storage";

interface Props {
  plan: DailyPlan;
  onChange: (plan: DailyPlan) => void;
}

interface EditingTask {
  slotId: string;
  taskId?: string;
  text: string;
  color: string;
}

interface EditingSlot {
  id: string;
  startTime: string;
  endTime: string;
}

export default function GunlukSaatPlani({ plan, onChange }: Props) {
  const [editingTask, setEditingTask] = useState<EditingTask | null>(null);
  const [editingSlot, setEditingSlot] = useState<EditingSlot | null>(null);
  const [showAddSlot, setShowAddSlot] = useState(false);
  const [newSlot, setNewSlot] = useState({ startTime: "", endTime: "" });

  function openAddTask(slotId: string) {
    setEditingTask({ slotId, text: "", color: TASK_COLORS[0].value });
  }

  function openEditTask(slotId: string, task: Task) {
    setEditingTask({ slotId, taskId: task.id, text: task.text, color: task.color });
  }

  function saveTask() {
    if (!editingTask || !editingTask.text.trim()) return;

    const newSlots = plan.timeSlots.map((slot) => {
      if (slot.id !== editingTask.slotId) return slot;
      if (editingTask.taskId) {
        return {
          ...slot,
          tasks: slot.tasks.map((t) =>
            t.id === editingTask.taskId
              ? { ...t, text: editingTask.text, color: editingTask.color }
              : t
          ),
        };
      } else {
        return {
          ...slot,
          tasks: [
            ...slot.tasks,
            { id: generateTaskId(), text: editingTask.text, color: editingTask.color },
          ],
        };
      }
    });

    onChange({ ...plan, timeSlots: newSlots });
    setEditingTask(null);
  }

  function deleteTask(slotId: string, taskId: string) {
    const newSlots = plan.timeSlots.map((slot) =>
      slot.id === slotId
        ? { ...slot, tasks: slot.tasks.filter((t) => t.id !== taskId) }
        : slot
    );
    onChange({ ...plan, timeSlots: newSlots });
  }

  function saveSlotTime() {
    if (!editingSlot) return;
    const newSlots = plan.timeSlots.map((slot) =>
      slot.id === editingSlot.id
        ? { ...slot, startTime: editingSlot.startTime, endTime: editingSlot.endTime }
        : slot
    );
    onChange({ ...plan, timeSlots: newSlots });
    setEditingSlot(null);
  }

  function deleteSlot(slotId: string) {
    onChange({ ...plan, timeSlots: plan.timeSlots.filter((s) => s.id !== slotId) });
  }

  function addSlot() {
    if (!newSlot.startTime || !newSlot.endTime) return;
    const slot: TimeSlot = {
      id: generateTaskId(),
      startTime: newSlot.startTime,
      endTime: newSlot.endTime,
      tasks: [],
    };
    onChange({ ...plan, timeSlots: [...plan.timeSlots, slot] });
    setNewSlot({ startTime: "", endTime: "" });
    setShowAddSlot(false);
  }

  function formatTime(t: string) {
    return t.replace(":", ":");
  }

  return (
    <div className="bg-[#c8dde8] rounded-2xl p-4 mb-4">
      <h2 className="text-base font-black tracking-widest text-[#1a2a3a] mb-3 text-center">
        GÜNLÜK SAAT PLANI
      </h2>

      <div className="bg-white/40 rounded-xl overflow-hidden">
        {plan.timeSlots.map((slot) => (
          <div key={slot.id} className="border-b border-[#9bb8ca] last:border-b-0">
            <div className="grid gap-0" style={{ gridTemplateColumns: "110px 1fr auto" }}>
              {/* Time cell */}
              <button
                onClick={() =>
                  setEditingSlot({ id: slot.id, startTime: slot.startTime, endTime: slot.endTime })
                }
                className="py-2 px-2 text-left font-bold text-[#1a2a3a] text-xs leading-tight border-r border-[#9bb8ca] bg-white/30 active:bg-white/60"
              >
                {formatTime(slot.startTime)}-{formatTime(slot.endTime)}
              </button>

              {/* Tasks cell */}
              <div
                className="py-2 px-2 flex flex-col gap-1 min-h-[40px]"
                onClick={() => openAddTask(slot.id)}
              >
                {slot.tasks.length === 0 && (
                  <span className="text-[#7a9ab0] text-xs italic">Eklemek için dokun...</span>
                )}
                {slot.tasks.map((task) => (
                  <button
                    key={task.id}
                    onClick={(e) => {
                      e.stopPropagation();
                      openEditTask(slot.id, task);
                    }}
                    className="flex items-center gap-1 text-left w-full"
                  >
                    <span
                      className="w-3 h-3 rounded-sm flex-shrink-0"
                      style={{ backgroundColor: task.color }}
                    />
                    <span className="text-xs font-medium text-[#1a2a3a] uppercase leading-tight">
                      {task.text}
                    </span>
                  </button>
                ))}
              </div>

              {/* Delete slot */}
              <button
                onClick={() => deleteSlot(slot.id)}
                className="px-2 text-[#9bb8ca] active:text-red-500"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="18" y1="6" x2="6" y2="18" />
                  <line x1="6" y1="6" x2="18" y2="18" />
                </svg>
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Add slot button */}
      {showAddSlot ? (
        <div className="mt-3 bg-white/50 rounded-xl p-3 flex flex-col gap-2">
          <div className="flex gap-2">
            <div className="flex-1">
              <label className="text-xs text-[#4a7fa5] font-semibold">Başlangıç</label>
              <input
                type="time"
                value={newSlot.startTime}
                onChange={(e) => setNewSlot({ ...newSlot, startTime: e.target.value })}
                className="w-full mt-1 px-2 py-1 rounded-lg border border-[#9bb8ca] text-sm bg-white"
              />
            </div>
            <div className="flex-1">
              <label className="text-xs text-[#4a7fa5] font-semibold">Bitiş</label>
              <input
                type="time"
                value={newSlot.endTime}
                onChange={(e) => setNewSlot({ ...newSlot, endTime: e.target.value })}
                className="w-full mt-1 px-2 py-1 rounded-lg border border-[#9bb8ca] text-sm bg-white"
              />
            </div>
          </div>
          <div className="flex gap-2">
            <button
              onClick={addSlot}
              className="flex-1 py-2 rounded-lg bg-[#4a7fa5] text-white text-sm font-semibold"
            >
              Ekle
            </button>
            <button
              onClick={() => setShowAddSlot(false)}
              className="flex-1 py-2 rounded-lg bg-gray-200 text-gray-600 text-sm"
            >
              İptal
            </button>
          </div>
        </div>
      ) : (
        <button
          onClick={() => setShowAddSlot(true)}
          className="mt-3 w-full py-2 rounded-xl border-2 border-dashed border-[#4a7fa5] text-[#4a7fa5] text-sm font-semibold"
        >
          + Saat Dilimi Ekle
        </button>
      )}

      {/* Edit task modal */}
      {editingTask && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end">
          <div className="bg-white w-full rounded-t-3xl p-5 shadow-xl">
            <h3 className="font-bold text-[#1a2a3a] mb-4 text-base">
              {editingTask.taskId ? "Görevi Düzenle" : "Görev Ekle"}
            </h3>

            <input
              autoFocus
              type="text"
              value={editingTask.text}
              onChange={(e) => setEditingTask({ ...editingTask, text: e.target.value })}
              placeholder="Görev adı..."
              className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm mb-4 bg-gray-50"
              onKeyDown={(e) => e.key === "Enter" && saveTask()}
            />

            <div className="mb-4">
              <p className="text-xs text-gray-500 mb-2 font-semibold">RENK</p>
              <div className="flex gap-2 flex-wrap">
                {TASK_COLORS.map((c) => (
                  <button
                    key={c.value}
                    onClick={() => setEditingTask({ ...editingTask, color: c.value })}
                    className="w-8 h-8 rounded-lg transition-transform"
                    style={{
                      backgroundColor: c.value,
                      transform: editingTask.color === c.value ? "scale(1.2)" : "scale(1)",
                      outline: editingTask.color === c.value ? `2px solid ${c.value}` : "none",
                      outlineOffset: "2px",
                    }}
                  />
                ))}
              </div>
            </div>

            <div className="flex gap-3">
              {editingTask.taskId && (
                <button
                  onClick={() => {
                    deleteTask(editingTask.slotId, editingTask.taskId!);
                    setEditingTask(null);
                  }}
                  className="flex-1 py-3 rounded-xl bg-red-50 text-red-500 font-semibold text-sm"
                >
                  Sil
                </button>
              )}
              <button
                onClick={() => setEditingTask(null)}
                className="flex-1 py-3 rounded-xl bg-gray-100 text-gray-600 font-semibold text-sm"
              >
                İptal
              </button>
              <button
                onClick={saveTask}
                className="flex-1 py-3 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm"
              >
                Kaydet
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Edit slot time modal */}
      {editingSlot && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end">
          <div className="bg-white w-full rounded-t-3xl p-5 shadow-xl">
            <h3 className="font-bold text-[#1a2a3a] mb-4 text-base">Saati Düzenle</h3>
            <div className="flex gap-3 mb-4">
              <div className="flex-1">
                <label className="text-xs text-gray-500 font-semibold">BAŞLANGIÇ</label>
                <input
                  type="time"
                  value={editingSlot.startTime}
                  onChange={(e) => setEditingSlot({ ...editingSlot, startTime: e.target.value })}
                  className="w-full mt-1 px-3 py-2 rounded-xl border border-gray-200 bg-gray-50"
                />
              </div>
              <div className="flex-1">
                <label className="text-xs text-gray-500 font-semibold">BİTİŞ</label>
                <input
                  type="time"
                  value={editingSlot.endTime}
                  onChange={(e) => setEditingSlot({ ...editingSlot, endTime: e.target.value })}
                  className="w-full mt-1 px-3 py-2 rounded-xl border border-gray-200 bg-gray-50"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setEditingSlot(null)}
                className="flex-1 py-3 rounded-xl bg-gray-100 text-gray-600 font-semibold text-sm"
              >
                İptal
              </button>
              <button
                onClick={saveSlotTime}
                className="flex-1 py-3 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm"
              >
                Kaydet
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
