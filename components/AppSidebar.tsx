"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

import { SidebarItem } from "@/lib/types";

type AppSidebarProps = {
  items: SidebarItem[];
};

export function AppSidebar({ items }: AppSidebarProps) {
  const pathname = usePathname();

  return (
    <>
      <aside className="hidden w-full max-w-[280px] shrink-0 rounded-4xl border border-line bg-white p-6 shadow-soft lg:block">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary-600 text-lg font-bold text-white">
            EX
          </div>
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted">
              EmbajadoresX
            </p>
            <p className="text-lg font-semibold text-ink">Affiliate SaaS</p>
          </div>
        </div>

        <nav className="mt-8 space-y-2">
          {items.map((item) => (
            <Link
              key={item.label}
              href={item.href}
              className={[
                "flex items-center justify-between rounded-2xl px-4 py-3 text-sm font-medium transition",
                pathname === item.href || (item.href === "/dashboard" && pathname === "/")
                  ? "bg-primary-50 text-primary-700"
                  : "text-muted hover:bg-slate-50 hover:text-ink"
              ].join(" ")}
            >
              <span>{item.label}</span>
              {item.count !== undefined && item.count > 0 ? (
                <span className="rounded-full bg-white px-2.5 py-1 text-xs text-muted ring-1 ring-inset ring-line">
                  {item.count}
                </span>
              ) : null}
            </Link>
          ))}
        </nav>

        <div className="mt-8 rounded-3xl bg-[#101828] p-5 text-white">
          <p className="text-sm font-semibold">Programa activo</p>
          <p className="mt-2 text-sm leading-6 text-slate-300">
            Mantén sincronizadas campañas, payouts y fuentes de tráfico desde
            un solo panel.
          </p>
        </div>
      </aside>

      <div className="overflow-x-auto lg:hidden">
        <div className="flex min-w-max gap-2 rounded-3xl border border-line bg-white p-2 shadow-soft">
          {items.map((item) => (
            <Link
              key={item.label}
              href={item.href}
              className={[
                "rounded-2xl px-4 py-2 text-sm font-medium transition",
                pathname === item.href || (item.href === "/dashboard" && pathname === "/")
                  ? "bg-primary-600 text-white"
                  : "bg-slate-50 text-muted"
              ].join(" ")}
            >
              {item.label}
            </Link>
          ))}
        </div>
      </div>
    </>
  );
}
