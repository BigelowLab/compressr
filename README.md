# compressr

Simple wrapper functions for tar, untar, zip and unzip from the utils package.

## Requirements

 + [R v3.5+](https://www.r-project.org/)
 
 + [fs](https://CRAN.R-project.org/package=fs)
 
 ## Installation
 
 ```
 devtools::install_github("BigelowLab/compressr")
 
 ```
 
 ## Usage
 
 Make a dummy directory or two.
 
 ```
fs::dir_create("tarball")
x <- 1:1000
ok <- lapply(seq_len(3),
  function(i){
    cat(x*i, sep = "\n", file = paste0("tarball/file", i, ".txt"))
  })
fs::dir_copy("tarball", "zipped")
```
 
Compress a directory as gzipped tarball and another as zipped archive.
 
 ```
 compressr::pack('tarball', form = "gzip", filename = 'tarball.tar.gz')
 compressr::pack('zipped', form = "zip", filename = 'zipped.zip')
 ```
 
 Delete the original directories.
 
 ```
 fs::dir_delete(c("tarball", "zipped"))
 ```
 
 Unpack the archives.
 
 ```
 compressr::unpack("tarball.tar.gz")
 compressr::unpack("zipped.zip")
 ```