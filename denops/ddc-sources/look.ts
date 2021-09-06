import { BaseSource, Candidate } from "https://deno.land/x/ddc_vim/types.ts#^";
import { GatherCandidatesArguments } from "https://deno.land/x/ddc_vim/base/source.ts";

async function run(cmd: string[]): Promise<string> {
  const p = Deno.run({ cmd, stdout: "piped", stderr: "null", stdin: "null" });
  await p.status();
  return new TextDecoder().decode(await p.output());
}

export class Source extends BaseSource {
  async gatherCandidates({
    completeStr,
  }: GatherCandidatesArguments): Promise<Candidate[]> {
    const out = await run(["look", "--", completeStr]);
    const words = out.split("\n").map((w) => w.trim()).filter((w) => w);
    const candidates = (words: string[]) => words.map((word) => ({ word }));
    return candidates(words);
  }
}
