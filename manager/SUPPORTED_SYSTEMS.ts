export const supportedSysNames = [
  "Darwin",
  "Ubuntu",
] as const;

export type SupportedSysName = (typeof supportedSysNames)[number];
