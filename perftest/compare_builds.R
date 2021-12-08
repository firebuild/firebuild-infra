#!/usr/bin/Rscript

# compare two build's performance test runs pairwise

args <- commandArgs(TRUE)
if (length(args) != 3) {
    stop("Usage: compare_builds.R <buildtimes.csv> <version 1> <version 2>", call.=FALSE)
}

buildtimes <- read.csv(args[1], header=FALSE, col.names=c("start", "end", "version", "ts", "name", "cmd", "status", "real1", "user1", "sys1", "real2", "user2", "sys2", "real3", "user3", "sys3", "cache.size.1", "cache.size.2"))

buildtimes[buildtimes$status != 0, 8:18]  <- NA

bt1 <- buildtimes[buildtimes$version == args[2], 8:18]
names1 <- buildtimes[buildtimes$version == args[2], 5]
bt2 <- buildtimes[buildtimes$version == args[3], 8:18]
names2 <- buildtimes[buildtimes$version == args[3], 5]

if (!all(dim(bt1) == dim(bt2))) {
    if (dim(bt1)[1] < dim(bt2)[1]) {
        shorter = args[2]
        bt2 <- bt2[1:dim(bt1)[1],]
    } else {
        shorter = args[3]
        bt1 <- bt1[1:dim(bt2)[1],]
    }
    message(paste("Versions have different run counts, omitting last runs from the longer set."))
}

if (!all(names1[1:dim(bt1)[1]] == names2[1:dim(bt2)[1]])) {
    stop("ERROR: Mismatched tests are compared", call.=FALSE)
}

message(paste("Time % increase from", args[2], "to", args[3], "\ncomparing", dim(bt1)[1], "run pairs."))
for(i in c(0, 1, 2)) {
    start_col <- 1 + i * 3
    end_col <- start_col + 2
    message("")
    print(summary(100 * (bt2[, start_col:end_col] - bt1[, start_col:end_col]) / bt1[, start_col:end_col]))
    totals <- data.frame(t(100 * (colSums(bt2[, start_col:end_col], na.rm = TRUE) - colSums(bt1[, start_col:end_col], na.rm = TRUE)) / colSums(bt1[, start_col:end_col], na.rm = TRUE)))
    row.names(totals) <- c(" Sum. incr.:")
    message("")
    print(totals, justify="")
}

message("")
message(paste("Cache size % increase from", args[2], "to", args[3]))
start_col <- 10
end_col <- 11
print(summary(100 * (bt2[, start_col:end_col] - bt1[, start_col:end_col]) / bt1[, start_col:end_col]))
totals <- data.frame(t((100 * (colSums(bt2[, start_col:end_col], na.rm = TRUE) - colSums(bt1[, start_col:end_col], na.rm = TRUE)) / colSums(bt1[, start_col:end_col], na.rm = TRUE))))
row.names(totals) <- c(" Sum. incr.:")
message("")
print(totals)

message("")
message(paste("Total time with firebuild (%) in", args[3], ":"))
sys <- colSums(bt2[, 4:6], na.rm = TRUE)
use <- colSums(bt2[, 7:9], na.rm = TRUE)
sums <- c(colSums(bt2[, 1:3], na.rm = TRUE),
          colSums(bt2[, 4:6], na.rm = TRUE),
          colSums(bt2[, 7:9], na.rm = TRUE))
dim(sums) <- c(3,3)
sums  <- rbind(sums[,], sums[2,] + sums[3,])
overheads <- (sums[,2:3]) / sums[,1] * 100
colnames(overheads) <- c("first run", "second run")
rownames(overheads) <- c("real", "user","sys", "user+sys")
print(overheads)
