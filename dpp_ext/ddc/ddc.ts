import { BaseConfig, ConfigArguments } from "jsr:@shougo/ddc-vim@~9.1.0/config";
import { type DdcItem } from "jsr:@shougo/ddc-vim@~9.1.0/types";

import type { Denops } from "jsr:@denops/std@~7.4.0";
import * as fn from "jsr:@denops/std@~7.4.0/function";

export class Config extends BaseConfig {
    override async config(args: ConfigArguments): Promise<void> {

        const commonSources = [
            "around",
            "file",
            "denippet"
        ];

        args.contextBuilder.patchGlobal({
            ui: "pum",
            dynamicUi: async (denops: Denops, args: Record<string, unknown>) => {
                const uiArgs = args as {
                    items: DdcItem[];
                };
                const mode = await fn.mode(denops);
                return Promise.resolve(
                    mode !== "t" && uiArgs.items.length == 1 ? "inline" : "pum",
                );
            },
            autoCompleteEvents: [
                "CmdlineChanged",
                "CmdlineEnter",
                "InsertEnter",
                "TextChangedI",
                "TextChangedP",
                "TextChangedT",
            ],
            sources: commonSources,
            cmdlineSources: {
                ":": ["cmdline", "cmdline-history", "around"],
                "@": ["input", "cmdline-history", "file", "around"],
                ">": ["input", "cmdline-history", "file", "around"],
                "/": ["around", "line"],
                "?": ["around", "line"],
                "-": ["around", "line"],
                "=": ["input"],
            },
                sourceOptions: {
                    _: {
                        ignoreCase: true,
                        matchers: ["matcher_fuzzy"],
                        sorters: ["sorter_fuzzy"],
                        converters: ["converter_fuzzy"],
                        timeout: 1000,
                    },
                    around: {
                        mark: "A",
                    },
                    buffer: {
                        mark: "B",
                    },
                    cmdline: {
                        mark: "cmdline",
                        forceCompletionPattern: "\\S/\\S*|\\.\\w*",
                    },
                    codeium: {
                        mark: "cod",
                        matchers: ["matcher_length"],
                        minAutoCompleteLength: 0,
                        isVolatile: true,
                    },
                    input: {
                        mark: "input",
                        forceCompletionPattern: "\\S/\\S*",
                        isVolatile: true,
                    },
                    line: {
                        mark: "line",
                    },
                    lsp: {
                        mark: "lsp",
                        forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
                        dup: "force",
                    },
                    file: {
                        mark: "F",
                        isVolatile: true,
                        minAutoCompleteLength: 1000,
                        forceCompletionPattern: "\\S/\\S*",
                    },
                    "cmdline-history": {
                        mark: "history",
                        sorters: [],
                    },
                    "shell-native": {
                        mark: "sh",
                        isVolatile: true,
                        forceCompletionPattern: "\\S/\\S*",
                    },
                },
                sourceParams: {
                    buffer: {
                        requireSameFiletype: false,
                        limitBytes: 50000,
                        fromAltBuf: true,
                        forceCollect: true,
                    },
                    file: {
                        filenameChars: "[:keyword:].",
                    },
                    lsp: {
                        enableAdditionalTextEdit: true,
                        enableDisplayDetail: true,
                        enableMatchLabel: true,
                        enableResolveItem: true,
                    },
                    "shell-native": {
                        shell: "fish",
                    },
                },
        });

        for (
            const filetype of [
                "markdown",
                "markdown_inline",
                "gitcommit",
                "comment",
            ]
        ) {
            args.contextBuilder.patchFiletype(filetype, {
                sources: commonSources.concat(["line"]),
            });
        }

        for (const filetype of ["html", "css"]) {
            args.contextBuilder.patchFiletype(filetype, {
                sourceOptions: {
                    _: {
                        keywordPattern: "[0-9a-zA-Z_:#-]*",
                    },
                },
            });
        }

        for (const filetype of ["zsh", "sh", "bash", "nushell"]) {
            args.contextBuilder.patchFiletype(filetype, {
                sourceOptions: {
                    _: {
                        keywordPattern: "[0-9a-zA-Z_./#:-]*",
                    },
                },
                sources: [
                    "shell-native",
                    "around",
                ],
            });
        }
        args.contextBuilder.patchFiletype("deol", {
            specialBufferCompletion: true,
            sources: [
                "shell-native",
                "shell-history",
                "around",
            ],
            sourceOptions: {
                _: {
                    keywordPattern: "[0-9a-zA-Z_./#:-]*",
                },
            },
        });

        // Use "#" as TypeScript keywordPattern
        for (const filetype of ["typescript"]) {
            args.contextBuilder.patchFiletype(filetype, {
                sourceOptions: {
                    _: {
                        keywordPattern: "#?[a-zA-Z_][0-9a-zA-Z_]*",
                    },
                },
            });
        }

        for (
            const filetype of [
                "css",
                "go",
                "graphql",
                "html",
                "lua",
                "python",
                "ruby",
                "rust",
                "tsx",
                "typescript",
                "typescriptreact",
            ]
        ) {
            args.contextBuilder.patchFiletype(filetype, {
                sources: ["lsp"].concat(commonSources),
            });
        }
    }
}
