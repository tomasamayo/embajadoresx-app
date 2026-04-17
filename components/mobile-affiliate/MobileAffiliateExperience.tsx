"use client";

import { useEffect, useState } from "react";

import { MobileAffiliateDrawer } from "@/components/mobile-affiliate/MobileAffiliateDrawer";
import { MobileAffiliateNav, MobileTab } from "@/components/mobile-affiliate/MobileAffiliateNav";
import {
  ArrowLeftIcon,
  BellIcon,
  CoinIcon,
  DownloadIcon,
  GridIcon,
  LinkIcon,
  ListIcon,
  MouseIcon,
  NetworkIcon,
  PencilIcon,
  RocketIcon,
  ShareIcon,
  ShieldIcon,
  SparklesIcon,
  TrophyIcon,
  WalletIcon
} from "@/components/mobile-affiliate/icons";

const quickCards = [
  { title: "Balance", value: "$200", accent: "from-[#153BFF]/30 to-transparent", icon: GridIcon },
  { title: "Acciones", value: "0/$0", accent: "from-[#FFB000]/25 to-transparent", icon: CoinIcon },
  { title: "Red", value: "0 afiliados", accent: "from-[#A855F7]/25 to-transparent", icon: NetworkIcon },
  { title: "Ventas", value: "0 cierres", accent: "from-[#0BFF95]/25 to-transparent", icon: TrophyIcon }
];

const rankingRows = [
  { rank: 4, name: "Danitza Consuelo", badge: "DC", score: 0 },
  { rank: 5, name: "Jose Daniel", badge: "JD", score: 0 },
  { rank: 6, name: "darwin delgado", badge: "DD", score: 0 },
  { rank: 7, name: "Pablo Isaí", badge: "PI", score: 0 }
];

const resourceCards = [
  {
    title: "Robot Millonario - Mines",
    price: "$10.99",
    profit: "0.00"
  },
  {
    title: "ZI - CRM Regular",
    price: "$300",
    profit: "$90.00"
  },
  {
    title: "ZI - CRM Extendida",
    price: "$1,800",
    profit: "$540.00"
  }
];

type SecondaryView = "links" | "profile" | "benefits";
type MobileView = MobileTab | SecondaryView;

function MobileFrame({
  children,
  activeTab,
  onSelect,
  onOpenMenu,
  showNav = true,
  showMenuButton = true
}: {
  children: React.ReactNode;
  activeTab: MobileTab;
  onSelect: (tab: MobileTab) => void;
  onOpenMenu: () => void;
  showNav?: boolean;
  showMenuButton?: boolean;
}) {
  return (
    <section className="relative h-[860px] w-full overflow-hidden rounded-[38px] border border-white/10 bg-[#050807] shadow-[0_30px_120px_rgba(0,0,0,0.55)]">
      <div className="mobile-fx-video absolute inset-0" />
      <div className="mobile-fx-grid absolute inset-0 opacity-50" />
      <div className="mobile-fx-scanlines absolute inset-0" />
      <div className="mobile-fx-orb absolute left-[-60px] top-[-30px] h-[280px] w-[280px] rounded-full bg-[radial-gradient(circle,_rgba(11,255,149,0.22),_transparent_68%)]" />
      <div className="mobile-fx-orb-slow absolute right-[-90px] top-28 h-[320px] w-[320px] rounded-full bg-[radial-gradient(circle,_rgba(11,255,149,0.16),_transparent_72%)]" />
      <div className="mobile-fx-orb absolute bottom-16 left-[-120px] h-[260px] w-[260px] rounded-full bg-[radial-gradient(circle,_rgba(88,255,215,0.08),_transparent_72%)]" />
      <div className="absolute inset-x-5 top-[340px] h-px bg-[linear-gradient(90deg,transparent,rgba(123,255,199,0.18),transparent)]" />
      <div className="absolute inset-x-8 top-[342px] h-px bg-[linear-gradient(90deg,transparent,rgba(123,255,199,0.06),transparent)] blur-sm" />
      <div className="mobile-fx-spark absolute left-[14%] top-[17%] h-1.5 w-1.5 rounded-full bg-[#7BFFC7] shadow-[0_0_14px_rgba(123,255,199,0.9)]" />
      <div className="mobile-fx-spark mobile-fx-spark-delay-1 absolute right-[19%] top-[12%] h-1.5 w-1.5 rounded-full bg-[#FFE072] shadow-[0_0_14px_rgba(255,224,114,0.8)]" />
      <div className="mobile-fx-spark mobile-fx-spark-delay-2 absolute left-[32%] top-[38%] h-1 w-1 rounded-full bg-[#0BFF95] shadow-[0_0_12px_rgba(11,255,149,0.8)]" />
      <div className="mobile-fx-spark mobile-fx-spark-delay-3 absolute right-[30%] top-[63%] h-1 w-1 rounded-full bg-[#8CF8FF] shadow-[0_0_12px_rgba(140,248,255,0.72)]" />

      <div className="relative h-full px-5 pb-28 pt-7">{children}</div>

      {showMenuButton ? (
        <button
          type="button"
          onClick={onOpenMenu}
          className="mobile-fx-rise absolute right-5 top-8 z-10 flex h-14 w-14 items-center justify-center rounded-[22px] border border-white/10 bg-white/[0.04] text-white/90 shadow-[0_8px_30px_rgba(0,0,0,0.2)] backdrop-blur-xl"
        >
          <svg viewBox="0 0 24 24" className="h-7 w-7" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M4 7h16" />
            <path d="M4 12h16" />
            <path d="M4 17h16" />
          </svg>
        </button>
      ) : null}

      {showNav ? <MobileAffiliateNav activeTab={activeTab} onSelect={onSelect} /> : null}
    </section>
  );
}

