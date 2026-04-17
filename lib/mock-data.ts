import { DashboardData } from "@/lib/types";

export const sidebarItems: DashboardData["sidebarItems"] = [
  { label: "Dashboard", href: "/dashboard", active: true },
  { label: "Embajadores", href: "#", count: 128 },
  { label: "Campañas", href: "#", count: 12 },
  { label: "Comisiones", href: "#", count: 24 },
  { label: "Pagos", href: "#", count: 8 },
  { label: "Configuración", href: "#" }
];

export const topbarUser: DashboardData["topbarUser"] = {
  name: "Tomas Amayo",
  role: "Admin del programa",
  initials: "TA"
};

export const earningsSummary: DashboardData["earningsSummary"] = [
  {
    title: "Ingresos atribuidos",
    value: "$48,920",
    delta: "+12.8%",
    tone: "primary" as const
  },
  {
    title: "Embajadores activos",
    value: "128",
    delta: "+9.3%",
    tone: "success" as const
  },
  {
    title: "Comisiones pendientes",
    value: "$8,240",
    delta: "+4.1%",
    tone: "warning" as const
  },
  {
    title: "Tasa de conversión",
    value: "12.4%",
    delta: "+1.7%",
    tone: "primary" as const
  }
];

export const referralLink =
  "https://embajadoresx.com/r/tomas-amayo-growth-partners";

export const referralRows: DashboardData["referralRows"] = [
  {
    name: "Camila Torres",
    email: "camila@creatorhub.com",
    source: "Instagram",
    joinedAt: "14 Abr 2026",
    status: "active",
    revenue: "$3,240"
  },
  {
    name: "Diego Salas",
    email: "diego@brandflow.io",
    source: "YouTube",
    joinedAt: "12 Abr 2026",
    status: "pending",
    revenue: "$1,180"
  },
  {
    name: "Mariana Ruiz",
    email: "mariana@socialboost.pe",
    source: "TikTok",
    joinedAt: "10 Abr 2026",
    status: "active",
    revenue: "$2,960"
  },
  {
    name: "Alonso Vega",
    email: "alonso@performancelab.co",
    source: "Newsletter",
    joinedAt: "08 Abr 2026",
    status: "review",
    revenue: "$740"
  }
];

export const commissionRows: DashboardData["commissionRows"] = [
  {
    campaign: "Lanzamiento Growth Sprint",
    ambassador: "Camila Torres",
    status: "paid",
    date: "15 Abr 2026",
    amount: "$1,240"
  },
  {
    campaign: "Afiliados Lifestyle",
    ambassador: "Mariana Ruiz",
    status: "pending",
    date: "14 Abr 2026",
    amount: "$860"
  },
  {
    campaign: "UGC Performance",
    ambassador: "Diego Salas",
    status: "review",
    date: "12 Abr 2026",
    amount: "$420"
  },
  {
    campaign: "Creator Acquisition",
    ambassador: "Alonso Vega",
    status: "paid",
    date: "10 Abr 2026",
    amount: "$1,020"
  }
];

export const mockDashboardData: DashboardData = {
  sidebarItems,
  topbarUser,
  earningsSummary,
  referralLink,
  referralRows,
  commissionRows
};
