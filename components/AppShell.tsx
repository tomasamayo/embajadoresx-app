import { ReactNode } from "react";

import { AppSidebar } from "@/components/AppSidebar";
import { appNavigation } from "@/lib/navigation";

type AppShellProps = {
  children: ReactNode;
};

export function AppShell({ children }: AppShellProps) {
  return (
    <main className="min-h-screen bg-canvas text-ink">
      <div className="mx-auto flex max-w-[1600px] flex-col gap-6 px-4 py-4 md:px-6 lg:flex-row lg:gap-8 lg:px-8 lg:py-8">
        <AppSidebar items={appNavigation} />
        <div className="flex min-w-0 flex-1 flex-col gap-6">{children}</div>
      </div>
    </main>
  );
}
