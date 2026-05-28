"use client";

import { useState } from "react";
import { DailyPlan, TodoItem } from "@/lib/types";
import { generateTaskId } from "@/lib/storage";
import {
  requestPermission,
  scheduleNotification,
  cancelNotification,
  todoIdToNotifId,
} from "@/lib/notifications";

interface Props {
  plan: DailyPlan;
  onChange: (plan: DailyPlan) => void;
}

interface EditState {
  id: string;
  text: string;
  reminder: string;
}

export default function YapilacaklarListesi({ plan, onChange }: Props) {
  const [newText, setNewText] = useState("");
  const [editing, setEditing] = useState<EditState | null>(null);
  const [reminderFor, setReminderFor] = useState<{ id: string; datetime: string } | null>(null);

  function addTodo() {
    if (!newText.trim()) return;
    const todo: TodoItem = {
      id: generateTaskId(),
      text: newText.trim(),
      completed: false,
    };
    onChange({ ...plan, todos: [...plan.todos, todo] });
    setNewText("");
  }

  function toggleTodo(id: string) {
    onChange({
      ...plan,
      todos: plan.todos.map((t) =>
        t.id === id ? { ...t, completed: !t.completed } : t
      ),
    });
  }

  function deleteTodo(id: string) {
    cancelNotification(todoIdToNotifId(id));
    onChange({ ...plan, todos: plan.todos.filter((t) => t.id !== id) });
  }

  function saveEdit() {
    if (!editing || !editing.text.trim()) return;
    onChange({
      ...plan,
      todos: plan.todos.map((t) =>
        t.id === editing.id ? { ...t, text: editing.text } : t
      ),
    });
    setEditing(null);
  }

  function openReminder(todo: TodoItem) {
    const now = new Date();
    now.setMinutes(now.getMinutes() + 30);
    const defaultDt = now.toISOString().slice(0, 16);
    setReminderFor({ id: todo.id, datetime: todo.reminder?.slice(0, 16) ?? defaultDt });
  }

  async function saveReminder() {
    if (!reminderFor) return;
    const granted = await requestPermission();
    if (!granted) {
      alert("Bildirim izni verilmedi. Lütfen tarayıcı/uygulama ayarlarından izin verin.");
      setReminderFor(null);
      return;
    }
    const todo = plan.todos.find((t) => t.id === reminderFor.id)!;
    const at = new Date(reminderFor.datetime);
    await scheduleNotification(
      todoIdToNotifId(todo.id),
      "Hatırlatıcı",
      todo.text,
      at
    );
    onChange({
      ...plan,
      todos: plan.todos.map((t) =>
        t.id === reminderFor.id ? { ...t, reminder: at.toISOString() } : t
      ),
    });
    setReminderFor(null);
  }

  async function removeReminder(id: string) {
    await cancelNotification(todoIdToNotifId(id));
    onChange({
      ...plan,
      todos: plan.todos.map((t) =>
        t.id === id ? { ...t, reminder: undefined } : t
      ),
    });
  }

  function formatReminder(iso: string) {
    const d = new Date(iso);
    return d.toLocaleString("tr-TR", {
      day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit",
    });
  }

  return (
    <div className="bg-[#4bbfcc] rounded-2xl p-4 mb-6">
      <h2 className="text-base font-black tracking-widest text-white mb-3 text-center">
        YAPILACAKLAR LİSTESİ
      </h2>

      <div className="flex flex-col gap-3 mb-3">
        {plan.todos.length === 0 && (
          <p className="text-white/60 text-sm text-center py-2">Henüz görev yok</p>
        )}
        {plan.todos.map((todo) => (
          <div key={todo.id} className="flex flex-col gap-1">
            <div className="flex items-center gap-2">
              {/* Checkbox */}
              <button
                onClick={() => toggleTodo(todo.id)}
                className={`w-5 h-5 rounded flex-shrink-0 border-2 flex items-center justify-center transition-colors ${
                  todo.completed ? "bg-white border-white" : "bg-transparent border-white"
                }`}
              >
                {todo.completed && (
                  <svg viewBox="0 0 16 16" fill="none" className="w-4 h-4">
                    <path d="M3 8l3.5 3.5L13 5" stroke="#4bbfcc" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                )}
              </button>

              {/* Text */}
              <button
                onClick={() => setEditing({ id: todo.id, text: todo.text, reminder: todo.reminder ?? "" })}
                className={`flex-1 text-left text-sm font-medium ${
                  todo.completed ? "line-through text-white/60" : "text-white"
                }`}
              >
                {todo.text}
              </button>

              {/* Bell button */}
              <button
                onClick={() => todo.reminder ? removeReminder(todo.id) : openReminder(todo)}
                className={`flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center transition-colors ${
                  todo.reminder ? "bg-yellow-300 text-yellow-900" : "bg-white/20 text-white"
                }`}
                title={todo.reminder ? "Hatırlatıcıyı kaldır" : "Hatırlatıcı ekle"}
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill={todo.reminder ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2">
                  <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                  <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                </svg>
              </button>

              {/* Delete */}
              <button onClick={() => deleteTodo(todo.id)} className="text-white/60 active:text-white flex-shrink-0">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                </svg>
              </button>
            </div>

            {/* Reminder badge */}
            {todo.reminder && (
              <div className="ml-7 flex items-center gap-1">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="currentColor" className="text-yellow-200">
                  <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                </svg>
                <span className="text-yellow-100 text-xs">{formatReminder(todo.reminder)}</span>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Add input */}
      <div className="flex gap-2">
        <input
          type="text"
          value={newText}
          onChange={(e) => setNewText(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && addTodo()}
          placeholder="Yeni görev ekle..."
          className="flex-1 px-3 py-2 rounded-xl bg-white/30 text-white placeholder-white/60 text-sm outline-none border border-white/30 focus:border-white"
        />
        <button
          onClick={addTodo}
          disabled={!newText.trim()}
          className="px-4 py-2 rounded-xl bg-white text-[#4bbfcc] font-bold text-sm disabled:opacity-50"
        >
          Ekle
        </button>
      </div>

      {/* Edit modal */}
      {editing && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end">
          <div className="bg-white w-full rounded-t-3xl p-5 shadow-xl">
            <h3 className="font-bold text-[#1a2a3a] mb-4 text-base">Görevi Düzenle</h3>
            <input
              autoFocus
              type="text"
              value={editing.text}
              onChange={(e) => setEditing({ ...editing, text: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm mb-4 bg-gray-50"
              onKeyDown={(e) => e.key === "Enter" && saveEdit()}
            />
            <div className="flex gap-3">
              <button onClick={() => setEditing(null)} className="flex-1 py-3 rounded-xl bg-gray-100 text-gray-600 font-semibold text-sm">İptal</button>
              <button onClick={saveEdit} className="flex-1 py-3 rounded-xl bg-[#4bbfcc] text-white font-semibold text-sm">Kaydet</button>
            </div>
          </div>
        </div>
      )}

      {/* Reminder modal */}
      {reminderFor && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end">
          <div className="bg-white w-full rounded-t-3xl p-5 shadow-xl">
            <h3 className="font-bold text-[#1a2a3a] mb-1 text-base">Hatırlatıcı Ekle</h3>
            <p className="text-xs text-gray-400 mb-4">Seçilen tarih ve saatte bildirim alırsın</p>
            <label className="text-xs font-bold text-gray-500 mb-2 block">TARİH VE SAAT</label>
            <input
              type="datetime-local"
              value={reminderFor.datetime}
              onChange={(e) => setReminderFor({ ...reminderFor, datetime: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm mb-5 bg-gray-50"
            />
            <div className="flex gap-3">
              <button onClick={() => setReminderFor(null)} className="flex-1 py-3 rounded-xl bg-gray-100 text-gray-600 font-semibold text-sm">İptal</button>
              <button onClick={saveReminder} className="flex-1 py-3 rounded-xl bg-[#4a7fa5] text-white font-semibold text-sm">
                🔔 Ayarla
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
