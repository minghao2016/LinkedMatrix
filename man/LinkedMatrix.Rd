% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LinkedMatrix.R
\name{LinkedMatrix}
\alias{LinkedMatrix}
\title{Create an Empty, Prespecified LinkedMatrix Object.}
\usage{
LinkedMatrix(nrow, ncol, nNodes, linkedBy, nodeInitializer, ...)
}
\arguments{
\item{nrow}{The number of rows of the whole matrix.}

\item{ncol}{The number of columns of the whole matrix.}

\item{nNodes}{The number of nodes.}

\item{linkedBy}{Whether the matrix is linked by \code{columns} or \code{rows}.}

\item{nodeInitializer}{The name of a function or a function \code{(nodeIndex, nrow, ncol, ...)} where \code{nodeIndex} is the index of the node, \code{nrow} is a
partition of the total number of rows, \code{ncol} is a partition of the total
number of columns, and \code{...} are additional parameters passed into the
function. The function is expected to return a matrix-like object of
dimensions \code{nrow} and \code{ncol}. Pre-defined node initializers include
\code{matrixNodeInitializer} to initialize matrices and \code{ffNodeInitializer} to
initialize \code{ff} objects.}

\item{...}{Additional arguments passed into the \code{nodeInitializer} function.}
}
\value{
A \linkS4class{ColumnLinkedMatrix} object if \code{linkedBy} is \code{columns} or a
\linkS4class{RowLinkedMatrix} object if \code{linkedBy} is \code{rows}.
}
\description{
This function creates an empty \linkS4class{LinkedMatrix} object of a certain
size, a certain number of nodes, and certain types of nodes.
}
\examples{
# Create an empty 15x10 RowLinkedMatrix with 3 matrix nodes
m1 <- LinkedMatrix(nrow = 15, ncol = 10, nNodes = 3, linkedBy = "rows",
                   nodeInitializer = "matrixNodeInitializer")
dim(m1)
nNodes(m1)
all(sapply(m1, class) == "matrix")

# Create an empty 15x10 RowLinkedMatrix with 3 ff nodes
m2 <- LinkedMatrix(nrow = 15, ncol = 10, nNodes = 3, linkedBy = "rows",
                   nodeInitializer = "ffNodeInitializer", vmode = "byte")
dim(m2)
nNodes(m2)
all(sapply(m2, inherits, "ff_matrix"))

# Create an empty 15x10 RowLinkedMatrix with 3 big.matrix nodes
m3 <- LinkedMatrix(nrow = 15, ncol = 10, nNodes = 3, linkedBy = "rows",
                   nodeInitializer = function(nodeIndex, nrow, ncol, ...) {
                       bigmemory::big.matrix(nrow = nrow, ncol = ncol)
                   })
dim(m3)
nNodes(m3)
all(sapply(m3, class) == "big.matrix")
}
\seealso{
\link[=initialize,ColumnLinkedMatrix-method]{initialize()} to create a
\linkS4class{ColumnLinkedMatrix} or \linkS4class{RowLinkedMatrix} object from a list of
matrix-like objects.
}
