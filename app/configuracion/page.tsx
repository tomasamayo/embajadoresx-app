import { AppShell } from "@/components/AppShell";
import { PageHeader } from "@/components/PageHeader";

const settingsGroups = [
  {
    title: "Programa",
    items: ["Nombre del programa", "Dominio de referidos", "Reglas de atribución"]
  },
  {
    title: "Comisiones",
    items: ["Comisión fija", "Comisión variable", "Bonos por performance"]
  },
  {
    title: "Pagos",
    items: ["Frecuencia de payout", "Métodos habilitados", "Validaciones antifraude"]
  }
];

export default function ConfiguracionPage() {
  return (
    <AppShell>
      <PageHeader
        eyebrow="Configuración"
        title="Reglas del programa"
        description="Define la lógica operativa del producto antes de conectar automatizaciones y backend real."
      />

      <section className="grid gap-6 xl:grid-cols-3">
        {settingsGroups.map((group) => (
          <article
            key={group.title}
            className="rounded-4xl border border-line bg-white p-6 shadow-soft"
          >
            <h2 className="text-2xl font-semibold tracking-tight text-ink">
              {group.title}
            </h2>
            <div className="mt-5 space-y-3">
              {group.items.map((item) => (
                <div
                  key={item}
                  className="rounded-2xl border border-line bg-slate-50 px-4 py-3 text-sm text-muted"
                >
                  {item}
                </div>
              ))}
            </div>
          </article>
        ))}
      </section>
    </AppShell>
  );
}
