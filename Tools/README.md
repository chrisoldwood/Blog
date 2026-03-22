# Tools

The scripts in this folder do most of the heavy lifting. My blog posts are
written using [Open Live Writer](https://openlivewriter.com/) with the occasional
one edited directly using Blogger which means that most, but not _all_ posts use
the same HTML markup. Consequently the scripts have needed tweaking a number of
times to adapt to the markup, but even then some seemingly random tags have
appeared from Writer or Blogger so I still need to manually tweak the posts here
and there once they stabilise.

### Scripts

Here is a rundown of the scripts in this folder:

* `ArchivePosts` -- top-level script for archiving posts across a date range. 
* `BlogPostToMarkdown` -- transforms a single blog post from HTML to Markdown.
* `GenerateToC` -- generates the table of contents for a range of archived posts.
* `ListBlogPosts` -- generates the `Posts` data structure.
* `Posts` -- mappings for each post from Blogger to the archive.

The scripts are regression tested by running them over previous posts and seeing
what's accidentally changed, that's why they all take a date range. The reason
for this is so that I can keep going back and pulling more metadata or content 
from the original posts as fidelity improves over time. The priority has been to
get the basic text archived and worry about images and formatting later.

The Blogger generated URL hasn't always been very good so the mappings in the
`Posts` script allow me to correct that. Also the URL date doesn't always match
the published date so that's also been corrected in the mappings when necessary.

The general process so far has been this:

1. Use `ListBlogPosts` to generate a small list of blog post URLs for archiving.
2. Add them to `Posts`, providing any necessary transformations. 
3. Run `ArchivePosts` to generate the Markdown versions of the posts.
4. Tweak `BlogPostToMarkdown` to account for any _new_ weirdness in the HTML.
5. Run `ArchivePosts` over an older date range to check for regressions.
6. Run `GenerateToC` and paste the output into the top-level `README.md`.
7. Commit the script changes and newly archived posts separately.
