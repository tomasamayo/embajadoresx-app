import { mockDashboardData } from "@/lib/mock-data";
import { DashboardData } from "@/lib/types";

async function fetchDashboardFromApi(): Promise<DashboardData | null> {
  const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;

  if (!apiBaseUrl) {
    return null;
  }

  try {
    const response = await fetch(`${apiBaseUrl}/api/dashboard`, {
      cache: "no-store",
      headers: {
        "Content-Type": "application/json"
      }
    });

    if (!response.ok) {
      return null;
    }

    return (await response.json()) as DashboardData;
  } catch {
    return null;
  }
}

export async function getDashboardData(): Promise<DashboardData> {
  const apiData = await fetchDashboardFromApi();

  if (apiData) {
    return apiData;
  }

  return mockDashboardData;
}
