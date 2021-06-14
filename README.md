# Squidtree

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

- Build the docker image: `. ./.env; docker build --build-arg SECRET_KEY_BASE .`
- Run the docker image: `docker run -p 4000:4000 -v ~/Documents/notes/zk:/app/priv/note_contents:ro -v ~/Documents/notes/publications:/app/priv/blog_contents:ro -it $(docker images --format "{{.ID}} {{.CreatedAt}}" | sort -rk 2 | awk 'NR==1{print $1}')`
- Verify the image by visiting <http://localhost:4000>

## TODO

### Longterm

- Fix blog post title
- Get layout name from view into layout container
- Differentiate wikilinks in notes from "real" links in blog posts - size, color, etc
- Add background variations incl date color
