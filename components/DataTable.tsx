import { ReactNode } from "react";

export type DataTableColumn<T> = {
  key: keyof T;
  header: string;
  align?: "left" | "right";
  render?: (row: T) => ReactNode;
};

type DataTableProps<T> = {
  columns: DataTableColumn<T>[];
  rows: T[];
};

export function DataTable<T extends Record<string, ReactNode | string>>({
  columns,
  rows
}: DataTableProps<T>) {
  return (
    <div className="overflow-hidden rounded-3xl border border-line">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-line">
          <thead className="bg-slate-50">
            <tr>
              {columns.map((column) => (
                <th
                  key={String(column.key)}
                  className={[
                    "px-5 py-4 text-xs font-semibold uppercase tracking-[0.18em] text-muted",
                    column.align === "right" ? "text-right" : "text-left"
                  ].join(" ")}
                >
                  {column.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-line bg-white">
            {rows.map((row, index) => (
              <tr key={index} className="transition hover:bg-slate-50/80">
                {columns.map((column) => (
                  <td
                    key={String(column.key)}
                    className={[
                      "px-5 py-4 text-sm text-muted",
                      column.align === "right" ? "text-right" : "text-left"
                    ].join(" ")}
                  >
                    {column.render ? column.render(row) : row[column.key]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
