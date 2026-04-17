import { AppShell } from "@/components/AppShell";
import { MetricPanel } from "@/components/MetricPanel";
import { PageHeader } from "@/components/PageHeader";

const campaigns = [
  {
    name: "Afiliados Lifestyle",
    budget: "$12,000",
    performance: "ROAS 4.2x",
    note: "La campaña más eficiente en TikTok y Reels."
  },
  {
    name: "Growth Sprint",
    budget: "$8,500",
    performance: "ROAS 3.6x",
    note: "Fuerte captación de leads con contenido largo."
  },
  {
    name: "Creator Acquisition",
    budget: "$5,900",
    performance: "ROAS 2.9x",
    note: "Conviene revisar comisión fija vs variable."
  }
];

export default function CampanasPage() {
  return (
    <AppShell>
      <PageHeader
        eyebrow="Campañas"
        title="Portafolio de campañas activas"
        description="Centraliza presupuesto, performance y foco operativo para cada campaña de afiliación."
      />

      <MetricPanel
        title="Resumen de campañas"
        description="Lectura rápida del estado del funnel comercial por campaña."
        items={[
          { label: "Campañas activas", value: "12" },
          { label: "ROAS promedio", value: "3.8x" },
          { label: "Presupuesto mensual", value: "$42,300" }
        ]}
      />

      <section className="grid gap-6 xl:grid-cols-3">
        {campaigns.map((campaign) => (
          <article
            key={campaign.name}
            className="rounded-4xl border border-line bg-white p-6 shadow-soft"
          >
            <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
              Activa
            </p>
            <h2 className="mt-3 text-2xl font-semibold tracking-tight text-ink">
              {campaign.name}
            </h2>
            <p className="mt-4 text-sm text-muted">Presupuesto: {campaign.budget}</p>
            <p className="mt-2 text-sm text-muted">Performance: {campaign.performance}</p>
            <p className="mt-4 text-sm leading-6 text-muted">{campaign.note}</p>
          </article>
        ))}
      </section>
    </AppShell>
  );
}
