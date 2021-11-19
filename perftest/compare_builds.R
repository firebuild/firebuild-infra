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
    print(paste("Versions have different run counts, cutting last runs from the shorter set:",
                shorter, "using only the first", dim(bt1)[1], "runs"))
}

if (!all(names1[1:dim(bt1)[1]] == names2[1:dim(bt2)[1]])) {
    stop("ERROR: Mismatched tests are compared", call.=FALSE)
}

print(paste("Time % increase in", args[3], "vs.", args[2]))
for(i in c(0, 1, 2)) {
    start_col <- 1 + i * 3
    end_col <- start_col + 2
    print(summary(100 * (bt2[, start_col:end_col] - bt1[, start_col:end_col]) / bt1[, start_col:end_col]))
}

print(paste("Cache size % increase in", args[3], "vs.", args[2]))
start_col <- 10
end_col <- 11
print(summary(100 * (bt2[, start_col:end_col] - bt1[, start_col:end_col]) / bt1[, start_col:end_col]))