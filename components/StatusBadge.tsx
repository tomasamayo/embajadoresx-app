export type StatusBadgeValue = "active" | "pending" | "paid" | "review";

type StatusBadgeProps = {
  status: StatusBadgeValue;
};

const statusMap: Record<
  StatusBadgeValue,
  { label: string; className: string }
> = {
  active: {
    label: "Activo",
    className: "bg-success-50 text-success-700"
  },
  pending: {
    label: "Pendiente",
    className: "bg-warning-50 text-warning-700"
  },
  paid: {
    label: "Pagado",
    className: "bg-primary-50 text-primary-700"
  },
  review: {
    label: "En revisión",
    className: "bg-danger-50 text-danger-700"
  }
};

export function StatusBadge({ status }: StatusBadgeProps) {
  const { label, className } = statusMap[status];

  return (
    <span className={`rounded-full px-3 py-1 text-xs font-semibold ${className}`}>
      {label}
    </span>
  );
}
