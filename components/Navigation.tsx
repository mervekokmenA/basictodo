"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Navigation() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50 shadow-lg">
      <div className="flex">
        <Link
          href="/"
          className={`flex-1 flex flex-col items-center py-3 text-xs font-semibold transition-colors ${
            pathname === "/" ? "text-[#4a7fa5]" : "text-gray-400"
          }`}
        >
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="4" width="18" height="18" rx="2" />
            <line x1="16" y1="2" x2="16" y2="6" />
            <line x1="8" y1="2" x2="8" y2="6" />
            <line x1="3" y1="10" x2="21" y2="10" />
          </svg>
          <span className="mt-1">Günlük Plan</span>
        </Link>
        <Link
          href="/calisma-hobiler"
          className={`flex-1 flex flex-col items-center py-3 text-xs font-semibold transition-colors ${
            pathname === "/calisma-hobiler" ? "text-[#4a7fa5]" : "text-gray-400"
          }`}
        >
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M12 2L2 7l10 5 10-5-10-5z" />
            <path d="M2 17l10 5 10-5" />
            <path d="M2 12l10 5 10-5" />
          </svg>
          <span className="mt-1">Çalışmalar</span>
        </Link>
      </div>
    </nav>
  );
}
