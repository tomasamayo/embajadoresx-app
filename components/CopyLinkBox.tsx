"use client";

import { useState } from "react";

type CopyLinkBoxProps = {
  title: string;
  description: string;
  link: string;
};

export function CopyLinkBox({ title, description, link }: CopyLinkBoxProps) {
  const [copied, setCopied] = useState(false);
  const [hasError, setHasError] = useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(link);
      setCopied(true);
      setHasError(false);
      window.setTimeout(() => setCopied(false), 1800);
    } catch {
      setHasError(true);
      setCopied(false);
    }
  };

  return (
    <section className="rounded-4xl border border-line bg-white p-6 shadow-soft">
      <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary-600">
        Activa el crecimiento
      </p>
      <h2 className="mt-3 text-2xl font-semibold tracking-tight text-ink">
        {title}
      </h2>
      <p className="mt-3 text-sm leading-6 text-muted">{description}</p>

      <div className="mt-6 rounded-3xl border border-line bg-slate-50 p-3">
        <p className="truncate text-sm font-medium text-ink">{link}</p>
      </div>

      <button
        type="button"
        onClick={handleCopy}
        className="mt-4 inline-flex w-full items-center justify-center rounded-2xl bg-primary-600 px-4 py-3 text-sm font-semibold text-white transition hover:bg-primary-700"
      >
        {copied ? "Enlace copiado" : "Copiar enlace"}
      </button>

      {hasError ? (
        <p className="mt-3 text-sm text-danger-700">
          No se pudo copiar automáticamente. Puedes copiar la URL manualmente.
        </p>
      ) : null}
    </section>
  );
}
