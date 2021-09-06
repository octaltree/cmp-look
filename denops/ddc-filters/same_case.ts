import { BaseFilter, Candidate } from "https://deno.land/x/ddc_vim/types.ts#^";
import { FilterArguments } from "https://deno.land/x/ddc_vim/base/filter.ts";
import { assertEquals } from "https://deno.land/std/testing/asserts.ts";

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

function uniqueCandidates(cs: Candidate[]): Candidate[] {
  const words = new Set();
  const ret = [];
  for (const c of cs) {
    if (words.has(c.word)) continue;
    ret.push(c);
    words.add(c.word);
  }
  return ret;
}

function convert(query: string, candidates: Candidate[]): Candidate[] {
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
  const cased = candidates.map((c) => (
    {
      ...c,
      word: conv(series, c.word),
      abbr: c.abbr ? conv(series, c.abbr) : c.abbr,
    }
  ));
  return uniqueCandidates(cased);
}

export class Filter extends BaseFilter {
  filter(
    { completeStr, candidates }: FilterArguments,
  ): Promise<Candidate[]> {
    return Promise.resolve(convert(completeStr, candidates));
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
