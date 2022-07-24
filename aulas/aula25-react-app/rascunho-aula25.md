
# Aula 25. React app
Aula react

- Usar o projeto do Github:
<https://github.com/facebook/create-react-app>


- Quick Overview:
npx create-react-app my-app
cd my-app
npm start


- Exemplo editado
npx create-react-app website
cd website
npm start




- Erro devido a versão do node:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$ npx create-react-app website
npx: installed 67 in 10.837s
You are running Node 10.24.0.
Create React App requires Node 14 or higher.
Please update your version of Node.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$ cd website
-bash: cd: website: No such file or directory
~~~~


- Atualizado para 16
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs
node -v
~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$ node -v
v16.16.0
~~~~




- Erros durante o "npx create-react-app":

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$ npx create-react-app website
Need to install the following packages:
  create-react-app
Ok to proceed? (y) y
npm WARN deprecated tar@2.2.2: This version of tar is no longer supported, and will not receive security updates. Please upgrade asap.

Creating a new React app in /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app/website.

Installing packages. This might take a couple of minutes.
Installing react, react-dom, and react-scripts with cra-template...

npm ERR! code ECONNRESET
npm ERR! errno ECONNRESET
npm ERR! network Invalid response body while trying to fetch https://registry.npmjs.org/@typescript-eslint%2fexperimental-utils: aborted
npm ERR! network This is a problem related to network connectivity.
npm ERR! network In most cases you are behind a proxy or have bad network settings.
npm ERR! network
npm ERR! network If you are behind a proxy, please make sure that the
npm ERR! network 'proxy' config is set properly.  See: 'npm help config'

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/fernando/.npm/_logs/2022-07-23T16_30_11_539Z-debug-0.log

Aborting installation.
  npm install --no-audit --save --save-exact --loglevel error react react-dom react-scripts cra-template has failed.

Deleting generated file... package.json
Deleting website/ from /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app
Done.
npm notice
npm notice New minor version of npm available! 8.11.0 -> 8.15.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v8.15.0
npm notice Run npm install -g npm@8.15.0 to update!
npm notice
~~~~



- Mesmo com o usuário root, ocorrem erros de permissão:

~~~~bash
root@debian10x64:/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app# npx create-react-app website
/tmp/npx-39942900.sh: 1: /tmp/npx-39942900.sh: create-react-app: Permission denied
root@debian10x64:/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app#
~~~~




- Colocada permissão 777 no /tmp.
- Saí do usuário root e voltei ao usuário comum.

- Rodando novamente, criou o projeto react agora:

~~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$ npx create-react-app website

Creating a new React app in /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app/website.

Installing packages. This might take a couple of minutes.
Installing react, react-dom, and react-scripts with cra-template...


added 1392 packages in 2m

203 packages are looking for funding
  run `npm fund` for details

Installing template dependencies using npm...
npm WARN deprecated source-map-resolve@0.6.0: See https://github.com/lydell/source-map-resolve#deprecated

added 52 packages in 13s

203 packages are looking for funding
  run `npm fund` for details
Removing template package using npm...


removed 1 package, and audited 1444 packages in 3s

203 packages are looking for funding
  run `npm fund` for details

6 high severity vulnerabilities

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.

Success! Created website at /home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app/website
Inside that directory, you can run several commands:

  npm start
    Starts the development server.

  npm run build
    Bundles the app into static files for production.

  npm test
    Starts the test runner.

  npm run eject
    Removes this tool and copies build dependencies, configuration files
    and scripts into the app directory. If you do this, you can’t go back!

We suggest that you begin by typing:

  cd website
  npm start

Happy hacking!
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app$
~~~~




- Entrar na pasta e executar o start do projeto:
cd website
npm start

Compiled successfully!

You can now view website in the browser.

  Local:            http://localhost:3000
  On Your Network:  http://192.168.0.113:3000

Note that the development build is not optimized.
To create a production build, use npm run build.

webpack compiled successfully


- Site acessivel via:
http://192.168.0.113:3000/





- Editando o arquivo app.js:
/home/fernando/cursos/terraform-udemy-cleber/terraform-aws/aulas/aula25-react-app/website/src/App.js

Alterado o titulo
Alterado o link
Alterado o conteúdo


- Site modificado, acessando:
http://192.168.0.113:3000/


