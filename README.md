LinkedMatrix
============

# Column-Linked and Row-Linked Matrices

Matrices implemented as collections of matrix-like nodes, linked by columns or rows.

## Classes & Methods

### Class `ColumnLinkedMatrix`

An S4 class to represent column-linked matrices, inherits from `list`.

#### Constructor

- `ColumnLinkedMatrix(...)` where `...` is a sequence of matrix-like objects of the same row-dimension. If no matrix-like objects are given, a single 1x1 node filled with `NA` is returned.

### Class `RowLinkedMatrix`

An S4 class to represent row-linked matrices, inherits from `list`.

#### Constructor

- `RowLinkedMatrix(...)` where `...` is a sequence of matrix-like objects of the same column-dimension. If no matrix-like objects are given, a single 1x1 node filled with `NA` is returned.

### Class `LinkedMatrix`

An S4 class union of `ColumnLinkedMatrix` and `RowLinkedMatrix`.

#### Methods

All methods described below are available on both `ColumnLinkedMatrix` and `RowLinkedMatrix` objects.

- `[` and `[<-` for subsetting and replacing matrix elements
- `dim(x)`, `nrow(x)`, `ncol(x)`
- `dimnames(x)`, `colnames(x)`, `rownames(x)`
- `colMeans(x)`, `colSums(x)`, `rowMeans(x)`, `rowSums(x)`
- `summary(x)`
- `apply(x, MARGIN, FUN)` with the same parameters and similar behavior than the `apply` function from the base package
- `as.matrix(x)` converts a `LinkedMatrix` object to a matrix (if small enough)
- `nodes(x)` returns the column or row indexes at which each node starts and ends
- `index(x)` maps each column or row index of a linked matrix to the column or row index of its corresponding node
- `length(x)` return the number of nodes
- `[[` and `[[<-` for subsetting and replacing nodes

## Installation

The `LinkedMatrix` package is not available on [CRAN](http://cran.r-project.org/) yet. However, it can be installed directly from GitHub using the [devtools](https://github.com/hadley/devtools) package.

1. Install `devtools` package: `install.packages('devtools')`
2. Load `devtools` package: `library(devtools)`
3. Install `LinkedMatrix` package from GitHub: `install_github('QuantGen/LinkedMatrix')`
4. Load `LinkedMatrix` package: `library(LinkedMatrix)`

Alternatively, you can download the most recent version as a bundle for [Windows](https://github.com/QuantGen/LinkedMatrix/archive/master.zip) or [Mac OS / Linux](https://github.com/QuantGen/LinkedMatrix/archive/master.tar.gz).
