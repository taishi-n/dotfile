#!/usr/bin/env perl
$latex          = 'uplatex -synctex=1 -halt-on-error';
$latex_silent   = 'uplatex -synctex=1 -halt-on-error -interaction=batchmode';
$bibtex         = 'upbibtex';
$biber          = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf         = 'dvipdfmx -V 7 %O -o %D %S';
$makeindex      = 'mendex %O -o %D %S';
$max_repeat     = 5;
$pdf_mode       = 3;
$pvc_view_file_via_temporary = 0;
$pdf_previewer  = "open -ga /Applications/Skim.app";
$clean_ext = 'synctex.gz synctex.gz(busy) bbl fdb_latexmk snm nav';
$preview_mode = 1;
