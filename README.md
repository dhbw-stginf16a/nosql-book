# NoSQL eBook
The current version of the book can be viewed at [GitHub Pages](https://dhbw-stginf16a.github.io/nosql-book/main.pdf).

# How to contribute your chapter

First and foremost: You never contribute to this repository directly!
Push access to all branches is disabled and all changes need to be done via a pull request.

Getting started:

1. Fork this repository.
2. Create a file under `content/`. You can use `content/00_test.tex` as a template.
3. Load this file in `main.tex` (similar to how it's done with `content/00_test`).
4. Add your content to the created file and bibliographic entries to `bibliography.bib`.
5. Add new packages to `main.tex` on demand.
6. Create a pull request for incorporating your changes with the book.

Please note that only pull requests which result in the project building
without errors or warnings will be accepted. To test whether your project will
work on continuous integration, install [Nix](https://nixos.org/nix/) and run
`nix-build` in the project root. If a folder `result` appears, you're good to
go.

## Writing a chapter in Markdown
If you think LaTeX is too much overhead for your chapter you can write it in
markdown instead. Just use the extension `.md` instead in step 2. It will
automatically be converted to Tex before being merged with the rest of the book.
You can use `content/01_test.md` as an example.

The author of a chapter is responsible for making sure that the output of
`pandoc` (the program that converts Markdown to Tex) does not negatively affect
the rest of the book.
