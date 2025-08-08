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
  devServer: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
    host: process.env.HOST || '0.0.0.0'
  },
  
  // Vite configuration for development server
  vite: {
    server: {
      port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
      host: process.env.HOST || '0.0.0.0'
    }
  },
  
  // CSS framework (optional - users can customize)
  css: [],
  
  // Modules (commonly used ones for TypeScript projects)
  modules: [
    '@nuxtjs/tailwindcss'
  ],
  
  // Auto-imports configuration
  imports: {
    autoImport: true
  }
})
EOF
    
    # Create a simple app.vue to replace the default one
    cat > app.vue << 'EOF'
<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
    <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
      <div class="mb-6">
        <img 
          src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nuxtjs/nuxtjs-original.svg" 
          alt="NuxtJS Logo" 
          class="w-16 h-16 mx-auto mb-4"
        >
        <h1 class="text-3xl font-bold text-gray-800 mb-2">
          Welcome to NuxtJS!
        </h1>
        <p class="text-gray-600">
          Your TypeScript-powered Nuxt application is ready to go.
        </p>
      </div>
      
      <div class="space-y-4">
        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <h2 class="text-lg font-semibold text-green-800 mb-2">
            ✨ Features Included
          </h2>
          <ul class="text-sm text-green-700 space-y-1">
            <li>• TypeScript support</li>
            <li>• Auto-imports</li>
            <li>• File-based routing</li>
            <li>• Hot reload</li>
            <li>• SSR/SSG ready</li>
          </ul>
        </div>
        
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h2 class="text-lg font-semibold text-blue-800 mb-2">
            🚀 Quick Start
          </h2>
          <div class="text-sm text-blue-700 space-y-1">
            <p>1. Edit <code class="bg-blue-100 px-1 rounded">app.vue</code></p>
            <p>2. Add pages in <code class="bg-blue-100 px-1 rounded">pages/</code></p>
            <p>3. Create components in <code class="bg-blue-100 px-1 rounded">components/</code></p>
          </div>
        </div>
        
        <button 
          @click="counter++"
          class="w-full bg-indigo-600 text-white py-2 px-4 rounded-lg hover:bg-indigo-700 transition-colors"
        >
          Click me! ({{ counter }})
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// This demonstrates TypeScript support in Nuxt 3
const counter = ref<number>(0)

// Meta configuration
useHead({
  title: 'NuxtJS + TypeScript Template',
  meta: [
    { name: 'description', content: 'A modern NuxtJS application with TypeScript support' }
  ]
})
</script>

<style scoped>
code {
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
}
</style>
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
    
    # Create additional directories that are commonly used
    mkdir -p components pages layouts composables server/api public assets
    
    # Create a simple example page
    cat > pages/index.vue << 'EOF'
<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-4xl font-bold mb-4">Home Page</h1>
    <p class="text-gray-600 mb-4">
      This is an example page. You can edit this file at <code>pages/index.vue</code>
    </p>
    <NuxtLink to="/about" class="text-blue-600 hover:underline">
      Go to About page
    </NuxtLink>
  </div>
</template>
EOF
    
    # Create an about page to demonstrate routing
    cat > pages/about.vue << 'EOF'
<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-4xl font-bold mb-4">About Page</h1>
    <p class="text-gray-600 mb-4">
      This demonstrates file-based routing in Nuxt.js
    </p>
    <NuxtLink to="/" class="text-blue-600 hover:underline">
      Back to Home
    </NuxtLink>
  </div>
</template>
EOF
    
    # Create an example composable
    cat > composables/useCounter.ts << 'EOF'
export const useCounter = () => {
  const count = ref(0)
  
  const increment = () => count.value++
  const decrement = () => count.value--
  const reset = () => count.value = 0
  
  return {
    count: readonly(count),
    increment,
    decrement,
    reset
  }
}
EOF
    
    # Create an example API route
    cat > server/api/hello.ts << 'EOF'
export default defineEventHandler(async (event) => {
  return {
    message: 'Hello from Nuxt API!',
    timestamp: new Date().toISOString()
  }
})
EOF
    
    # Install dependencies
    ${if packageManager == "npm" then "npm install"
      else if packageManager == "yarn" then "yarn install"
      else if packageManager == "pnpm" then "pnpm install"
      else if packageManager == "bun" then "bun install"
      else "npm install"}
    
    # Add TailwindCSS for styling (optional but makes the template more complete)
    ${if packageManager == "npm" then "npm install -D @nuxtjs/tailwindcss tailwindcss"
      else if packageManager == "yarn" then "yarn add -D @nuxtjs/tailwindcss tailwindcss"
      else if packageManager == "pnpm" then "pnpm add -D @nuxtjs/tailwindcss tailwindcss"
      else if packageManager == "bun" then "bun add -D @nuxtjs/tailwindcss tailwindcss"
      else "npm install -D @nuxtjs/tailwindcss tailwindcss"}
    
    cd ..
    mv "$WS_NAME" "$out"
  '';
}
