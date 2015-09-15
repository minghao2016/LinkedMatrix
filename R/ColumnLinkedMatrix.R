#' An S4 class to represent a column-distributed \code{mmMatrix}.
#'
#' \code{ColumnLinkedMatrix} inherits from \code{\link{list}}. Each element of the list is
#' an \code{ff_matrix} object.
#'
#' @export ColumnLinkedMatrix
#' @exportClass ColumnLinkedMatrix
ColumnLinkedMatrix<-setClass('ColumnLinkedMatrix',contains='list')

#' @export
setMethod('initialize','ColumnLinkedMatrix',function(.Object,nrow=1,ncol=1,nChunks=NULL){
    if(is.null(nChunks)){
        chunkSize<-min(ncol,floor(.Machine$integer.max/nrow/1.2))
        nChunks<-ceiling(ncol/chunkSize)
    }else{
        chunkSize<-ceiling(ncol/nChunks)
        if(chunkSize*nrow >= .Machine$integer.max/1.2){
            stop('More chunks are needed')
        }
    }
    ffList<-list()
    end<-0
    for(i in 1:nChunks){
        ini<-end+1
        end<-min(ncol,ini+chunkSize-1)
        ffList[[i]]<-matrix(nrow=nrow,ncol=(end-ini+1))
    }
    .Object<-callNextMethod(.Object,ffList)
    return(.Object)
})


subset.ColumnLinkedMatrix<-function(x,i,j,drop){
    if(missing(i)){
        i<-1:nrow(x)
    }
    if(missing(j)){
        j<-1:ncol(x)
    }
    if(class(i)=='logical'){
        i<-which(i)
    }else if(class(i)=='character'){
        i<-sapply(i,function(name){
            which(rownames(x)==name)
        },USE.NAMES=FALSE)
    }
    if(class(j)=='logical'){
        j<-which(j)
    }else if(class(j)=='character'){
        j<-sapply(j,function(name){
            which(colnames(x)==name)
        },USE.NAMES=FALSE)
    }
    n<-length(i)
    p<-length(j)
    originalOrder<-(1:p)[order(j)]
    sortedColumns<-sort(j)

    dimX<-dim(x)
    if( p>dimX[2] | n>dimX[1] ){
        stop('Either the number of columns or number of rows requested exceed the number of rows or columns in x, try dim(x)...')
    }

    Z<-matrix(nrow=n,ncol=p,NA)
    colnames(Z)<-colnames(x)[j]
    rownames(Z)<-rownames(x)[i]

    INDEX<-index(x)[sortedColumns,,drop=FALSE]

    whatChunks<-unique(INDEX[,1])
    end<-0
    for(k in whatChunks){
        TMP<-matrix(data=INDEX[INDEX[,1]==k,],ncol=3)
        ini<-end+1
        end<-ini+nrow(TMP)-1
        Z[,ini:end]<-x[[k]][i,TMP[,3],drop=FALSE]
    }
    if(length(originalOrder)>1){
        Z[]<-Z[,originalOrder]
    }
    if(drop==TRUE&&(n==1||p==1)){
        # Revert drop.
        return(Z[,])
    }else{
        return(Z)
    }
}

#' @export
setMethod("[",signature(x="ColumnLinkedMatrix"),subset.ColumnLinkedMatrix)


replace.ColumnLinkedMatrix<-function(x,i,j,...,value){
    if(missing(i)){
        i<-1:nrow(x)
    }
    if(missing(j)){
        j<-1:ncol(x)
    }
    Z<-matrix(nrow=length(i),ncol=length(j),data=value)
    CHUNKS<-chunks(x)
    ellipsis<-list(...)
    if(is.null(ellipsis$index)){
        index<-index(x)
    }else{
        index<-ellipsis$index
    }
    for(k in 1:nrow(CHUNKS)){
        col_z<-(j>=CHUNKS[k,2])&(j<=CHUNKS[k,3])
        colLocal<-index[j[col_z],3]
        x[[k]][i,colLocal]<-Z[,col_z]
    }
    return(x)
}

#' @export
setReplaceMethod("[",signature(x="ColumnLinkedMatrix"),replace.ColumnLinkedMatrix)


#' @export
dim.ColumnLinkedMatrix<-function(x){
    n<-nrow(x[[1]])
    p<-0
    for(i in 1:length(x)){
        p<-p+ncol(x[[i]])
    }
    return(c(n,p))
}


# This function looks like an S3 method, but isn't one.
rownames.ColumnLinkedMatrix<-function(x){
    out<-rownames(x[[1]])
    return(out)
}

# This function looks like an S3 method, but isn't one.
colnames.ColumnLinkedMatrix<-function(x){
    out<-NULL
    if(!is.null(colnames(x[[1]]))){
        p<-dim(x)[2]
        out<-rep('',p)
        TMP<-chunks(x)
        for(i in 1:nrow(TMP)){
            out[(TMP[i,2]:TMP[i,3])]<-colnames(x[[i]])
        }
    }
    return(out)
}

#' @export
dimnames.ColumnLinkedMatrix<-function(x){
    list(rownames.ColumnLinkedMatrix(x),colnames.ColumnLinkedMatrix(x))
}


# This function looks like an S3 method, but isn't one.
`rownames<-.ColumnLinkedMatrix`<-function(x,value){
    for(i in 1:length(x)){
        rownames(x[[i]])<-value
    }
    return(x)
}

# This function looks like an S3 method, but isn't one.
`colnames<-.ColumnLinkedMatrix`<-function(x,value){
    TMP<-chunks(x)
    for(i in 1:nrow(TMP)){
        colnames(x[[i]])<-value[(TMP[i,2]:TMP[i,3])]
    }
    return(x)
}

#' @export
`dimnames<-.ColumnLinkedMatrix`<-function(x,value){
    d<-dim(x)
    rownames<-value[[1]]
    colnames<-value[[2]]
    if(!is.list(value)||length(value)!=2||!(is.null(rownames)||length(rownames)==d[1])||!(is.null(colnames)||length(colnames)==d[2])){
        stop('invalid dimnames')
    }
    x<-`rownames<-.ColumnLinkedMatrix`(x,rownames)
    x<-`colnames<-.ColumnLinkedMatrix`(x,colnames)
    return(x)
}


#' @export
as.matrix.ColumnLinkedMatrix<-function(x,...){
    x[,,drop=FALSE]
}


#' @export
chunks.ColumnLinkedMatrix<-function(x){
    n<-length(x)
    OUT<-matrix(nrow=n,ncol=3,NA)
    colnames(OUT)<-c('chunk','col.ini','col.end')
    end<-0
    for(i in 1:n){
        ini<-end+1
        end<-ini+ncol(x[[i]])-1
        OUT[i,]<-c(i,ini,end)
    }
    return(OUT)
}


index.ColumnLinkedMatrix<-function(x){
    CHUNKS<-chunks(x)
    nColIndex<-CHUNKS[nrow(CHUNKS),3]
    INDEX<-matrix(nrow=nColIndex,ncol=3)
    colnames(INDEX)<-c('chunk','col.global','col.local')
    INDEX[,2]<-1:nColIndex
    end<-0
    for(i in 1:nrow(CHUNKS)){
        nColChunk<-CHUNKS[i,3]-CHUNKS[i,2]+1
        ini<-end+1
        end<-ini+nColChunk-1
        INDEX[ini:end,1]<-i
        INDEX[ini:end,3]<-1:nColChunk
    }
    return(INDEX)
}