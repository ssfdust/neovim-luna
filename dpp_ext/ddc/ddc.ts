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
                ":": ["cmdline", "cmdline_history", "around"],
                "@": ["input", "cmdline_history", "file", "around"],
                ">": ["input", "cmdline_history", "file", "around"],
                "/": ["around", "line"],
                "?": ["around", "line"],
                "-": ["around", "line"],
                "=": ["input"],
            },
            filterParams: {
                matcher_fuzzy: {
                    hlGroup: "Title"
                },
                converter_kind_labels: {
                    kindLabels: {
                        Text: "Text ",
                        Method: "Method ",
                        Function: "Function ",
                        Constructor: "Constructor ",
                        Field: "Field ",
                        Variable: "Variable ",
                        Class: "Class ",
                        Interface: "Interface ",
                        Module: "Module ",
                        Property: "Property ",
                        Unit: "Unit ",
                        Value: "Value ",
                        Enum: "Enum ",
                        Keyword: "Keyword ",
                        Snippet: "Snippet ",
                        Color: "Color ",
                        File: "File ",
                        Reference: "Reference ",
                        Folder: "Folder ",
                        EnumMember: "EnumMember ",
                        Constant: "Constant ",
                        Struct: "Struct ",
                        Event: "Event ",
                        Operator: "Operator ",
                        TypeParameter: "TypeParameter "
                    },
                    kindHlGroups: {
                        Text: "String",
                        Method: "Function",
                        Function: "Function",
                        Constructor: "Function",
                        Field: "Identifier",
                        Variable: "Identifier",
                        Class: "Structure",
                        Interface: "Structure",
                        Module: "Function",
                        Property: "Identifier",
                        Unit: "Identifier",
                        Value: "String",
                        Enum: "Structure",
                        Keyword: "Identifier",
                        Snippet: "Structure",
                        Color: "Structure",
                        File: "Structure",
                        Reference: "Function",
                        Folder: "Structure",
                        EnumMember: "Structure",
                        Constant: "String",
                        Struct: "Structure",
                        Event: "Function",
                        Operator: "Identifier",
                        TypeParameter: "Identifier",
                    }
                },
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
                    maxItems: 20,
                    sorters: ["sorter_lsp-kind"],
                    forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
                    converters: ["converter_fuzzy", "converter_kind_labels"],
                    dup: "keep",
                },
                file: {
                    mark: "F",
                    isVolatile: true,
                    minAutoCompleteLength: 1000,
                    forceCompletionPattern: "\\S/\\S*",
                },
                cmdline_history: {
                    mark: "history",
                    sorters: [],
                },
                shell_native: {
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
                shell_native: {
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
                "shell_native",
                "shell_history",
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
