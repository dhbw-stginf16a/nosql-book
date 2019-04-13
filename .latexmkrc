@default_files = ("main.tex");

$pdf_mode = 1;
$dvi_mode = 0;
$ps_mode = 0;

$recorder = 1;

$latex = 'latex  %O  --shell-escape %S';
$pdflatex = 'pdflatex  %O  --shell-escape %S';

$bibtex_use = 2; # remove .bbl from output on clean
@generated_exts = qw(fls lof lot out toc ist lol run.xml synctex.gz);
