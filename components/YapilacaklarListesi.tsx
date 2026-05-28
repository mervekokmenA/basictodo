"use client";

import { useState } from "react";
import { DailyPlan, TodoItem } from "@/lib/types";
import { generateTaskId } from "@/lib/storage";

interface Props {
  plan: DailyPlan;
  onChange: (plan: DailyPlan) => void;
}

export default function YapilacaklarListesi({ plan, onChange }: Props) {
  const [newText, setNewText] = useState("");
  const [editing, setEditing] = useState<{ id: string; text: string } | null>(null);

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

  return (
    <div className="bg-[#4bbfcc] rounded-2xl p-4 mb-6">
      <h2 className="text-base font-black tracking-widest text-white mb-3 text-center">
        YAPILACAKLAR LİSTESİ
      </h2>

      <div className="flex flex-col gap-2">
        {plan.todos.map((todo) => (
          <div key={todo.id} className="flex items-center gap-3">
            <button
              onClick={() => toggleTodo(todo.id)}
              className={`w-5 h-5 rounded flex-shrink-0 border-2 transition-colors ${
                todo.completed
                  ? "bg-white border-white"
                  : "bg-transparent border-white"
              }`}
            >
              {todo.completed && (
                <svg viewBox="0 0 16 16" fill="none" className="w-4 h-4">
                  <path
                    d="M3 8l3.5 3.5L13 5"
                    stroke="#4bbfcc"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              )}
            </button>
            <button
              onClick={() => setEditing({ id: todo.id, text: todo.text })}
              className={`flex-1 text-left text-sm font-medium ${
                todo.completed ? "line-through text-white/60" : "text-white"
              }`}
            >
              {todo.text}
            </button>
            <button
              onClick={() => deleteTodo(todo.id)}
              className="text-white/60 active:text-white flex-shrink-0"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
        ))}

        {plan.todos.length === 0 && (
          <p className="text-white/60 text-sm text-center py-2">Henüz görev yok</p>
        )}
      </div>

      {/* Add todo input */}
      <div className="mt-3 flex gap-2">
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
              <button
                onClick={() => setEditing(null)}
                className="flex-1 py-3 rounded-xl bg-gray-100 text-gray-600 font-semibold text-sm"
              >
                İptal
              </button>
              <button
                onClick={saveEdit}
                className="flex-1 py-3 rounded-xl bg-[#4bbfcc] text-white font-semibold text-sm"
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
