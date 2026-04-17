import { ReactNode } from "react";

type PageHeaderProps = {
  eyebrow: string;
  title: string;
  description: string;
  action?: ReactNode;
};

export function PageHeader({
  eyebrow,
  title,
  description,
  action
}: PageHeaderProps) {
  return (
    <header className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <div className="flex flex-col gap-6 xl:flex-row xl:items-end xl:justify-between">
        <div className="max-w-3xl">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
            {eyebrow}
          </p>
          <h1 className="mt-3 text-3xl font-semibold tracking-tight text-ink md:text-4xl">
            {title}
          </h1>
          <p className="mt-3 max-w-2xl text-sm leading-7 text-muted md:text-base">
            {description}
          </p>
        </div>

        {action ? <div>{action}</div> : null}
      </div>
    </header>
  );
}
