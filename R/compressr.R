#' Test if a given file is compressed by zip or tgz, gzip.
#' 
#' @family COMPRESSED
#' @export
#' @param filename the fully qualified name of the file to test
#' @return a character vector of 'zip', 'gzip' or "tgz", "bzip2",  "unknown"
test_compressed <- function(filename){
  if (missing(filename)) stop("filename is required")
  if (!fs::file_exists(filename)) stop("file not found:", filename)    
  ok <- is_zip(filename) ; if (ok) return("zip")
  ok <- is_tgz(filename) ; if (ok) return("tgz")
  ok <- is_gzip(filename) ; if (ok) return("gzip")
  ok <- is_bzip2(filename); if (ok) return("bzip2")
  return("unknown")
}

#' Test if a file is tarred and gzip (.tar, .gz or tgz)
#' 
#' We guess that the first four bytes tell us enough to know what kind of zip
#' file we have.  For more information see 
#' \url{http://pank.org/blog/archives/000202.html}
#' 
#' A tgz's first four bytes will be [1f, 8b, 08, 00]
#' 
#' @export
#' @param filename the fully qualified name of the file to test
#' @return logical, TRUE if the input is likely gzipped
is_tgz <- function(filename) {
  if (length(filename) > 1) return(sapply(filename, is_tgz))
  if (!fs::file_exists(filename)) stop("file not found:", filename)
  if (fs::dir_exists(filename)) return(FALSE)
  
  con <- file(filename, open = "rb")
  x = readBin(con, "raw", size = 1, n = 4, endian = "little")
  close(con)
  identical(rawToChar(x, multiple = TRUE), c("\037", "\x8b", "\b", ""))
}



#' Test if a file is gzipped
#' 
#' We guess that the first two bytes tell us enough to know what kind of zip
#' file we have.  For more information see 
#' \url{http://www.gzip.org/zlib/rfc-gzip.html#file-format}
#' and \url{https://www.ietf.org/rfc/rfc1952}
#' 
#' @export
#' @param filename the fully qualified name of the file to test
#' @return logical, TRUE if the input is likely gzipped
is_gzip <- function(filename){
  # ID1 (IDentification 1)
  # ID2 (IDentification 2)
  # These have the fixed values ID1 = 31 (0x1f, \037), ID2 = 139
  #   (0x8b, \213), to identify the file as being in gzip format.
  
  if (missing(filename)) stop("filename is required")
  if (!fs::file_exists(filename)) stop("file not found:", filename)
  
  if (length(filename) > 1) return(sapply(filename, is_gzip))
  if (fs::dir_exists(filename)) return(FALSE)
  
  con <- file(filename, open = "rb")
  x = readBin(con, "raw", size = 1, n = 2, endian = "little")
  close(con)
  identical(rawToChar(x, multiple = TRUE), c("\037", "\x8b"))
}


#' Test if a file is gzipped
#' 
#' We guess that the first two bytes tell us enough to know it is bzip2
#' file we have.  For more information see \url{https://en.wikipedia.org/wiki/Bzip2#File_format}
#' and \url{https://www.ietf.org/rfc/rfc1952}
#' 
#' @export
#' @param filename the fully qualified name of the file to test
#' @return logical, TRUE if the input is likely gzipped
is_bzip2 <- function(filename){
  # ID1 (IDentification 1)
  # ID2 (IDentification 2)
  # These have the fixed values ID1 = 31 (0x1f, \037), ID2 = 139
  #   (0x8b, \213), to identify the file as being in gzip format.
  
  if (missing(filename)) stop("filename is required")
  if (!fs::file_exists(filename)) stop("file not found:", filename)
  if (length(filename) > 1) return(sapply(filename, is_gzip))
  if (fs::dir_exists(filename)) return(FALSE)
  
  con <- file(filename, open = "rb")
  x = readBin(con, "raw", size = 1, n = 2, endian = "little")
  close(con)
  identical(rawToChar(x, multiple = TRUE), c("B", "Z"))
}

#' Test if a file is zipped.
#' 
#' @export
#' @param filename the fully qualified name of the file to test
#' @return logical, TRUE if the input is likely zipped
is_zip <- function(filename){
  
  if (missing(filename)) stop("filename is required")
  if (!fs::file_exists(filename)) stop("file not found:", filename)
  
  if (length(filename) > 1) return(sapply(filename, is_zip))
  if (fs::dir_exists(filename)) return(FALSE)
  
  
  con <- file(filename, open = "rb")
  x = readBin(con, "integer", size = 4, endian = "little")
  close(con)
  sprintf("0x%X", x) == "0x4034B50"  
}

#' Bundle and possibly compress a directory
#' 
#' @export
#' @param src character, path description for an exisiting directory
#' @param filename character, path description for trhe destination file
#' @param form character either 'gzip' or 'zip' to indicate compression used
#' @param compression character, see \code{\link[utils]{tar}} ignored if
#'        \code{form} is not "gzip"
#' @param ... arguments for \code{\link[utils]{tar}} or \code{\link[utils]{zip}}
#' @return numeric with 0 for success as returned by \code{\link[utils]{tar}}
pack <- function(src, 
                 form = c("gzip", "zip")[1], 
                 filename = paste0(basename(src), 
                                   ifelse(form[1] =='gzip',".tar.gz", '.zip')),
                 compression = "gzip",
                 ...){
  stopifnot(fs::dir_exists(src[1]))
  if (tolower(form[1] == 'gzip')){
    od <- setwd(dirname(src[1]))
    x <- utils::tar(filename[1], basename(src[1]), compression = compression[1], ...)
    setwd(od)
  } else {
    od <- setwd(dirname(src[1]))
    x <- try(utils::zip(filename[1], basename(src[1]),  ...))
    setwd(od)
  }
  x
}

#' Uncompress a packed directory
#' 
#' @export
#' @param filename character, path description to the file to unpack
#' @param exdir character the path where to extract the package
#' @param ... arguments for \code{\link[utils]{untar}} or \code{\link[utils]{unzip}}
#' @return varies as returned from \code{\link[utils]{untar}} or 
#'         \code{\link[utils]{unzip}}
unpack <- function(filename,
                   exdir = ".",
                   ...){
  stopifnot(fs::file_exists(filename[1]))
  ctype <- test_compressed(filename[1])
  if (ctype == 'zip'){
    x <- utils::unzip(filename,
                      exdir = exdir,
                      ...)
  } else if (ctype %in%  c('tgz', "gzip", "bzip2", "xz")){
    x <- utils::untar(filename,
                 exdir = exdir,
                 ...)
  } else {
    stop("compression type not handled: ", ctype)
  }
  x
}