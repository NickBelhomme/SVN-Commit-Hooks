#!/usr/bin/php
<?php
$repos = $argv[1];
$txn = $argv[2];

// Check message has at least 10 Chars ...
exec('svnlook info ' . $repos . ' -t ' . $txn, $info);
$author = $info[0];
$time = $info[1];
$change_size = $info[2];
$message = array_slice($info, 3);
$message = implode("\n", $message);
$pattern = '/^(\[BUGFIX\]|\[REFACTOR\]|\[FEATURE\]|\[TASK\]|\[CONF\])(\[\!{3}\])?.{10,}([^\n]+\n+)*((issue|resolves): #\d+\n)?build: #\d+/';
if (!preg_match($pattern, $message)) {
    fwrite(
        STDERR,
        'Your commit has been blocked because you did not respect the commit message format'
        .PHP_EOL
        .'Please write a log message in the following format'
        .PHP_EOL
        .$pattern
        .PHP_EOL
        .'Rejected Message:'
        .PHP_EOL
        .$message
    );
    exit(1);
}
exit(0);
