// app/engine-status/page.tsx
import React from "react";

type Health = { status: string; service?: string; version?: string };

async function getHealth(): Promise<{ ok: boolean; data?: Health; error?: string }> {
  try {
    const res = await fetch("http://127.0.0.1:5173/health", { cache: "no-store" });
    if (!res.ok) return { ok: false, error: `HTTP ${res.status}` };
    const data = (await res.json()) as Health;
    return { ok: true, data };
  } catch (e: any) {
    return { ok: false, error: String(e?.message ?? e) };
  }
}

export default async function EngineStatusPage() {
  const health = await getHealth();

  return (
    <main className="min-h-[60vh] flex items-center justify-center p-8">
      <div className="max-w-xl w-full rounded-xl border p-6">
        <h1 className="text-2xl font-semibold mb-4">Engine Health</h1>
        {health.ok ? (
          <pre className="bg-black/5 rounded p-4 text-sm">
{JSON.stringify(health.data, null, 2)}
          </pre>
        ) : (
          <div className="text-red-500">
            Couldn’t reach daemon: <span className="font-mono">{health.error}</span>
          </div>
        )}
        <div className="mt-4 text-sm text-muted-foreground">
          If this shows <code>{"{ status: \"ok\" }"}</code> your Rust daemon is up.
        </div>
      </div>
    </main>
  );
}
