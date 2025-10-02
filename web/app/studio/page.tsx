// app/studio/page.tsx
"use client";

import React from "react";

// UI Builder core (added by the shadcn registry step)
import UIBuilder from "@/components/ui/ui-builder";

// Pre-registered component maps (added by the registry step)
import { primitiveComponentDefinitions } from "@/lib/ui-builder/registry/primitive-component-definitions";
import { complexComponentDefinitions } from "@/lib/ui-builder/registry/complex-component-definitions";

import type { ComponentRegistry } from "@/components/ui/ui-builder/types";

const componentRegistry: ComponentRegistry = {
  ...primitiveComponentDefinitions,
  ...complexComponentDefinitions,
};

export default function StudioPage() {
  return (
    <main className="min-h-screen p-6">
      <h1 className="text-2xl font-semibold mb-4">Clipollo Studio</h1>
      <UIBuilder componentRegistry={componentRegistry} />
    </main>
  );
}
