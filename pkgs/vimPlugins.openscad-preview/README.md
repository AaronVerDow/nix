# OpenSCAD Preview

Vim plugin to automatically open OpenSCAD when editing files. 

## Use

Edit a .scad file in vim and the file will be automatically opened in OpenSCAD. Add a comment containing `NOPREVIEW` to disable for specific files.

Set the envornment variable `OPENSCAD_EXECUTABLE` to specify a custom path to OpenSCAD.

Custom views of modules can be defined by commenting `PREVIEW` above a module. When this feature is used the overall file will no longer be opened. This allows previewing multiple parts at once.

OpenSCAD closes automatically when vim exits.
