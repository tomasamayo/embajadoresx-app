import { TopbarUser } from "@/lib/types";

type TopbarProps = {
  title: string;
  subtitle: string;
  user: TopbarUser;
};

export function Topbar({ title, subtitle, user }: TopbarProps) {
  return (
    <header className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <div className="flex flex-col gap-6 xl:flex-row xl:items-center xl:justify-between">
        <div className="max-w-3xl">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
            Dashboard
          </p>
          <h1 className="mt-3 text-3xl font-semibold tracking-tight text-ink md:text-4xl">
            {title}
          </h1>
          <p className="mt-3 max-w-2xl text-sm leading-7 text-muted md:text-base">
            {subtitle}
          </p>
        </div>

        <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
          <div className="rounded-2xl border border-line bg-slate-50 px-4 py-3">
            <p className="text-xs uppercase tracking-[0.2em] text-muted">
              Periodo
            </p>
            <p className="mt-1 font-semibold text-ink">Últimos 30 días</p>
          </div>

          <div className="flex items-center gap-3 rounded-2xl bg-[#101828] px-4 py-3 text-white">
            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-white/10 text-sm font-semibold">
              {user.initials}
            </div>
            <div>
              <p className="font-semibold">{user.name}</p>
              <p className="text-sm text-slate-300">{user.role}</p>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
