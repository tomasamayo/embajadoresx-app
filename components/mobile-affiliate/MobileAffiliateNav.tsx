"use client";

import {
  FlameIcon,
  GridIcon,
  LinkIcon,
  NetworkIcon,
  TrophyIcon
} from "@/components/mobile-affiliate/icons";

export type MobileTab = "inicio" | "eventos" | "red" | "ranking" | "mi-red";

type MobileAffiliateNavProps = {
  activeTab: MobileTab;
  onSelect: (tab: MobileTab) => void;
};

const navItems: Array<{ label: string; icon: MobileTab; tab: MobileTab }> = [
  { label: "Inicio", icon: "inicio", tab: "inicio" },
  { label: "Eventos", icon: "eventos", tab: "eventos" },
  { label: "Red", icon: "red", tab: "red" },
  { label: "Ranking", icon: "ranking", tab: "ranking" },
  { label: "Mi Red", icon: "mi-red", tab: "mi-red" }
];

function NavIcon({ icon }: { icon: MobileTab }) {
  switch (icon) {
    case "inicio":
      return <GridIcon className="h-5 w-5" />;
    case "eventos":
      return <FlameIcon className="h-5 w-5" />;
    case "red":
      return <LinkIcon className="h-5 w-5" />;
    case "ranking":
      return <TrophyIcon className="h-5 w-5" />;
    default:
      return <NetworkIcon className="h-5 w-5" />;
  }
}

export function MobileAffiliateNav({
  activeTab,
  onSelect
}: MobileAffiliateNavProps) {
  return (
    <nav className="absolute inset-x-4 bottom-4 rounded-[28px] border border-white/10 bg-[#151520]/95 px-3 py-3 shadow-[0_16px_60px_rgba(0,0,0,0.45)] backdrop-blur-xl">
      <div className="grid grid-cols-5 items-end">
        {navItems.map((item) => {
          const active = activeTab === item.tab;

          return (
            <button
              key={item.label}
              type="button"
              onClick={() => onSelect(item.tab)}
              className="flex flex-col items-center gap-1 text-[11px] font-medium text-white/50"
            >
              <span
                className={[
                  "flex h-11 w-11 items-center justify-center rounded-full transition",
                  active
                    ? "bg-[#0BFF95]/16 text-[#0BFF95] shadow-[0_0_24px_rgba(11,255,149,0.45)]"
                    : "text-white/55"
                ].join(" ")}
              >
                <NavIcon icon={item.icon} />
              </span>
              <span className={active ? "text-[#0BFF95]" : ""}>{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
