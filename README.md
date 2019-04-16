# NoSQL eBook
The current version of the book can be viewed on [GitHub Pages](https://dhbw-stginf16a.github.io/nosql-book/main.pdf).

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

Please note that only pull requests which result in the project building without errors or warnings will be accepted.
To test whether your project will work on continuous integration, install `Nix` and run `nix-build` in the project root.
If a folder `result` appears, you're good to go.

## Things to watch out for
- [ ] Please make sure that your chapter uses the correct file name.
- [ ] Don't define any labels without some part referring to your chapter.
- [ ] Don't use manually defined (in line) acronyms - use the glossaries package.
- [ ] Don't use absolute measures. Use `textwidth` and `textheight` instead.
- [ ] Don't manipulate any global preferences without a good reason.

## File names
- `1_introduction.tex` (Chapter)
- `2_0_key_value.tex` (Chapter)
- `2_1_hazelcast.tex` (Section)
- `2_2_redis.tex` (Section)
- `2_3_riak.tex` (Section)
- `3_0_column_oriented.tex` (Chapter)
- `3_1_cassandra.tex` (Section)
- `4_0_document_oriented.tex` (Chapter)
- `4_1_couchbase.tex` (Section)
- `4_2_rethink_db.tex` (Section)
- `5_0_graph_db.tex` (Chapter)
- `5_1_neo4j.tex` (Section)
- `6_conclusion.tex` (Chapter)
