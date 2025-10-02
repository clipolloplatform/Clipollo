// components/ui/ui-builder/components/iframeadapter.tsx
import * as React from "react";

type IframeProps = React.ComponentPropsWithoutRef<"iframe">;

export function IframeAdapter({
  frameRef,
  ...props
}: IframeProps & { frameRef?: React.Ref<HTMLIFrameElement> }) {
  return <iframe ref={frameRef} {...props} />;
}

export default IframeAdapter;
