% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compressr.R
\name{is_tgz}
\alias{is_tgz}
\title{Test if a file is tarred and gzip (.tar, .gz or tgz)}
\usage{
is_tgz(filename)
}
\arguments{
\item{filename}{the fully qualified name of the file to test}
}
\value{
logical, TRUE if the input is likely gzipped
}
\description{
We guess that the first four bytes tell us enough to know what kind of zip
file we have.  For more information see 
\url{http://pank.org/blog/archives/000202.html}
}
\details{
A tgz's first four bytes will be [1f, 8b, 08, 00]
}
