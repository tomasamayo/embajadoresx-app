import { AppShell } from "@/components/AppShell";
import { DataTable, DataTableColumn } from "@/components/DataTable";
import { MetricPanel } from "@/components/MetricPanel";
import { PageHeader } from "@/components/PageHeader";
import { StatusBadge } from "@/components/StatusBadge";
import { referralRows } from "@/lib/mock-data";
import { ReferralRow } from "@/lib/types";

const ambassadorColumns: DataTableColumn<ReferralRow>[] = [
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
  { key: "source", header: "Canal" },
  { key: "joinedAt", header: "Ingreso" },
  {
    key: "status",
    header: "Estado",
    render: (row) => <StatusBadge status={row.status} />
  },
  { key: "revenue", header: "Ingresos", align: "right" }
];

export default function EmbajadoresPage() {
  return (
    <AppShell>
      <PageHeader
        eyebrow="Embajadores"
        title="Red activa de afiliados"
        description="Gestiona el desempeño de tu base de embajadores, revisa su activación y detecta rápido quién merece incentivos adicionales."
      />

      <MetricPanel
        title="Visión operativa"
        description="KPIs clave para decidir reclutamiento, activación y retención de afiliados."
        items={[
          { label: "Embajadores activos", value: "128", helpText: "78 con ventas en los últimos 30 días." },
          { label: "Tasa de activación", value: "61%", helpText: "Subió 8 puntos frente al ciclo anterior." },
          { label: "Ticket promedio", value: "$142", helpText: "Mayor tracción en canales lifestyle y contenido UGC." }
        ]}
      />

      <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
        <DataTable columns={ambassadorColumns} rows={referralRows} />
      </section>
    </AppShell>
  );
}
