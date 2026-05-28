"use client";
import { useEffect } from "react";
import { loadSettings } from "@/lib/storage";
export default function ThemeProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const s = loadSettings();
    document.documentElement.classList.toggle("dark", s.theme === "dark");
  }, []);
  return <>{children}</>;
}
