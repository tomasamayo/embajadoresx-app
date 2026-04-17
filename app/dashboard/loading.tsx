function CardSkeleton() {
  return (
    <div className="h-32 animate-pulse rounded-4xl border border-line bg-white p-6 shadow-soft">
      <div className="h-4 w-24 rounded-full bg-slate-200" />
      <div className="mt-6 h-10 w-32 rounded-full bg-slate-200" />
    </div>
  );
}

function TableSkeleton() {
  return (
    <div className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <div className="h-4 w-32 animate-pulse rounded-full bg-slate-200" />
      <div className="mt-4 h-8 w-72 animate-pulse rounded-full bg-slate-200" />
      <div className="mt-6 space-y-3">
        {Array.from({ length: 4 }).map((_, index) => (
          <div
            key={index}
            className="h-14 animate-pulse rounded-2xl bg-slate-100"
          />
        ))}
      </div>
    </div>
  );
}

export default function DashboardLoading() {
  return (
    <main className="min-h-screen bg-canvas text-ink">
      <div className="mx-auto flex max-w-[1600px] flex-col gap-6 px-4 py-4 md:px-6 lg:flex-row lg:gap-8 lg:px-8 lg:py-8">
        <div className="hidden h-[720px] w-full max-w-[280px] animate-pulse rounded-4xl border border-line bg-white shadow-soft lg:block" />

        <div className="flex flex-1 flex-col gap-6">
          <div className="h-52 animate-pulse rounded-4xl border border-line bg-white shadow-soft" />

          <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {Array.from({ length: 4 }).map((_, index) => (
              <CardSkeleton key={index} />
            ))}
          </section>

          <section className="grid gap-6 xl:grid-cols-[1.35fr_0.85fr]">
            <TableSkeleton />
            <div className="space-y-6">
              <div className="h-80 animate-pulse rounded-4xl border border-line bg-white shadow-soft" />
              <div className="h-72 animate-pulse rounded-4xl bg-[#111827] shadow-soft" />
            </div>
          </section>

          <TableSkeleton />
        </div>
      </div>
    </main>
  );
}
