import {
    type ContextBuilder,
    type ExtOptions,
    type Plugin,
} from "jsr:@shougo/dpp-vim@~4.1.0/types";
import {
    BaseConfig,
    type ConfigReturn,
    type MultipleHook,
} from "jsr:@shougo/dpp-vim@~4.1.0/config";
import { Protocol } from "jsr:@shougo/dpp-vim@~4.1.0/protocol";
import { mergeFtplugins } from "jsr:@shougo/dpp-vim@~4.1.0/utils";
import { globals } from "jsr:@denops/std/variable";

import type {
    Ext as TomlExt,
    Params as TomlParams,
} from "jsr:@shougo/dpp-ext-toml@~1.3.0";
import type {
    Ext as LazyExt,
    LazyMakeStateResult,
    Params as LazyParams,
} from "jsr:@shougo/dpp-ext-lazy@~1.5.0";

import type { Denops } from "jsr:@denops/std@~7.4.0";
import * as fn from "jsr:@denops/std@~7.4.0/function";

import { walk } from "jsr:@std/fs@~1.0.0/walk";
import { expandGlob } from "jsr:@std/fs@~1.0.0/expand-glob";

export class Config extends BaseConfig {
    override async config(args: {
        denops: Denops;
        contextBuilder: ContextBuilder;
        basePath: string;
    }): Promise<ConfigReturn> {
        const hubsite = await globals.get(args.denops, "dpp_hubsite");
        args.contextBuilder.setGlobal({
            extParams: {
                installer: {
                    checkDiff: true,
                    logFilePath: "$DPP_INSTALLER_LOG",
                    githubAPIToken: Deno.env.get("GITHUB_API_TOKEN"),
                },
            },
            protocolParams: {
                git: {
                    defaultHubSite: `${hubsite || "github.com"}`,
                },
            },
            protocols: ["git"],
        });

        const [context, options] = await args.contextBuilder.get(args.denops);
        const protocols = await args.denops.dispatcher.getProtocols() as Record<
            string,
            Protocol
        >;

        const recordPlugins: Record<string, Plugin> = {};
        const ftplugins: Record<string, string> = {};
        const hooksFiles: string[] = [];
        let multipleHooks: MultipleHook[] = [];

        const [tomlExt, tomlOptions, tomlParams]: [
            TomlExt | undefined,
            ExtOptions,
            TomlParams,
        ] = await args.denops.dispatcher.getExt(
            "toml",
        ) as [TomlExt | undefined, ExtOptions, TomlParams];
        if (tomlExt) {
            const action = tomlExt.actions.load;

            const tomlPromises = [
                { path: "$BASE_DIR/dpp_ext/dpp/dpp.toml", lazy: false },
                { path: "$BASE_DIR/dpp_ext/merge.toml", lazy: false },
                { path: "$BASE_DIR/dpp_ext/ddc/ddc.toml", lazy: true },
                { path: "$BASE_DIR/dpp_ext/denops.toml", lazy: true },
                { path: "$BASE_DIR/dpp_ext/ddu/ddu.toml", lazy: true },
                { path: "$BASE_DIR/dpp_ext/lazy.toml", lazy: true },
                { path: "$BASE_DIR/dpp_ext/nvim-lsp.toml", lazy: true },
            ].map((tomlFile) =>
                  action.callback({
                      denops: args.denops,
                      context,
                      options,
                      protocols,
                      extOptions: tomlOptions,
                      extParams: tomlParams,
                      actionParams: {
                          path: tomlFile.path,
                          options: {
                              lazy: tomlFile.lazy,
                          },
                      },
                  })
                 );

                 const tomls = await Promise.all(tomlPromises);

                 // Merge toml results
                 for (const toml of tomls) {
                     for (const plugin of toml.plugins ?? []) {
                         recordPlugins[plugin.name] = plugin;
                     }

                     if (toml.ftplugins) {
                         mergeFtplugins(ftplugins, toml.ftplugins);
                     }

                     if (toml.multiple_hooks) {
                         multipleHooks = multipleHooks.concat(toml.multiple_hooks);
                     }

                     if (toml.hooks_file) {
                         hooksFiles.push(toml.hooks_file);
                     }
                 }
        }

        const [lazyExt, lazyOptions, lazyParams]: [
            LazyExt | undefined,
            ExtOptions,
            LazyParams,
        ] = await args.denops.dispatcher.getExt(
            "lazy",
        ) as [LazyExt | undefined, ExtOptions, PackspecParams];
        let lazyResult: LazyMakeStateResult | undefined = undefined;
        if (lazyExt) {
            const action = lazyExt.actions.makeState;

            lazyResult = await action.callback({
                denops: args.denops,
                context,
                options,
                protocols,
                extOptions: lazyOptions,
                extParams: lazyParams,
                actionParams: {
                    plugins: Object.values(recordPlugins),
                },
            });
        }

        const checkFiles = [];
        const basedir = await fn.getenv(args.denops, "BASE_DIR");
        for await (const file of walk(
            basedir,
            { exts: ['.ts', '.lua', '.toml', '.vim'] }
        )) {
            checkFiles.push(file.path);
        }

        return {
            checkFiles,
            ftplugins,
            hooksFiles,
            multipleHooks,
            plugins: lazyResult?.plugins ?? [],
            stateLines: lazyResult?.stateLines ?? [],
        };
    }
}