function HomeScreen({
  onOpenMenu,
  onSelect,
  onOpenSecondary
}: {
  onOpenMenu: () => void;
  onSelect: (tab: MobileTab) => void;
  onOpenSecondary: (view: SecondaryView) => void;
}) {
  return (
    <MobileFrame activeTab="inicio" onSelect={onSelect} onOpenMenu={onOpenMenu}>
      <div className="mobile-fx-no-scrollbar flex h-full flex-col overflow-y-auto overscroll-contain pb-28 pr-1">
        <header className="mobile-fx-rise flex items-start justify-between gap-4 pr-16">
          <div className="min-w-0 flex gap-4">
            <div className="mobile-fx-glow-ring flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-[radial-gradient(circle,rgba(11,255,149,0.08),rgba(0,0,0,0.55))] text-[1.85rem] font-bold text-[#0BFF95]">
              <div className="flex h-[52px] w-[52px] items-center justify-center rounded-full border border-[#0BFF95]/25 bg-[#07100d]">
                H
              </div>
            </div>
            <div className="min-w-0">
              <div className="mb-2 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.03] px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.28em] text-[#8CF8FF] backdrop-blur">
                <span className="h-2 w-2 rounded-full bg-[#0BFF95] shadow-[0_0_12px_rgba(11,255,149,0.75)]" />
                Nexus Online
              </div>
              <p className="max-w-[220px] text-[clamp(2.8rem,8vw,4.15rem)] font-semibold leading-[0.9] tracking-[-0.05em] text-white">
                Hola, haniel!
              </p>
              <button
                type="button"
                onClick={() => onOpenSecondary("profile")}
                className="mt-2 inline-flex items-center gap-2 text-sm font-medium text-white/70"
              >
                Ver Perfil
                <span className="flex h-6 w-6 items-center justify-center rounded-full border border-[#0BFF95]/20 bg-[#0BFF95]/10 text-[#0BFF95]">
                  ›
                </span>
              </button>
            </div>
          </div>
        </header>

        <div className="mobile-fx-rise mobile-fx-rise-delay-1 mt-8 rounded-[30px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.04),rgba(255,255,255,0.02))] p-3.5 shadow-[0_24px_70px_rgba(0,0,0,0.22)] backdrop-blur-sm">
          <div className="mobile-fx-panel mobile-fx-shimmer relative flex items-center justify-between gap-4 rounded-[26px] px-4 py-4">
            <div className="flex min-w-0 items-center gap-3">
              <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-[18px] bg-[#103221] text-[#0BFF95] shadow-[0_0_24px_rgba(11,255,149,0.08)]">
                <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M12 3 5 6v6c0 4 3 7 7 9 4-2 7-5 7-9V6l-7-3Z" />
                  <path d="m9 12 2 2 4-4" />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-[16px] font-semibold">Acción requerida</p>
                <p className="mt-1 text-[13px] leading-5 text-white/42">
                  Completa tu setup de cobros
                </p>
              </div>
            </div>
            <button
              type="button"
              className="shrink-0 rounded-[20px] bg-[linear-gradient(135deg,#0BFF95,#66FFC9)] px-5 py-3.5 text-[15px] font-semibold text-[#07100d] shadow-[0_14px_35px_rgba(11,255,149,0.24)] transition hover:scale-[1.02]"
            >
              Configurar
            </button>
          </div>
        </div>

        <div className="mobile-fx-rise mobile-fx-rise-delay-2 mt-6 grid grid-cols-2 gap-3">
          <article className="mobile-fx-card relative overflow-hidden rounded-[26px] border border-[#0BFF95]/14 bg-[linear-gradient(160deg,rgba(11,255,149,0.12),rgba(255,255,255,0.015))] p-4 shadow-[0_18px_40px_rgba(0,0,0,0.22)]">
            <div className="absolute right-[-18px] top-[-18px] h-20 w-20 rounded-full bg-[radial-gradient(circle,_rgba(123,255,199,0.25),_transparent_70%)]" />
            <div className="mb-5 flex h-10 w-10 items-center justify-center rounded-2xl bg-[linear-gradient(160deg,rgba(40,88,255,0.28),rgba(16,18,60,0.25))]">
              <GridIcon className="h-5 w-5 text-white/75" />
            </div>
            <p className="text-[15px] text-white/72">Balance</p>
            <p className="mt-3 text-[clamp(2.1rem,8vw,3.4rem)] font-semibold leading-[0.9] tracking-[-0.05em] text-white">
              $200
            </p>
          </article>
          <article className="mobile-fx-card relative overflow-hidden rounded-[26px] border border-white/12 bg-[linear-gradient(160deg,rgba(255,162,0,0.12),rgba(255,255,255,0.015))] p-4 shadow-[0_18px_40px_rgba(0,0,0,0.22)]">
            <div className="mb-5 flex h-10 w-10 items-center justify-center rounded-2xl bg-[linear-gradient(160deg,rgba(255,176,0,0.26),rgba(66,35,3,0.18))]">
              <SparklesIcon className="h-5 w-5 text-white/75" />
            </div>
            <p className="text-[15px] text-white/72">Acciones</p>
            <p className="mt-3 text-[clamp(2.1rem,8vw,3.4rem)] font-semibold leading-[0.9] tracking-[-0.05em] text-white">
              0/$0
            </p>
          </article>
          <article className="mobile-fx-card relative overflow-hidden rounded-[26px] border border-white/12 bg-[linear-gradient(160deg,rgba(168,85,247,0.12),rgba(255,255,255,0.015))] p-4 shadow-[0_18px_40px_rgba(0,0,0,0.22)]">
            <div className="mb-5 flex h-10 w-10 items-center justify-center rounded-2xl bg-[linear-gradient(160deg,rgba(168,85,247,0.22),rgba(35,12,58,0.18))]">
              <MouseIcon className="h-5 w-5 text-white/75" />
            </div>
            <p className="text-[15px] text-white/72">Clics</p>
            <p className="mt-3 text-[clamp(2.1rem,8vw,3.4rem)] font-semibold leading-[0.9] tracking-[-0.05em] text-white">
              0/$S0
            </p>
          </article>
          <article className="mobile-fx-card relative overflow-hidden rounded-[26px] border border-white/12 bg-[linear-gradient(160deg,rgba(77,199,92,0.12),rgba(255,255,255,0.015))] p-4 shadow-[0_18px_40px_rgba(0,0,0,0.22)]">
            <div className="mb-5 flex h-10 w-10 items-center justify-center rounded-2xl bg-[linear-gradient(160deg,rgba(77,199,92,0.22),rgba(10,46,24,0.18))]">
              <WalletIcon className="h-5 w-5 text-white/75" />
            </div>
            <p className="text-[15px] text-white/72">Total Transferido</p>
            <p className="mt-3 text-[clamp(2.1rem,8vw,3.4rem)] font-semibold leading-[0.9] tracking-[-0.05em] text-white">
              $200
            </p>
          </article>
        </div>

        <div className="mobile-fx-rise mobile-fx-rise-delay-3 mt-6 flex items-start justify-center gap-6">
          {[
            { label: "Mis Enlaces", icon: LinkIcon, action: () => onOpenSecondary("links") },
            { label: "Mi Plan", icon: ShieldIcon, action: () => onOpenSecondary("benefits") },
            { label: "Academia", icon: RocketIcon, action: () => undefined }
          ].map((item) => {
            const Icon = item.icon;

            return (
              <button
                key={item.label}
                type="button"
                onClick={item.action}
                className="group flex flex-col items-center"
              >
                <span className="flex h-16 w-16 items-center justify-center rounded-full border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.06),rgba(255,255,255,0.02))] shadow-[0_14px_28px_rgba(0,0,0,0.2)] backdrop-blur-xl transition group-hover:scale-[1.04]">
                  <Icon className="h-7 w-7 text-[#0BFF95]" />
                </span>
                <span className="mt-3 text-sm text-white/72">{item.label}</span>
              </button>
            );
          })}
        </div>

        <div className="mobile-fx-rise mobile-fx-rise-delay-4 mt-8 rounded-[28px] border border-white/8 bg-[linear-gradient(180deg,rgba(255,255,255,0.03),rgba(255,255,255,0.01))] px-6 py-5 backdrop-blur-sm">
          <div className="mb-4 flex items-center justify-between">
            <p className="text-[13px] font-semibold uppercase tracking-[0.24em] text-white/55">
              Rango: Nivel Inicial
            </p>
            <p className="text-[22px] font-semibold text-[#0BFF95]">$S200</p>
          </div>
          <div className="h-[2px] rounded-full bg-white/8">
            <div className="h-full w-[88%] rounded-full bg-[#0BFF95] shadow-[0_0_18px_rgba(11,255,149,0.6)]" />
          </div>
        </div>

        <div className="mobile-fx-rise mobile-fx-rise-delay-4 mt-8">
          <p className="text-[12px] font-semibold uppercase tracking-[0.26em] text-white/28">
            Actividad reciente
          </p>
          <div className="mt-6 text-center text-[20px] font-medium italic text-white/28">
            Aun no tienes actividades recientes
          </div>
        </div>

        <button
          type="button"
          className="mobile-fx-rise mobile-fx-rise-delay-4 absolute bottom-28 right-5 flex h-16 w-16 items-center justify-center rounded-full bg-[radial-gradient(circle_at_30%_30%,#66FFC9,#0BFF95_65%,#07c774)] text-[#07100d] shadow-[0_0_30px_rgba(11,255,149,0.55)] transition hover:scale-[1.04]"
        >
          <svg viewBox="0 0 24 24" className="h-7 w-7" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="7" y="7" width="10" height="10" rx="2" />
            <path d="M12 3v4" />
            <path d="M12 17v4" />
            <path d="M3 12h4" />
            <path d="M17 12h4" />
          </svg>
        </button>
      </div>
    </MobileFrame>
  );
}

function SecondaryHeader({
  title,
  onBack
}: {
  title: string;
  onBack: () => void;
}) {
  return (
    <header className="mobile-fx-rise flex items-center justify-between">
      <button
        type="button"
        onClick={onBack}
        className="flex h-11 w-11 items-center justify-center rounded-full border border-white/10 bg-white/[0.04] text-[#0BFF95]"
      >
        <ArrowLeftIcon className="h-6 w-6" />
      </button>
      <h1 className="text-[22px] font-bold tracking-[0.04em] text-[#0BFF95]">{title}</h1>
      <div className="h-11 w-11" />
    </header>
  );
}

function LinksScreen({
  onBack,
  onOpenMenu
}: {
  onBack: () => void;
  onOpenMenu: () => void;
}) {
  return (
    <MobileFrame activeTab="inicio" onSelect={() => undefined} onOpenMenu={onOpenMenu} showNav={true}>
      <div className="flex h-full flex-col pb-6">
        <SecondaryHeader title="Banners y Enlaces" onBack={onBack} />
        <p className="mt-2 text-[11px] font-semibold uppercase tracking-[0.28em] text-[#0BFF95]/55">
          Tus favoritos y productos creados
        </p>

        <div className="mobile-fx-rise mobile-fx-rise-delay-1 mt-6 flex items-center justify-between rounded-[26px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.04),rgba(255,255,255,0.02))] px-5 py-5 backdrop-blur-sm">
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#0BFF95]/55">
              Total recursos
            </p>
            <p className="mt-3 text-[34px] font-semibold">3 Enlaces</p>
          </div>
          <div className="flex gap-3">
            <button type="button" className="flex h-14 w-14 items-center justify-center rounded-[20px] border border-white/10 bg-white/[0.04] text-[#0BFF95]">
              <ShareIcon className="h-6 w-6" />
            </button>
            <button type="button" className="flex h-14 w-14 items-center justify-center rounded-[20px] bg-[#0BFF95] text-[#07100d]">
              <ListIcon className="h-6 w-6" />
            </button>
          </div>
        </div>

        <div className="mobile-fx-no-scrollbar mt-5 flex-1 space-y-4 overflow-y-auto overscroll-contain pb-24">
          {resourceCards.map((card, index) => (
            <article
              key={card.title}
              className={`mobile-fx-card mobile-fx-rise rounded-[28px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.05),rgba(255,255,255,0.015))] p-4 shadow-[0_24px_50px_rgba(0,0,0,0.22)] mobile-fx-rise-delay-${Math.min(index + 1, 4)}`}
            >
              <div className="h-28 rounded-[20px] bg-[linear-gradient(135deg,rgba(123,255,199,0.18),rgba(255,255,255,0.04))]" />
              <p className="mt-4 text-[18px] font-semibold">{card.title}</p>
              <div className="mt-4 flex justify-between text-sm text-white/58">
                <p>Precio</p>
                <p>Ganancia</p>
              </div>
              <div className="mt-1 flex justify-between text-[22px] font-semibold">
                <p>{card.price}</p>
                <p className="text-[#0BFF95]">{card.profit}</p>
              </div>
              <div className="mt-4 flex gap-3">
                <button type="button" className="flex h-11 w-11 items-center justify-center rounded-2xl border border-white/10 bg-white/[0.04] text-white/72">
                  <ShareIcon className="h-5 w-5" />
                </button>
                <button type="button" className="flex flex-1 items-center justify-center rounded-2xl bg-[#0BFF95] py-3 text-sm font-semibold text-[#07100d]">
                  COPIAR
                </button>
              </div>
            </article>
          ))}
        </div>
      </div>
    </MobileFrame>
  );
}

function ProfileScreen({
  onBack,
  onOpenMenu
}: {
  onBack: () => void;
  onOpenMenu: () => void;
}) {
  return (
    <MobileFrame activeTab="inicio" onSelect={() => undefined} onOpenMenu={onOpenMenu} showNav={false} showMenuButton={false}>
      <div className="flex h-full flex-col">
        <SecondaryHeader title="Configuracion de Perfil" onBack={onBack} />
        <button
          type="button"
          className="absolute right-5 top-24 flex h-12 w-12 items-center justify-center rounded-2xl border border-white/10 bg-white/[0.04] text-[#0BFF95]"
        >
          <PencilIcon className="h-5 w-5" />
        </button>

        <div className="mt-12 flex flex-col items-center">
          <div className="mobile-fx-glow-ring flex h-28 w-28 items-center justify-center rounded-full bg-[radial-gradient(circle,rgba(11,255,149,0.1),rgba(0,0,0,0.35))]">
            <div className="flex h-[98px] w-[98px] items-center justify-center rounded-full bg-[#111716] text-[32px] font-black text-[#0BFF95]">
              H
            </div>
          </div>
          <p className="mt-5 text-[30px] font-semibold">haniel mera</p>
          <p className="text-[18px] text-white/58">prueba@yahoo.com</p>
        </div>

        <div className="mt-8 space-y-4">
          {[
            ["Nombre Completo", "haniel mera", GridIcon],
            ["Correo Electronico", "prueba@yahoo.com", WalletIcon],
            ["Telefono", "+51 987 635 213", BellIcon]
          ].map(([label, value, Icon]) => {
            const IconComponent = Icon as typeof GridIcon;
            return (
              <div key={label} className="rounded-[26px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.05),rgba(255,255,255,0.015))] p-5">
                <div className="flex items-center gap-4">
                  <span className="flex h-12 w-12 items-center justify-center rounded-[18px] bg-white/[0.04]">
                    <IconComponent className="h-5 w-5 text-white/72" />
                  </span>
                  <div>
                    <p className="text-[11px] font-semibold uppercase tracking-[0.24em] text-white/32">{label}</p>
                    <p className="mt-2 text-[22px] font-semibold">{value}</p>
                  </div>
                </div>
              </div>
            );
          })}

          <div className="rounded-[26px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.05),rgba(255,255,255,0.015))] p-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <span className="flex h-12 w-12 items-center justify-center rounded-[18px] bg-[#103221] text-[#0BFF95]">
                  <ShieldIcon className="h-5 w-5" />
                </span>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.24em] text-white/32">Estado del plan</p>
                  <p className="mt-2 text-[22px] font-semibold">Plan Ultra</p>
                </div>
              </div>
              <span className="rounded-full border border-[#0BFF95]/20 bg-[#0BFF95]/10 px-4 py-2 text-xs font-semibold uppercase tracking-[0.18em] text-[#0BFF95]">
                Activo
              </span>
            </div>
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}

function BenefitsScreen({
  onBack,
  onOpenMenu
}: {
  onBack: () => void;
  onOpenMenu: () => void;
}) {
  return (
    <MobileFrame activeTab="inicio" onSelect={() => undefined} onOpenMenu={onOpenMenu} showNav={false} showMenuButton={false}>
      <div className="flex h-full flex-col">
        <SecondaryHeader title="BENEFICIOS EX" onBack={onBack} />

        <div className="mt-6 rounded-[28px] border border-[#0BFF95]/12 bg-[linear-gradient(180deg,rgba(11,255,149,0.1),rgba(255,255,255,0.02))] p-5">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[18px] font-semibold text-[#7BFFC7]">Estatus real: PLATA</p>
              <div className="mt-4 h-3 w-56 rounded-full bg-black/50">
                <div className="h-full w-8 rounded-full bg-[#0BFF95] shadow-[0_0_18px_rgba(11,255,149,0.7)]" />
              </div>
            </div>
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-white text-[28px] font-black text-[#111]">
              P
            </div>
          </div>
        </div>

        <p className="mt-8 text-[12px] font-semibold uppercase tracking-[0.26em] text-[#0BFF95]">
          Explorar rangos
        </p>

        <div className="mt-4 rounded-[28px] border border-[#0BFF95]/18 bg-[linear-gradient(135deg,rgba(11,255,149,0.14),rgba(255,255,255,0.02))] p-4">
          <div className="h-52 rounded-[22px] border border-[#0BFF95]/25 bg-[radial-gradient(circle_at_top,rgba(255,255,255,0.08),transparent_55%),linear-gradient(160deg,#273324,#101512)] p-5">
            <div className="flex justify-end text-[#0BFF95]">
              <ShieldIcon className="h-5 w-5" />
            </div>
            <p className="mt-20 text-[34px] font-semibold">PLATA</p>
            <button type="button" className="mt-3 rounded-full border border-[#0BFF95]/25 bg-[#0BFF95]/10 px-4 py-2 text-xs font-semibold uppercase tracking-[0.18em] text-[#0BFF95]">
              Explorar
            </button>
          </div>
          <div className="mt-4 flex gap-2">
            <div className="h-2 w-10 rounded-full bg-[#0BFF95]" />
            {Array.from({ length: 11 }).map((_, index) => (
              <div key={index} className="h-2 w-2 rounded-full bg-[#0BFF95]/45" />
            ))}
          </div>
        </div>

        <div className="mt-6 rounded-[28px] border border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.05),rgba(255,255,255,0.015))] p-5">
          <p className="text-[28px] font-semibold">Misiones para subir a PLATA</p>
          <div className="mt-5 space-y-4">
            {[
              "Ventas personales: $200 / $1000",
              "Patrocinios directos: 0 / 1",
              "Socios en red: 0 / 3",
              "Volumen de equipo: $0 / $3000"
            ].map((item) => (
              <div key={item} className="flex items-center gap-3 text-[18px] text-white/78">
                <span className="h-6 w-6 rounded-full border border-[#0BFF95]" />
                <span>{item}</span>
              </div>
            ))}
          </div>
          <p className="mt-6 text-[12px] font-semibold uppercase tracking-[0.24em] text-[#0BFF95]">
            Progreso hacia este rango
          </p>
          <div className="mt-4 h-4 rounded-full bg-black/50">
            <div className="h-full w-[6%] rounded-full bg-[#0BFF95]" />
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}

function EventsScreen({
  onOpenMenu,
  onSelect
}: {
  onOpenMenu: () => void;
  onSelect: (tab: MobileTab) => void;
}) {
  return (
    <MobileFrame activeTab="eventos" onSelect={onSelect} onOpenMenu={onOpenMenu}>
      <div className="flex h-full flex-col items-center text-center">
        <header className="w-full pt-2">
          <h1 className="text-[24px] font-semibold tracking-tight text-[#0BFF95]">
            Eventos Especiales
          </h1>
        </header>

        <section className="mt-8 w-full rounded-[30px] border border-[#0BFF95]/10 bg-[linear-gradient(180deg,rgba(11,255,149,0.11),rgba(255,255,255,0.02))] px-6 py-8">
          <div className="mx-auto flex h-36 w-36 items-center justify-center rounded-full border border-[#0BFF95]/35 bg-[radial-gradient(circle,rgba(11,255,149,0.12),transparent_65%)] shadow-[0_0_35px_rgba(11,255,149,0.28)]">
            <svg viewBox="0 0 24 24" className="h-14 w-14 text-[#0BFF95]" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="m7 4 2.5 4L7 12h10l-2.5-4L17 4H7Z" />
              <path d="m9.5 8 2.5 10 2.5-10" />
            </svg>
          </div>
          <h2 className="mt-8 text-[26px] font-semibold text-[#FFCE21]">Nivel Inicial</h2>
          <div className="mx-auto mt-7 h-3 w-full rounded-full bg-white/8">
            <div className="h-full w-[4%] rounded-full bg-[#5F516B]" />
          </div>
          <p className="mt-4 text-[15px] text-white/55">0% de progreso al siguiente nivel</p>
        </section>

        <div className="mt-10 w-full text-left">
          <p className="text-[20px] font-black uppercase tracking-[0.08em] text-[#0BFF95]">
            Centro de Desafíos
          </p>
          <h3 className="mt-5 text-[22px] font-semibold">Eventos Flash</h3>
          <p className="mt-1 text-[16px] text-white/58">
            Participa y gana recompensas exclusivas
          </p>
        </div>

        <div className="mt-auto pb-20">
          <div className="mx-auto flex h-20 w-20 items-center justify-center text-[#0BFF95]">
            <svg viewBox="0 0 24 24" className="h-16 w-16" fill="currentColor">
              <path d="M13 2 6 14h5l-1 8 8-13h-5l0-7Z" />
            </svg>
          </div>
          <p className="mt-5 text-[22px] font-semibold">¡Estén atentos!</p>
          <p className="mt-2 text-[15px] text-white/45">Pronto nuevos Eventos Flash</p>
        </div>
      </div>
    </MobileFrame>
  );
}

function RankingScreen({
  onOpenMenu,
  onSelect
}: {
  onOpenMenu: () => void;
  onSelect: (tab: MobileTab) => void;
}) {
  return (
    <MobileFrame activeTab="ranking" onSelect={onSelect} onOpenMenu={onOpenMenu}>
      <div className="flex h-full flex-col pb-6">
        <header className="pt-2 text-center">
          <h1 className="text-[22px] font-bold tracking-[0.08em]">RANKING GLOBAL</h1>
        </header>

        <div className="mt-5 flex items-center justify-between rounded-[20px] border border-[#0BFF95]/10 bg-[#101615] px-4 py-3 text-[#0BFF95]">
          <p className="text-[15px] font-semibold">29 usuarios</p>
          <p className="text-[15px] font-semibold">S/ 200</p>
        </div>

        <div className="mt-5 grid grid-cols-3 gap-3">
          {[
            { name: "moises romero", badge: "M2", points: "8.7", level: "Nivel: 2", order: "2", accent: false },
            { name: "haniel mera", badge: "H1", points: "200", level: "Nivel: 1", order: "1", accent: true },
            { name: "Daniel Ortiz", badge: "DO", points: "8.7", level: "Nivel: 3", order: "3", accent: false }
          ].map((card) => (
            <article
              key={card.order}
              className={[
                "rounded-[24px] border bg-white/[0.03] px-3 pb-4 pt-5 text-center",
                card.accent ? "border-[#FFCE21] shadow-[0_0_0_1px_rgba(255,206,33,0.25)]" : "border-white/10"
              ].join(" ")}
            >
              <div className="relative mx-auto flex h-16 w-16 items-center justify-center rounded-full border border-[#0BFF95]/35 bg-[#131817] text-xl font-bold text-white">
                {card.badge}
                <span className="absolute -right-2 -top-2 text-[30px] font-black text-[#FFCE21]">
                  {card.order}
                </span>
              </div>
              <p className="mt-3 text-[15px] font-semibold leading-tight">{card.name}</p>
              <p className="mt-2 text-[28px] font-semibold text-[#0BFF95]">{card.points}</p>
              <p className="text-xs text-white/45">{card.level}</p>
            </article>
          ))}
        </div>

        <div className="mt-5 flex-1 space-y-3 overflow-hidden">
          {rankingRows.map((row) => (
            <div
              key={row.rank}
              className="flex items-center gap-3 border-b border-white/6 pb-3"
            >
              <span className="w-5 text-sm text-white/55">{row.rank}</span>
              <div className="flex h-11 w-11 items-center justify-center rounded-full border border-[#0BFF95]/25 bg-white/5 text-sm font-semibold text-white/85">
                {row.badge}
              </div>
              <div className="min-w-0 flex-1">
                <p className="truncate text-[15px] font-semibold">{row.name}</p>
                <p className="text-xs text-white/38">Rango: {row.rank}</p>
              </div>
              <span className="text-[22px] font-semibold text-[#0BFF95]">{row.score}</span>
            </div>
          ))}
        </div>

        <div className="mt-4 rounded-[24px] border border-[#0BFF95]/14 bg-[#1C1825] px-5 py-4 shadow-[0_0_0_1px_rgba(11,255,149,0.08)]">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-[18px] font-semibold">Tu ranking</p>
              <p className="mt-1 text-sm text-white/48">
                ¡Felicidades! Eres el líder del ranking.
              </p>
            </div>
            <p className="text-[28px] font-black text-[#0BFF95]">#1 de 29</p>
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}

function MyNetworkScreen({
  onOpenMenu,
  onSelect
}: {
  onOpenMenu: () => void;
  onSelect: (tab: MobileTab) => void;
}) {
  return (
    <MobileFrame activeTab="mi-red" onSelect={onSelect} onOpenMenu={onOpenMenu}>
      <div className="flex h-full flex-col pb-6">
        <header className="pt-2 pr-16">
          <div className="flex items-center gap-2 text-[#0BFF95]">
            <NetworkIcon className="h-6 w-6" />
          </div>
          <h1 className="mt-4 text-[34px] font-bold leading-none tracking-tight">MI RED</h1>
          <p className="mt-2 text-[18px] font-medium text-white/75">Comunidad: [2] EX</p>
        </header>

        <div className="mt-8 grid grid-cols-3 gap-3 text-center">
          <div>
            <p className="text-[11px] uppercase tracking-[0.18em] text-white/35">Ganancias mes</p>
            <p className="mt-2 text-[22px] font-semibold">$0.00</p>
          </div>
          <div className="flex items-start justify-center">
            <span className="rounded-full border border-[#0BFF95]/35 px-4 py-2 text-xs font-semibold uppercase tracking-[0.16em] text-[#0BFF95]">
              Nivel inicial
            </span>
          </div>
          <div>
            <p className="text-[11px] uppercase tracking-[0.18em] text-white/35">Afiliados mes</p>
            <p className="mt-2 text-[22px] font-semibold text-[#0BFF95]">0</p>
          </div>
        </div>

        <div className="relative mt-10 flex-1">
          <div className="absolute left-1/2 top-[118px] h-[210px] w-px -translate-x-1/2 bg-[linear-gradient(to_bottom,rgba(11,255,149,0.45),rgba(11,255,149,0.05))]" />

          <div className="flex flex-col items-center">
            <div className="flex h-20 w-20 items-center justify-center rounded-full border border-[#0BFF95]/45 bg-[radial-gradient(circle,rgba(11,255,149,0.12),rgba(0,0,0,0.2))] shadow-[0_0_22px_rgba(11,255,149,0.35)]">
              <span className="text-[30px] font-black text-[#0BFF95]">EX</span>
            </div>
            <p className="mt-4 text-[24px] font-semibold">Embajadores X</p>
            <p className="text-[18px] text-[#C6952B]">Bronce</p>
            <p className="mt-2 text-[28px] font-semibold">$0.00</p>
            <p className="text-[#0BFF95]">$ +0</p>
          </div>

          <div className="mt-24 flex flex-col items-center">
            <div className="flex h-20 w-20 items-center justify-center rounded-full border border-[#0BFF95]/45 bg-[radial-gradient(circle,rgba(11,255,149,0.12),rgba(0,0,0,0.2))] shadow-[0_0_22px_rgba(11,255,149,0.35)]">
              <span className="text-[30px] font-black text-white/90">H</span>
            </div>
            <p className="mt-4 text-[24px] font-semibold">haniel</p>
            <p className="text-[18px] text-[#C6952B]">Bronce</p>
            <p className="mt-2 text-[28px] font-semibold">$0.00</p>
            <p className="text-[#0BFF95]">$ +0</p>
          </div>

          <button
            type="button"
            className="absolute bottom-3 right-2 flex h-16 w-16 items-center justify-center rounded-full bg-[#0BFF95] text-[#07100d] shadow-[0_0_30px_rgba(11,255,149,0.55)]"
          >
            <svg viewBox="0 0 24 24" className="h-7 w-7" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="4" />
              <path d="M12 2v2" />
              <path d="M12 20v2" />
              <path d="M2 12h2" />
              <path d="M20 12h2" />
            </svg>
          </button>
        </div>

        <div className="grid grid-cols-4 gap-3 rounded-[24px] border border-white/8 bg-[#121119] px-4 py-4 text-center">
          {[
            ["0", "Afiliados"],
            ["$0", "Volumen"],
            ["0", "Clics"],
            ["0", "Ventas"]
          ].map(([value, label]) => (
            <div key={label}>
              <p className="text-[24px] font-semibold">{value}</p>
              <p className="mt-1 text-[10px] uppercase tracking-[0.18em] text-white/35">
                {label}
              </p>
            </div>
          ))}
        </div>
      </div>
    </MobileFrame>
  );
}

export function MobileAffiliateExperience() {
  const [activeView, setActiveView] = useState<MobileView>("inicio");
  const [drawerOpen, setDrawerOpen] = useState(false);

  useEffect(() => {
    document.documentElement.classList.add("mobile-app-shell");
    document.body.classList.add("mobile-app-shell");

    return () => {
      document.documentElement.classList.remove("mobile-app-shell");
      document.body.classList.remove("mobile-app-shell");
    };
  }, []);

  const handleSelect = (tab: MobileTab) => {
    if (tab === "red") {
      setDrawerOpen(true);
      return;
    }

    setActiveView(tab);
  };

  const handleOpenMenu = () => {
    setDrawerOpen(true);
  };

  const handleOpenSecondary = (view: SecondaryView) => {
    setDrawerOpen(false);
    setActiveView(view);
  };

  const handleBackToHome = () => {
    setActiveView("inicio");
  };

  const commonProps = {
    onOpenMenu: handleOpenMenu,
    onSelect: handleSelect
  };

  return (
    <main className="h-[100dvh] overflow-hidden bg-[#050807] px-4 py-6 text-white overscroll-none">
      <div className="mx-auto flex h-full max-w-[430px] items-center justify-center overflow-hidden">
        <div className="relative h-full w-full overflow-hidden">
          {activeView === "inicio" ? (
            <HomeScreen
              onOpenMenu={handleOpenMenu}
              onOpenSecondary={handleOpenSecondary}
              onSelect={handleSelect}
            />
          ) : null}
          {activeView === "eventos" ? <EventsScreen {...commonProps} /> : null}
          {activeView === "ranking" ? <RankingScreen {...commonProps} /> : null}
          {activeView === "mi-red" ? <MyNetworkScreen {...commonProps} /> : null}
          {activeView === "links" ? (
            <LinksScreen onBack={handleBackToHome} onOpenMenu={handleOpenMenu} />
          ) : null}
          {activeView === "profile" ? (
            <ProfileScreen onBack={handleBackToHome} onOpenMenu={handleOpenMenu} />
          ) : null}
          {activeView === "benefits" ? (
            <BenefitsScreen onBack={handleBackToHome} onOpenMenu={handleOpenMenu} />
          ) : null}

          <MobileAffiliateDrawer
            open={drawerOpen}
            onClose={() => setDrawerOpen(false)}
            onNavigate={handleOpenSecondary}
          />
        </div>
      </div>
    </main>
  );
}
