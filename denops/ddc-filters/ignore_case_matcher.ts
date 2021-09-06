import { BaseFilter, Candidate } from "https://deno.land/x/ddc_vim/types.ts#^";
import { FilterArguments } from "https://deno.land/x/ddc_vim/base/filter.ts";

export class Filter extends BaseFilter {
  filter(
    { completeStr, candidates }: FilterArguments,
  ): Promise<Candidate[]> {
    const query = completeStr.toLowerCase();
    return Promise.resolve(
      candidates.filter((c) => c.word.toLowerCase().startsWith(query)),
    );
  }
}
