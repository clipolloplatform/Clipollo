"use client";

import React, { memo, useCallback, useMemo, useState } from "react";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
// NOTE: use ESM styles path (newer versions)
// Old CJS path was: dist/cjs/styles/prism
import { coldarkDark } from "react-syntax-highlighter/dist/esm/styles/prism";

import { CopyIcon, CheckIcon } from "lucide-react";
import { useCopyToClipboard } from "@/hooks/use-copy-to-clipboard";
import { Button } from "@/components/ui/button";

type CodeBlockProps = {
  code: string;
  language?: string;
  showCopy?: boolean;
  className?: string;
};

const CodeBlockBase = ({
  code,
  language = "tsx",
  showCopy = true,
  className = "",
}: CodeBlockProps) => {
  const normalized = useMemo(() => (code ?? "").trim(), [code]);
  const { copy } = useCopyToClipboard();
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(async () => {
    await copy(normalized);
    setCopied(true);
    setTimeout(() => setCopied(false), 1600);
  }, [copy, normalized]);

  return (
    <div className={`relative rounded-md overflow-hidden ${className}`}>
      {showCopy && (
        <div className="absolute right-2 top-2 z-10">
          <Button size="sm" variant="secondary" onClick={handleCopy}>
            {copied ? (
              <>
                <CheckIcon className="h-4 w-4 mr-1" />
                Copied
              </>
            ) : (
              <>
                <CopyIcon className="h-4 w-4 mr-1" />
                Copy
              </>
            )}
          </Button>
        </div>
      )}

      <SyntaxHighlighter
        language={language}
        style={coldarkDark}
        customStyle={{ margin: 0, padding: "16px", background: "transparent" }}
        codeTagProps={{ style: { fontSize: 13, lineHeight: 1.5 } }}
      >
        {normalized}
      </SyntaxHighlighter>
    </div>
  );
};

export const CodeBlock = memo(CodeBlockBase); // named export
export default CodeBlock;                     // default export (kept)
