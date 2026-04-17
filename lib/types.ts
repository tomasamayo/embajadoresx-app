import { StatusBadgeValue } from "@/components/StatusBadge";

export type SidebarItem = {
  label: string;
  href: string;
  active?: boolean;
  count?: number;
};

export type TopbarUser = {
  name: string;
  role: string;
  initials: string;
};

export type DashboardStat = {
  title: string;
  value: string;
  delta: string;
  tone: "primary" | "success" | "warning";
};

export type ReferralRow = {
  name: string;
  email: string;
  source: string;
  joinedAt: string;
  status: StatusBadgeValue;
  revenue: string;
};

export type CommissionRow = {
  campaign: string;
  ambassador: string;
  status: StatusBadgeValue;
  date: string;
  amount: string;
};

export type DashboardData = {
  sidebarItems: SidebarItem[];
  topbarUser: TopbarUser;
  earningsSummary: DashboardStat[];
  referralLink: string;
  referralRows: ReferralRow[];
  commissionRows: CommissionRow[];
};
