import { BaseFilter, Item } from "https://deno.land/x/ddc_vim/types.ts#^";
import { FilterArguments } from "https://deno.land/x/ddc_vim/base/filter.ts";

function isLower(c: string): boolean {
  return /^[a-z]$/g.test(c);
}

function isUpper(c: string): boolean {
  return /^[A-Z]$/g.test(c);
}

type Params = Record<string, never>;

export class Filter extends BaseFilter<Params> {
  filter(
    { completeStr, candidates }: FilterArguments<Params>,
  ): Promise<Item[]> {
    const cs = completeStr.split("");
    if (cs.some(isLower) || cs.every((c) => !isUpper(c))) {
      return Promise.resolve(candidates);
    }
    return Promise.resolve(candidates.map((candidate) => ({
      ...candidate,
      word: candidate.word.toUpperCase(),
      abbr: candidate.abbr ? candidate.abbr.toUpperCase() : undefined,
    })));
  }

  params(): Params {
    return {};
  }
}
