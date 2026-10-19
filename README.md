# template-pandoc
Full featured Pandoc template for Entangled

To use this template, make sure Entangled (`pip install entangled-cli`) and [Pandoc](https://pandoc.org/) are installed:

```bash
entangled new pandoc my-new-entangled-project
# ... answer the few questions ...
cd my-new-entangled-project
entangled tangle
brei weave
```

The rendered web-page should be in `docs/site`.

## Testing

To develop the template or perform tests, clone the repository in the same place as `entangled.py` and `copier copy` the template to a `test` folder,

```bash
uv init --bare
uv add --dev --editable ../entangled.py
copier copy . test
```
