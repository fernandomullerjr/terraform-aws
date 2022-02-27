

# Aula 9. Entendendo o Terraform CLI


## Utilizando o Help

terraform -h

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ terraform -h
Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Experimental support for module integration testing
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$
~~~


## Estrutura do comando

Usage: terraform [global options] <subcommand> [args]




## Como usar um comando especifico

- O help do Terraform auxilia na utilização de comandos especificos.
- Basta passar o paramêtro "-h" ao final do comando.

- Exemplo:

terraform init -h

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ terraform init -h
Usage: terraform [global options] init [options]

  Initialize a new or existing Terraform working directory by creating
  initial files, loading any remote state, downloading modules, etc.

  This is the first command that should be run for any new or existing
  Terraform configuration per machine. This sets up all the local data
  necessary to run Terraform that is typically not committed to version
  control.

  This command is always safe to run multiple times. Though subsequent runs
  may give errors, this command will never delete your configuration or
  state. Even so, if you have important information, please back it up prior
  to running this command, just in case.

Options:

  -backend=false          Disable backend or Terraform Cloud initialization for
                          this configuration and use what what was previously
                          initialized instead.

                          aliases: -cloud=false

  -backend-config=path    Configuration to be merged with what is in the
                          configuration file's 'backend' block. This can be
                          either a path to an HCL file with key/value
                          assignments (same format as terraform.tfvars) or a
                          'key=value' format, and can be specified multiple
                          times. The backend type must be in the configuration
                          itself.

  -force-copy             Suppress prompts about copying state data when
                          initializating a new state backend. This is
                          equivalent to providing a "yes" to all confirmation
                          prompts.

  -from-module=SOURCE     Copy the contents of the given module into the target
                          directory before initialization.

  -get=false              Disable downloading modules for this configuration.

  -input=false            Disable interactive prompts. Note that some actions may
                          require interactive prompts and will error if input is
                          disabled.

  -lock=false             Don't hold a state lock during backend migration.
                          This is dangerous if others might concurrently run
                          commands against the same workspace.

  -lock-timeout=0s        Duration to retry a state lock.

  -no-color               If specified, output won't contain any color.

  -plugin-dir             Directory containing plugin binaries. This overrides all
                          default search paths for plugins, and prevents the
                          automatic installation of plugins. This flag can be used
                          multiple times.

  -reconfigure            Reconfigure a backend, ignoring any saved
                          configuration.

  -migrate-state          Reconfigure a backend, and attempt to migrate any
                          existing state.

  -upgrade                Install the latest module and provider versions
                          allowed within configured constraints, overriding the
                          default behavior of selecting exactly the version
                          recorded in the dependency lockfile.

  -lockfile=MODE          Set a dependency lockfile mode.
                          Currently only "readonly" is valid.

  -ignore-remote-version  A rare option used for Terraform Cloud and the remote backend
                          only. Set this to ignore checking that the local and remote
                          Terraform versions use compatible state representations, making
                          an operation proceed even when there is a potential mismatch.
                          See the documentation on configuring Terraform with
                          Terraform Cloud for more information.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$
~~~




terraform plan -h

~~~bash
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$ terraform plan -h
Usage: terraform [global options] plan [options]

  Generates a speculative execution plan, showing what actions Terraform
  would take to apply the current configuration. This command will not
  actually perform the planned actions.

  You can optionally save the plan to a file, which you can then pass to
  the "apply" command to perform exactly the actions described in the plan.

Plan Customization Options:

  The following options customize how Terraform will produce its plan. You
  can also use these options when you run "terraform apply" without passing
  it a saved plan, in order to plan and apply in a single command.

  -destroy            Select the "destroy" planning mode, which creates a plan
                      to destroy all objects currently managed by this
                      Terraform configuration instead of the usual behavior.

  -refresh-only       Select the "refresh only" planning mode, which checks
                      whether remote objects still match the outcome of the
                      most recent Terraform apply but does not propose any
                      actions to undo any changes made outside of Terraform.

  -refresh=false      Skip checking for external changes to remote objects
                      while creating the plan. This can potentially make
                      planning faster, but at the expense of possibly planning
                      against a stale record of the remote system state.

  -replace=resource   Force replacement of a particular resource instance using
                      its resource address. If the plan would've normally
                      produced an update or no-op action for this instance,
                      Terraform will plan to replace it instead.

  -target=resource    Limit the planning operation to only the given module,
                      resource, or resource instance and all of its
                      dependencies. You can use this option multiple times to
                      include more than one object. This is for exceptional
                      use only.

  -var 'foo=bar'      Set a value for one of the input variables in the root
                      module of the configuration. Use this option more than
                      once to set more than one variable.

  -var-file=filename  Load variable values from the given file, in addition
                      to the default files terraform.tfvars and *.auto.tfvars.
                      Use this option more than once to include more than one
                      variables file.

Other Options:

  -compact-warnings   If Terraform produces any warnings that are not
                      accompanied by errors, shows them in a more compact form
                      that includes only the summary messages.

  -detailed-exitcode  Return detailed exit codes when the command exits. This
                      will change the meaning of exit codes to:
                      0 - Succeeded, diff is empty (no changes)
                      1 - Errored
                      2 - Succeeded, there is a diff

  -input=true         Ask for input for variables if not directly set.

  -lock=false         Don't hold a state lock during the operation. This is
                      dangerous if others might concurrently run commands
                      against the same workspace.

  -lock-timeout=0s    Duration to retry a state lock.

  -no-color           If specified, output won't contain any color.

  -out=path           Write a plan file to the given path. This can be used as
                      input to the "apply" command.

  -parallelism=n      Limit the number of concurrent operations. Defaults to 10.

  -state=statefile    A legacy option used for the local backend only. See the
                      local backend's documentation for more information.
fernando@debian10x64:~/cursos/terraform-udemy-cleber/terraform-aws$
~~~