"use client";

import type { ComponentType } from "react";

import {
  ArrowLeftIcon,
  BellIcon,
  CoinIcon,
  ListIcon,
  LogoutIcon,
  ShieldIcon,
  SparklesIcon,
  TrophyIcon,
  WalletIcon
} from "@/components/mobile-affiliate/icons";

type MobileAffiliateDrawerProps = {
  open: boolean;
  onClose: () => void;
  onNavigate: (destination: "links" | "benefits" | "profile") => void;
};

const primaryMenu = [
  { label: "Tienda", icon: WalletIcon, destination: "links" as const },
  { label: "Beneficios", icon: TrophyIcon, destination: "benefits" as const },
  { label: "Notificaciones", icon: BellIcon },
  { label: "Solicitar Check Azul", icon: ShieldIcon, accent: true },
  { label: "Configurar Perfil", icon: SparklesIcon, destination: "profile" as const }
];

const reportsMenu = [
  { label: "Mis Reportes", icon: CoinIcon, active: true },
  { label: "Lista de Registros", icon: ListIcon },
  { label: "Mis Pedidos", icon: WalletIcon }
];

const financeMenu = [
  { label: "Comprar ExCoin", icon: CoinIcon },
  { label: "Detalles de Pago", icon: WalletIcon },
  { label: "Pagos", icon: CoinIcon }
];

function MenuGroup({
  title,
  items
}: {
  title: string;
  items: Array<{ label: string; icon: ComponentType<{ className?: string }>; active?: boolean; accent?: boolean }>;
}) {
  return (
    <div className="mt-8">
      <p className="px-3 text-[11px] font-semibold uppercase tracking-[0.32em] text-white/28">
        {title}
      </p>
      <div className="mt-3 space-y-2">
        {items.map((item) => {
          const Icon = item.icon;

          return (
            <button
              key={item.label}
              type="button"
              className={[
                "flex w-full items-center gap-4 rounded-[20px] px-4 py-3.5 text-left text-[16px] font-medium transition",
                item.active
                  ? "border border-[#0BFF95]/8 bg-[linear-gradient(90deg,#103321,#133724)] text-[#0BFF95] shadow-[0_12px_36px_rgba(11,255,149,0.08)]"
                  : item.accent
                    ? "text-[#0BFF95]"
                    : "text-white/78 hover:bg-white/[0.04]"
              ].join(" ")}
            >
              <span
                className={[
                  "flex h-10 w-10 items-center justify-center rounded-[14px]",
                  item.active ? "bg-[#0BFF95]/10" : "bg-white/[0.03]"
                ].join(" ")}
              >
                <Icon className="h-5 w-5" />
              </span>
              <span className="flex-1">{item.label}</span>
              {item.active ? (
                <span className="h-2.5 w-2.5 rounded-full bg-[#0BFF95]" />
              ) : null}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export function MobileAffiliateDrawer({
  open,
  onClose,
  onNavigate
}: MobileAffiliateDrawerProps) {
  return (
    <>
      <div
        className={[
          "absolute inset-0 bg-black/50 transition",
          open ? "pointer-events-auto opacity-100" : "pointer-events-none opacity-0"
        ].join(" ")}
        onClick={onClose}
      />

      <aside
        className={[
          "absolute inset-y-0 left-0 z-20 flex w-[83%] max-w-[320px] flex-col rounded-r-[38px] border-r border-white/10 bg-[linear-gradient(180deg,#101412,#0d100f)] px-5 pb-7 pt-5 shadow-[30px_0_80px_rgba(0,0,0,0.55)] transition duration-300",
          open ? "translate-x-0" : "-translate-x-full"
        ].join(" ")}
      >
        <div className="absolute inset-0 mobile-fx-video opacity-45" />
        <div className="absolute inset-0 mobile-fx-grid opacity-25" />
        <div className="absolute inset-x-0 top-0 h-36 bg-[radial-gradient(circle_at_top_left,_rgba(11,255,149,0.16),_transparent_72%)]" />

        <div className="relative flex items-start justify-between">
          <div className="flex gap-3">
            <div className="mobile-fx-glow-ring h-14 w-14 rounded-[20px] bg-[linear-gradient(135deg,#0d2b22,#0BFF95)] p-[2px] shadow-[0_0_26px_rgba(11,255,149,0.12)]">
              <div className="flex h-full w-full items-center justify-center rounded-[18px] bg-[#0a0f0e] text-sm font-bold text-[#0BFF95]">
                H
              </div>
            </div>
            <div>
              <p className="pt-1 text-[15px] font-semibold text-white">haniel mera</p>
              <p className="mt-1 text-[11px] font-medium uppercase tracking-[0.28em] text-white/38">
                Modo afiliado
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="flex h-12 w-12 items-center justify-center rounded-full border border-white/10 bg-white/[0.03] text-white/45 transition hover:bg-white/5 hover:text-white"
          >
            <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M6 6 18 18" />
              <path d="M18 6 6 18" />
            </svg>
          </button>
        </div>

        <div className="mobile-fx-no-scrollbar relative min-h-0 flex-1 overflow-y-auto overscroll-contain pr-1 pt-2">
          <div className="mt-6 space-y-2 pb-6">
            {primaryMenu.map((item) => {
              const Icon = item.icon;

            return (
              <button
                key={item.label}
                type="button"
                onClick={() => {
                  if (item.destination) {
                    onNavigate(item.destination);
                  }
                }}
                className={[
                  "flex w-full items-center gap-4 rounded-[20px] px-4 py-3.5 text-left text-[16px] font-medium transition",
                  item.accent ? "text-[#0BFF95]" : "text-white/78 hover:bg-white/5"
                  ].join(" ")}
                >
                  <span className="flex h-10 w-10 items-center justify-center rounded-[14px] bg-white/[0.03]">
                    <Icon className="h-5 w-5" />
                  </span>
                  <span>{item.label}</span>
                </button>
              );
            })}

            <MenuGroup title="Gestión" items={reportsMenu} />
            <MenuGroup title="Finanzas" items={financeMenu} />
          </div>
        </div>

        <div className="pt-4">
          <button
            type="button"
            onClick={onClose}
            className="mb-3 flex w-full items-center gap-4 rounded-[20px] px-4 py-3.5 text-[15px] font-semibold text-white/60 transition hover:bg-white/[0.05]"
          >
            <span className="flex h-10 w-10 items-center justify-center rounded-[14px] bg-white/[0.04]">
              <ArrowLeftIcon className="h-5 w-5" />
            </span>
            <span>Volver al panel</span>
          </button>

          <button
            type="button"
            className="flex w-full items-center gap-4 rounded-[20px] px-4 py-3.5 text-[18px] font-semibold text-[#FF5C5C] transition hover:bg-[#ff5c5c]/[0.06]"
          >
            <span className="flex h-10 w-10 items-center justify-center rounded-[14px] bg-[#ff5c5c]/[0.08]">
              <LogoutIcon className="h-5 w-5" />
            </span>
            <span>Cerrar Sesión</span>
          </button>

          <p className="mt-4 text-center text-xs tracking-[0.16em] text-white/24">
            Versión 1.3.0
          </p>
        </div>
      </aside>
    </>
  );
}
