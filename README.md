# Squidtree

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

- Build the docker image: `. ./.env; docker build --build-arg SECRET_KEY_BASE -t squidtree .`
- Run the docker image: `docker run -p 4000:4000 -v ~/Documents/notes/zk:/app/priv/note_contents:ro -v ~/Documents/notes/publications:/app/priv/blog_contents:ro -it $(docker images --format "{{.ID}} {{.CreatedAt}}" | sort -rk 2 | awk 'NR==1{print $1}')`
- Verify the image by visiting <http://localhost:4000>
- Export the image for import: `docker save squidtree:latest | gzip > squidtree.tar.gz`

## TODO

### Next Up

- Add a Now page
- Verify all citations are correct
- Fix 404 = 500 error
- Meta title and h1 need markdown character replacement, but not HTML

### Midterm

- Display random notes on index
- Create cache reset endpoint
- Add search feature
- Explain chosen color

### Longterm

- Allow localstorage edits on notes
- Add background variations incl date color
- Blog tags
- Add note link preview on hover
