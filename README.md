# Squidtree

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Maintenance

- Upgrade hex `mix local.hex`
- Install deps `mix deps.get`
- Update deps `mix deps.update --all`
- Audit deps `mix deps.audit`

## Production

- Save the build to `./squidtree.tar.gz` via `bin/docker-build`
- Optionally run the docker image locally: `docker run -p 4000:4000 -v ~/Documents/notes/zk:/app/priv/note_contents:ro -v ~/Documents/notes/publications:/app/priv/blog_contents:ro -it $(docker images --format "{{.ID}} {{.CreatedAt}}" | sort -rk 2 | awk 'NR==1{print $1}')`
  - Verify the image by visiting <http://localhost:4000>
- Upload the image to Docker and start a new container with the correct locations mapped as above

## TODO

### Next Up

- Make the homepage read from a markdown file
- Verify all citations are correct
- Add updated dates to posts
- Add updated dates to notes?
- Allow any arbitrary folder structure in the blog posts folder?
- Sign up for newsletter?

### Longterm

- Display random notes on index
- Add search feature
- Explain chosen color
- Allow localstorage edits on notes
- Add background variations incl date color
- Blog tags
- Add note link preview on hover
