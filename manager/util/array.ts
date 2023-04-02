export function concat<E>(...a: ReadonlyArray<E>[]): E[] {
  return Array.prototype.concat(...a);
}
