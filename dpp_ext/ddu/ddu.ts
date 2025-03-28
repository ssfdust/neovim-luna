// Ddu 
import {
  type ActionArguments,
  ActionFlags,
  type DduOptions,
} from "jsr:@shougo/ddu-vim@~9.1.0/types";
import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddu-vim@~9.1.0/config";
import { type ActionData as FileAction } from "jsr:@shougo/ddu-kind-file@~0.9.0";
import { type Params as FfParams } from "jsr:@shougo/ddu-ui-ff@~1.6.0";
import { type Params as FilerParams } from "jsr:@shougo/ddu-ui-filer@~1.5.0";

import type { Denops } from "jsr:@denops/std@~7.4.0";
import * as fn from "jsr:@denops/std@~7.4.0/function";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.setAlias("files", "source", "file_rg", "file_external");
    args.setAlias("files", "source", "file_git", "file_external");
    args.setAlias("files", "filter", "matcher_ignore_current_buffer", "matcher_ignores");
    args.setAlias("files", "action", "tabopen", "open");
    args.setAlias("files", "column", "icon_filename_for_ff", "icon_filename");

    args.contextBuilder.patchGlobal({
      ui: "ff",
      profile: false,
      uiOptions: {
        filer: {
          toggle: true,
        },
      },
      uiParams: {
        ff: {
          autoAction: {
            name: "preview",
          },
          filterSplitDirection: "floating",
          floatingBorder: "rounded",
          highlights: {
            filterText: "Statement",
            floating: "StatusLine",
            floatingCursorLine: "TabLineSel",
            floatingBorder: "StatusLine",
          },
          inputFunc: "cmdline#input",
          inputOptsFunc: "cmdline#input_opts",
          maxHighlightItems: 50,
          onPreview: async (args: {
            denops: Denops;
            previewWinId: number;
          }) => {
            await fn.win_execute(args.denops, args.previewWinId, "normal! zt");
          },
          startFilter: true,
          previewFloating: true,
          // split: true,
          previewFloatingBorder: "single",
          //previewSplit: "no",
          // startAutoAction: true,
          updateTime: 0,
          winWidth: 100,
        } as Partial<FfParams>,
        filer: {
          autoAction: {
            name: "preview",
          },
          previewCol: "&columns / 2 + 1",
          previewFloating: true,
          sort: "filename",
          sortTreesFirst: true,
          split: "no",
          //startAutoAction: true,
          toggle: true,
        } as Partial<FilerParams>,
      },
      columnParams: {
        icon_filename: {
          defaultIcon: {
            icon: '',
          },
        },
        icon_filename_for_ff: {
          defaultIcon: {
            icon: '',
          },
          pathDisplayOption: 'relative',
        },
      },
      sourceOptions: {
        _: {
          ignoreCase: true,
          matchers: ["matcher_substring"],
          smartCase: true,
        },
        file_old: {
          columns: ['icon_filename_for_ff'],
          matchers: [
            "matcher_relative",
            "matcher_substring",
          ],
          converters: ["converter_hl_dir"],
        },
        file_git: {
          columns: ['icon_filename_for_ff'],
          matchers: [
            "matcher_relative",
            "matcher_substring",
          ],
          sorters: ["sorter_mtime"],
          converters: ["converter_hl_dir"],
        },
        file_rec: {
          columns: ['icon_filename_for_ff'],
          matchers: [
            "matcher_substring",
            "matcher_hidden",
          ],
          sorters: ["sorter_mtime"],
          converters: ["converter_hl_dir"],
        },
        file: {
          columns: ['icon_filename'],
          matchers: [
            "matcher_substring",
            "matcher_hidden",
          ],
          sorters: ["sorter_alpha"],
          converters: ["converter_hl_dir"],
        },
        dpp: {
          defaultAction: "cd",
          actions: {
            update: async (args: ActionArguments<Params>) => {
              const names = args.items.map((item) =>
                (item.action as DppAction).__name
              );

              await args.denops.call(
                "dpp#async_ext_action",
                "installer",
                "update",
                { names },
              );

              return Promise.resolve(ActionFlags.None);
            },
          },
        },
        command_args: {
          defaultAction: "execute",
        },
        markdown: {
          sorters: [],
        },
        path_history: {
          defaultAction: "uiCd",
        },
        rg: {
          matchers: [
            "matcher_substring",
            "matcher_files",
          ],
        },
      },
      sourceParams: {
        file_git: {
          cmd: ["git", "ls-files", "-co", "--exclude-standard"],
        },
        rg: {
          args: [
            "--smart-case",
            "--column",
            "--no-heading",
            "--color",
            "never",
          ],
        },
        file_rg: {
          cmd: [
            "rg",
            "--files",
            "--glob",
            "!.git",
            "--color",
            "never",
            "--no-messages",
          ],
          updateItems: 50000,
        },
      },
      filterParams: {
        matcher_substring: {
          highlightMatched: "Search",
        },
        matcher_ignore_files: {
          ignoreGlobs: ["test_*.vim"],
          ignorePatterns: [],
        },
        converter_hl_dir: {
          hlGroup: ["Directory", "Keyword"],
        },
      },
      kindOptions: {
        file: {
          defaultAction: "open",
          actions: {
            grep: async (args: ActionArguments<Params>) => {
              const action = args.items[0]?.action as FileAction;

              await args.denops.call("ddu#start", {
                name: args.options.name,
                push: true,
                sources: [
                  {
                    name: "rg",
                    params: {
                      path: action.path,
                      input: await fn.input(args.denops, "Pattern: "),
                    },
                  },
                ],
              });

              return Promise.resolve(ActionFlags.None);
            },
          },
        },
        deol: {
          defaultAction: "switch",
        },
        action: {
          defaultAction: "do",
        },
      },
      kindParams: {},
      actionOptions: {
        narrow: {
          quit: false,
        },
        tabopen: {
          quit: false,
        },
      },
      actionParams: {
        tabopen: {
          command: "tabedit",
        },
      },
    });

    return Promise.resolve();
  }
}
