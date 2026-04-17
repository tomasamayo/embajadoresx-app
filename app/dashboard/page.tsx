import { AppShell } from "@/components/AppShell";
import { CopyLinkBox } from "@/components/CopyLinkBox";
import { DataTable, DataTableColumn } from "@/components/DataTable";
import { StatCard } from "@/components/StatCard";
import { StatusBadge } from "@/components/StatusBadge";
import { Topbar } from "@/components/Topbar";
import { getDashboardData } from "@/lib/dashboard-data";
import { CommissionRow, ReferralRow } from "@/lib/types";

const referralColumns: DataTableColumn<ReferralRow>[] = [
  {
    key: "name",
    header: "Embajador",
    render: (row) => (
      <div>
        <p className="font-semibold text-ink">{row.name}</p>
        <p className="text-xs text-muted">{row.email}</p>
      </div>
    )
  },
  {
    key: "source",
    header: "Canal"
  },
  {
    key: "joinedAt",
    header: "Fecha"
  },
  {
    key: "status",
    header: "Estado",
    render: (row) => <StatusBadge status={row.status} />
  },
  {
    key: "revenue",
    header: "Ingresos",
    align: "right"
  }
];

const commissionColumns: DataTableColumn<CommissionRow>[] = [
  {
    key: "campaign",
    header: "Campaña"
  },
  {
    key: "ambassador",
    header: "Embajador"
  },
  {
    key: "status",
    header: "Estado",
    render: (row) => <StatusBadge status={row.status} />
  },
  {
    key: "date",
    header: "Fecha"
  },
  {
    key: "amount",
    header: "Comisión",
    align: "right"
  }
];

export default async function DashboardPage() {
  const {
    commissionRows,
    earningsSummary,
    referralLink,
    referralRows,
    topbarUser
  } = await getDashboardData();

  return (
    <AppShell>
          <Topbar
            title="Panel de embajadores"
            subtitle="Sigue el rendimiento de tu programa, comparte enlaces y monitorea comisiones en tiempo real."
            user={topbarUser}
          />

          <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {earningsSummary.map((item) => (
              <StatCard key={item.title} {...item} />
            ))}
          </section>

          <section className="grid gap-6 xl:grid-cols-[1.35fr_0.85fr]">
            <div className="rounded-4xl border border-line bg-white p-6 shadow-soft">
              <div className="mb-6 flex flex-col gap-2">
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
                  Referidos recientes
                </p>
                <h2 className="text-2xl font-semibold tracking-tight text-ink">
                  Nuevos embajadores con mejor conversión
                </h2>
              </div>

              <DataTable columns={referralColumns} rows={referralRows} />
            </div>

            <div className="flex flex-col gap-6">
              <CopyLinkBox
                title="Tu enlace de afiliado"
                description="Compártelo con nuevos embajadores o partners y centraliza cada conversión en una sola URL."
                link={referralLink}
              />

              <div className="rounded-4xl border border-line bg-[#111827] p-6 text-white shadow-soft">
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-100">
                  Insights
                </p>
                <h3 className="mt-3 text-2xl font-semibold tracking-tight">
                  Tu mejor campaña creció 18% esta semana
                </h3>
                <p className="mt-3 text-sm leading-6 text-slate-300">
                  La campaña de influencers lifestyle está generando el mayor
                  ticket promedio. Conviene priorizar comisiones escalonadas y
                  follow-up automático para embajadores activos.
                </p>
                <div className="mt-6 grid gap-4 sm:grid-cols-2">
                  <div className="rounded-3xl bg-white/10 p-4">
                    <p className="text-sm text-slate-300">CTR promedio</p>
                    <p className="mt-2 text-2xl font-semibold">4.8%</p>
                  </div>
                  <div className="rounded-3xl bg-white/10 p-4">
                    <p className="text-sm text-slate-300">Conversión</p>
                    <p className="mt-2 text-2xl font-semibold">12.4%</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
            <div className="mb-6 flex flex-col gap-2">
              <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
                Historial de comisiones
              </p>
              <h2 className="text-2xl font-semibold tracking-tight text-ink">
                Pagos, pendientes y validaciones
              </h2>
            </div>

            <DataTable columns={commissionColumns} rows={commissionRows} />
          </section>
    </AppShell>
  );
}
