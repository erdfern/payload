{ pkgs, lib, config, inputs, ... }:
let
  devDeps = with pkgs; [
    # vscode-langservers-extracted # OLD!!
    vscode-css-languageserver
    vscode-json-languageserver
    nodePackages.typescript-language-server
    # also need prettier-plugin-astro as dev dependency for fmt!
    # astro-language-server
    # also need prettier-plugin-svelte as dev dependency for fmt!
    # svelte-language-server
    tailwindcss-language-server
    # prettier
    prettierd

    # for cloudflare workers
    # wrangler
    # nodePackages.wrangler
    # for strapi
    nodePackages.pm2

    # stripe-cli
    stripe-cli-main

    # colmena
  ];
in
{

  dotenv.disableHint = true;
  # cachix.enable = true;

  overlays = [
    (final: prev: {
      stripe-cli-main = final.callPackage ./stripe-cli-main.nix { };
    })
  ];

  packages = [ ] ++ lib.optionals (!config.container.isBuilding) devDeps;

  # https://devenv.sh/languages/
  languages.javascript = {
    enable = true;
    # corepack.enable = true;
    npm.enable = true;
    pnpm.enable = true;
    bun.enable = true;
  };
  languages.typescript.enable = true;

  # https://devenv.sh/tasks/
  # tasks = {
  #   #   # "myproj:setup".exec = "mytool build";
  #   #   # "devenv:enterShell".after = [ "myproj:setup" ];
  #   "backend:install_deps" = {
  #     exec = "cd \"$DEVENV_ROOT\"/backend && pnpm install";
  #     before = [ "devenv:processes:payload" ];
  #   };
  # };

  # https://devenv.sh/processes
  # https://devenv.sh/tasks/#processes-as-tasks
  # process.manager.implementation = "process-compose";
  processes = {
    #   # NOTE need to be logged in! `stripe login`
    stripe-webhooks-redirect = {
      exec = "stripe listen --forward-to localhost:3000/api/stripe/webhooks";
      process-compose = {
        #     is_daemon = true;
        readiness_probe = {
          exec = {
            command = "pgrep -f \"stripe listen\"";
          };
          initial_delay_seconds = 2;
          period_seconds = 5;
          timeout_seconds = 5;
          success_threshold = 1;
          failure_threshold = 2;
        };
        # TODO this is incorrect
        # liveness_probe = {
        #   exec = (pkgs.writeShellScript "checkhealth_stripe_redirect" ''
        #     # Check if stripe listen process is running
        #     pgrep -f "stripe listen" > /dev/null
        #     if [ $? -ne 0 ]; then
        #       echo "stripe listen process not found."
        #       exit 1
        #     fi

        #     # Using -m 5 for max time, -s silent, -o /dev/null to discard output
        #     curl -m 5 -s -o /dev/null http://localhost:3000/api/stripe/webhooks
        #     CURL_STATUS=$?

        #     if [ $CURL_STATUS -ne 0 ]; then
        #       echo "Failed to connect to localhost:3000/api/stripe/webhooks (curl exit code: $CURL_STATUS)."
        #       exit 1
        #     fi
        #     exit 0
        #   '').outPath;
        #   # http_get = {
        #   #   scheme = "http";
        #   #   host = "127.0.0.1";
        #   #   port = 8000;
        #   #   path = "/health";
        #   # };
        #   initial_delay_seconds = 25;
        #   period_seconds = 25;
        #   timeout_seconds = 5;
        #   success_threshold = 1;
        #   failure_threshold = 5;
        # };
      };
    };
    payload = {
      exec = "cd templates/ecommerce && pnpm dev";
      process-compose = {
        depends_on.mongodb.condition = "process_started";
        # depends_on.stripe-webhooks-redirect.condition = "process_started";
        # depends_on.stripe-webhooks-redirect.condition = "process_healthy";
      };
    };
  };

  # https://devenv.sh/services/
  services = {
    mongodb = {
      enable = true;
      additionalArgs = [
        "--port"
        "27017"
        "--noauth"
      ];
    };
  };

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  # https://devenv.sh/basics/
  # enterShell = ''
  #   hello         # Run scripts directly
  #   git --version # Use packages
  # '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
