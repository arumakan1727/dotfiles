export class ErrUnsupportedOS extends Error {
  readonly os: typeof Deno.build.os;

  constructor(os: typeof Deno.build.os) {
    super(`unsupported os: ${os}`);
    this.os = os;
    this.name = "ErrUnsupportedOS";
  }
}

export class ErrUnsupportedDistrib extends Error {
  readonly distrib: string;

  constructor(distrib: string) {
    super(`unsupported linux distribution: ${distrib}`);
    this.distrib = distrib;
    this.name = "ErrUnsupportedDistrib";
  }
}
