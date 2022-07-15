# Pytorch Glow Github Action

Use glow (https://github.com/pytorch/glow) deep learning compiler in a Docker container inside you Github workflows.

## Inputs

## `command`

**Required** Command to be executed in container with glow installed.

## Example usage

```yaml
uses: zaitra/pytorch-glow-action@v0.1.2
with:
    command: |
        /root/dev/Build_Debug/bin/model-compiler ...
```