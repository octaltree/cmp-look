import {
  BaseSource,
  Candidate,
  Context,
  DdcOptions,
  SourceOptions,
} from "https://deno.land/x/ddc_vim@v0.0.11/types.ts#^";
import { Denops } from "https://deno.land/x/ddc_vim@v0.0.11/deps.ts#^";

async function sh(cmd: string[]): Promise<string> {
  const p = Deno.run({ cmd, stdout: "piped", stderr: "null", stdin: "null" });
  await p.status();
  return new TextDecoder().decode(await p.output());
}

export class Source extends BaseSource {
  async gatherCandidates(
    _denops: Denops,
    _context: Context,
    _ddcOptions: DdcOptions,
    _sourceOptions: SourceOptions,
    _sourceParams: Record<string, unknown>,
    completeStr: string,
  ): Promise<Candidate[]> {
    const out = await sh(["look", "--", completeStr]);
    const words = out.split("\n").map(String.prototype.trim).filter((w) => w);
    return words.map((word) => ({ word }));
  }

  params(): Record<string, unknown> {
    return {};
  }
}
