import { DashboardStat } from "@/lib/types";

type StatCardProps = DashboardStat;

const toneStyles = {
  primary: "bg-primary-50 text-primary-700",
  success: "bg-success-50 text-success-700",
  warning: "bg-warning-50 text-warning-700"
};

export function StatCard({ title, value, delta, tone }: StatCardProps) {
  return (
    <article className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-medium text-muted">{title}</p>
          <p className="mt-4 text-3xl font-semibold tracking-tight text-ink">
            {value}
          </p>
        </div>

        <span
          className={`rounded-full px-3 py-1 text-xs font-semibold ${toneStyles[tone]}`}
        >
          {delta}
        </span>
      </div>
    </article>
  );
}
