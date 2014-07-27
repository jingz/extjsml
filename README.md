ExtJSML - ExtJS Markup Language based on YAML
===
### What is the ExtJSML ?
* An alternative to ExtJS Designer which using extended YAML to define GUI configuation
* With a library that simplify ExtJS's API and extend some components for ease of use.
* The compiler is written in Ruby script.
* The generator's output is the same as ExtJS Designer:
  1. UI script, store the ui configuration of ExtJS components.
  2. Event script, where event handling of the components located.

### Why ExtJSML ?
* Huge Overhead -> It reduces many configuration options which have to set in ExtJS Designer to make it just work
* Steep Learning Curve Of Layout Sysytem -> It auto apply layouts for each element appropriately 
* Easier to reposiiton the elements

> ! ExtJS is a [javascript library for cross-browser RIA](http://www.sencha.com/products/extjs3/)
    which is [licensed](http://www.sencha.com/products/extjs/license/)

> ***\*This tool is tested on ExtJS 4.2.1***

### Example Syntax and UI result
#### Basic Form
![Basic Syntax](https://raw.github.com/jingz/extjsml/master/examples/basic_syntax.png)
![Basic Form](https://raw.github.com/jingz/extjsml/master/examples/basic_form.png)

## Install
```shell
   gem install extjsml
```
## Usage
```shell
   $ extjsmlc filename.yaml
```
> output files:
> - filename.ui.js -> UI script
> - filename.js    -> event handling script

### Suppport / Contact : wsaryoo@gmail.com

<!--
### Interactive
start the server to provide output (js) from compling the code edited in the editor
### Commandline

*** include ui script before event handling script ***

### Support ExtJS components
* Form
  - fieldset
  - filefield
  - form
  - hidden
  - numberfield
  - checkbox
  - datefield
  - checkboxgroup
  - combo
  - compositefield
  - textarea
  - textfield
  - timefield
  - radio
  - radiogroup

* Grid
  - actioncolumn
  - booleancolumn
  - gridcolumn
  - runningcolumn
  - numbercolumn
  - templatecolumn
  - datecolumn
  - grid
  - paging
  - tbfill
  - tbseparator
  - editorgrid
  - # pivotgrid

* Container
  - container
  - panel
  - viewport
  - window
  - tabpanel

* Etc
  - button
  - toolbar

* Aliases
  - tab => tabpanel
  - div => container
  - gtext => gridcolumn
  - gboolean => booleancolumn
  - gnumber => numbercolumn
  - gdate => datecolumn
  - gtemplate => templatecolumn
  - gaction => actioncolumn
  - gcurrency => currencycolumn

### Extend API
...

-->
