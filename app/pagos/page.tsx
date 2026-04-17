import { AppShell } from "@/components/AppShell";
import { MetricPanel } from "@/components/MetricPanel";
import { PageHeader } from "@/components/PageHeader";

export default function PagosPage() {
  return (
    <AppShell>
      <PageHeader
        eyebrow="Pagos"
        title="Calendario de liquidaciones"
        description="Organiza próximos payouts, ventanas de corte y reglas de pago para mantener una operación predecible."
      />

      <MetricPanel
        title="Próximos hitos"
        description="Vista ejecutiva de la operación de pagos."
        items={[
          { label: "Próximo corte", value: "22 Abr", helpText: "Se liquidan ventas verificadas hasta el 21 de abril." },
          { label: "Siguiente payout", value: "25 Abr", helpText: "Transferencias automáticas para afiliados aprobados." },
          { label: "Métodos habilitados", value: "3", helpText: "Transferencia, PayPal y saldo interno." }
        ]}
      />

      <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
        <h2 className="text-2xl font-semibold tracking-tight text-ink">
          Política operativa sugerida
        </h2>
        <div className="mt-6 grid gap-4 md:grid-cols-3">
          {[
            "Validar ventas sospechosas antes del corte mensual.",
            "Separar payouts automáticos de payouts manuales excepcionales.",
            "Mantener historial de liquidación por afiliado y campaña."
          ].map((item) => (
            <div key={item} className="rounded-3xl bg-slate-50 p-5 text-sm leading-6 text-muted">
              {item}
            </div>
          ))}
        </div>
      </section>
    </AppShell>
  );
}
