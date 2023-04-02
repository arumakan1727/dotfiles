export function cutPrefix(s: string, prefix: string): [string, boolean] {
  if (s.startsWith(prefix)) {
    return [s.substring(prefix.length), true];
  }
  return [s, false];
}
