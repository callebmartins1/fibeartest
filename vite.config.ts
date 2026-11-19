import { defineConfig, loadEnv } from "vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import tsConfigPaths from "vite-tsconfig-paths";
import { nitro } from "nitro/vite";

export default defineConfig(({ command, mode }) => {
  // Deixa as variáveis do .env (não só as VITE_*) disponíveis ao código de servidor via process.env.
  const env = loadEnv(mode, process.cwd(), "");
  for (const [key, value] of Object.entries(env)) {
    if (process.env[key] === undefined) process.env[key] = value;
  }

  return {
    resolve: {
      dedupe: [
        "react",
        "react-dom",
        "@tanstack/react-router",
        "@tanstack/react-start",
        "@tanstack/react-query",
      ],
    },
    plugins: [
      tsConfigPaths(),
      // Usa src/server.ts (nosso wrapper de erros de SSR) como entrada do servidor.
      tanstackStart({ server: { entry: "server" } }),
      // O preset do Nitro vem de NITRO_PRESET (definido no netlify.toml); sem ele, o Nitro detecta a plataforma sozinho.
      ...(command === "build" ? [nitro()] : []),
      // O plugin do React precisa vir depois do plugin do TanStack Start.
      viteReact(),
      tailwindcss(),
    ],
  };
});
