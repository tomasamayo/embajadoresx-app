import { AppShell } from "@/components/AppShell";
import { DataTable, DataTableColumn } from "@/components/DataTable";
import { MetricPanel } from "@/components/MetricPanel";
import { PageHeader } from "@/components/PageHeader";
import { StatusBadge } from "@/components/StatusBadge";
import { commissionRows } from "@/lib/mock-data";
import { CommissionRow } from "@/lib/types";

const commissionColumns: DataTableColumn<CommissionRow>[] = [
  { key: "campaign", header: "Campaña" },
  { key: "ambassador", header: "Embajador" },
  {
    key: "status",
    header: "Estado",
    render: (row) => <StatusBadge status={row.status} />
  },
  { key: "date", header: "Fecha" },
  { key: "amount", header: "Monto", align: "right" }
];

export default function ComisionesPage() {
  return (
    <AppShell>
      <PageHeader
        eyebrow="Comisiones"
        title="Control de payouts y validaciones"
        description="Supervisa qué se pagó, qué sigue en revisión y qué comisiones necesitan validación operativa antes del payout."
      />

      <MetricPanel
        title="Estado financiero"
        description="Indicadores rápidos para operaciones de afiliados."
        items={[
          { label: "Pagado este mes", value: "$18,420" },
          { label: "Pendiente por aprobar", value: "$8,240" },
          { label: "En revisión", value: "$2,180" }
        ]}
      />

      <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
        <DataTable columns={commissionColumns} rows={commissionRows} />
      </section>
    </AppShell>
  );
}
