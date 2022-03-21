import {
  BaseSource,
  Item,
} from "https://deno.land/x/ddc_vim@v2.2.0/types.ts#^";
import { GatherArguments } from "https://deno.land/x/ddc_vim@v2.2.0/base/source.ts#^";
import { assertEquals } from "https://deno.land/std/testing/asserts.ts";

async function run(cmd: string[]): Promise<string> {
  const p = Deno.run({ cmd, stdout: "piped", stderr: "null", stdin: "null" });
  await p.status();
  return new TextDecoder().decode(await p.output());
}

function isLower(c: string): boolean {
  return /^[a-z]$/g.test(c);
}

function isUpper(c: string): boolean {
  return /^[A-Z]$/g.test(c);
}

type Case = {
  // -1: lower eng alph, 0: others, 1: upper eng alph
  v: number;
  n: number;
};

function conv(series: Case[], word: string): string {
  let ret = "";
  let offset = 0;
  const f = (v: number, s: string) =>
    v < 0 ? s.toLowerCase() : v > 0 ? s.toUpperCase() : s;
  for (const s of series) {
    const target = word.slice(offset, offset + s.n);
    ret += f(s.v, target);
    offset += s.n;
  }
  ret += word.slice(offset);
  return ret;
}

function unique<T>(xs: T[]): T[] {
  const pool = new Set();
  const ret = [];
  for (const x of xs) {
    if (pool.has(x)) continue;
    ret.push(x);
    pool.add(x);
  }
  return ret;
}

function convert(query: string, words: string[]): string[] {
  const flg = query.split("").map((c) => isLower(c) ? -1 : isUpper(c) ? 1 : 0);
  const series = flg.reduce((a: Case[], b) => {
    if (!a.length) return [{ v: b, n: 1 }];
    const last = a.slice(-1)[0];
    if (last.v == b) {
      last.n++;
      return a;
    } else {
      a.push({ v: b, n: 1 });
      return a;
    }
  }, []);
  return unique(words.map((w) => conv(series, w)));
}

type Params = {
  convertCase: boolean;
  dict: undefined | string;
};

export class Source extends BaseSource<Params> {
  async gather({
    sourceParams,
    completeStr,
  }: GatherArguments<Params>): Promise<Item[]> {
    const args = typeof sourceParams.dict == "string"
      ? ["-f", "--", completeStr, sourceParams.dict]
      : ["--", completeStr];
    const out = await run(["look"].concat(args));
    const words = out.split("\n").map((w) => w.trim()).filter((w) => w);
    const candidates = (words: string[]) => words.map((word) => ({ word }));
    const cased = sourceParams.convertCase
      ? convert(completeStr, words)
      : words;
    return candidates(cased);
  }

  params(): Params {
    const params: Params = {
      convertCase: true,
      dict: undefined,
    };
    return params;
  }
}

Deno.test("conv", function () {
  assertEquals(conv([{ v: 1, n: 2 }], "azadrachta"), "AZadrachta");
  assertEquals(
    conv(
      [{ v: 1, n: 1 }, { v: -1, n: 1 }, { v: 1, n: 1 }, { v: -1, n: 2 }],
      "assemblable",
    ),
    "AsSemblable",
  );
});

Deno.test("convert", function () {
  assertEquals(
    convert("AZ", [
      "az",
      "azadrachta",
      "azafrin",
      "AZ",
      "Azalea",
    ]),
    [
      "AZ",
      "AZadrachta",
      "AZafrin",
      "AZalea",
    ],
  );
  assertEquals(
    convert("AsSem", [
      "assemblable",
      "assemblage",
      "assemble",
      "assembler",
      "assembly",
      "assemblyman",
    ]),
    [
      "AsSemblable",
      "AsSemblage",
      "AsSemble",
      "AsSembler",
      "AsSembly",
      "AsSemblyman",
    ],
  );
});
