/*
 Copyright 2024 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/*
idx-template \
--output-dir /home/user/idx/nuxtjs-typescript-test \
-a '{ "packageManager": "npm" }' \
--workspace-name 'my-nuxt-app' \
/workspaces/community-templates/nuxtjs-typescript \
--failure-report
*/
{ pkgs, packageManager ? "npm", ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.nodePackages.pnpm
    pkgs.yarn
    pkgs.bun
  ];
  bootstrap = ''
    # Create NuxtJS project with TypeScript
    npx nuxi@latest init "$WS_NAME" --packageManager ${packageManager}
    
    # Setup IDX configuration
    mkdir -p "$WS_NAME/.idx/"
    cp -rf ${./dev.nix} "$WS_NAME/.idx/dev.nix"
    chmod -R +w "$WS_NAME"
    
    # Configure Nuxt for IDX environment
    cd "$WS_NAME"
    
    # Update nuxt.config.ts to use environment port and add TypeScript config
    cat > nuxt.config.ts << 'EOF'
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  
  // TypeScript configuration
  typescript: {
    strict: true,
    typeCheck: true
  },
  
  // Development server configuration for IDX
  nitro: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
    host: process.env.HOST || '0.0.0.0'
  },
  
  // CSS framework (optional - users can customize)
  css: [],
  
  // Modules (commonly used ones for TypeScript projects)
  modules: [],
  
  // Auto-imports configuration
  imports: {
    autoImport: true
  }
})
EOF
    
    # Create a comprehensive .gitignore for NuxtJS
    cat > .gitignore << 'EOF'
# Nuxt dev/build outputs
.output
.data
.nuxt
.nitro
.cache
dist

# Node dependencies
node_modules

# Logs
*.log

# Misc
.DS_Store
.fleet
.idea

# Local env files
.env
.env.*
!.env.example
EOF
    
    # Install dependencies
    ${if packageManager == "npm" then "npm install --package-lock-only --ignore-scripts"
      else if packageManager == "yarn" then "yarn install --ignore-scripts"
      else if packageManager == "pnpm" then "pnpm install --ignore-scripts"
      else if packageManager == "bun" then "bun install"
      else "npm install --package-lock-only --ignore-scripts"}
    
    cd ..
    mv "$WS_NAME" "$out"
  '';
}
