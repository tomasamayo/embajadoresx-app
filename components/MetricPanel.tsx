type MetricItem = {
  label: string;
  value: string;
  helpText?: string;
};

type MetricPanelProps = {
  title: string;
  description: string;
  items: MetricItem[];
};

export function MetricPanel({
  title,
  description,
  items
}: MetricPanelProps) {
  return (
    <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <h2 className="text-2xl font-semibold tracking-tight text-ink">{title}</h2>
      <p className="mt-2 text-sm leading-6 text-muted">{description}</p>

      <div className="mt-6 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <div key={item.label} className="rounded-3xl bg-slate-50 p-5">
            <p className="text-sm font-medium text-muted">{item.label}</p>
            <p className="mt-3 text-3xl font-semibold tracking-tight text-ink">
              {item.value}
            </p>
            {item.helpText ? (
              <p className="mt-2 text-sm leading-6 text-muted">{item.helpText}</p>
            ) : null}
          </div>
        ))}
      </div>
    </section>
  );
}
