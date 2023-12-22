import { BaseFilter, Item } from "https://deno.land/x/ddc_vim@v2.5.1/types.ts";
import { FilterArguments } from "https://deno.land/x/ddc_vim@v2.5.1/base/filter.ts";

function isLower(c: string): boolean {
  return /^[a-z]$/g.test(c);
}

function isUpper(c: string): boolean {
  return /^[A-Z]$/g.test(c);
}

type Params = Record<string, never>;

export class Filter extends BaseFilter<Params> {
  filter(
    { completeStr, items }: FilterArguments<Params>,
  ): Promise<Item[]> {
    const cs = completeStr.split("");
    if (cs.some(isLower) || cs.every((c: string) => !isUpper(c))) {
      return Promise.resolve(items);
    }
    return Promise.resolve(items.map((item: Item) => ({
      ...item,
      word: item.word.toUpperCase(),
      abbr: item.abbr ? item.abbr.toUpperCase() : undefined,
    })));
  }

  params(): Params {
    return {};
  }
}
