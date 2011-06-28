#!/usr/bin/php
<?php
$repos = $argv[1];
$txn = $argv[2];

// Check message has at least 10 Chars ...
exec('svnlook info ' . $repos . ' -t ' . $txn, $info);
$author = $info[0];
$time = $info[1];
$changeSize = $info[2];
$message = '';
$infoCount = count($info);
for ( $i=3; $i<$infoCount; ++$i ) {
    $message .= $info[$i];
}

$pattern = '/^(\[BUGFIX\]|\[FEATURE\]|\[TASK\])+ issue #\d+/';

if (!preg_match($pattern, $message)) {
    fwrite(
        STDERR,
        'Your commit has been blocked because you did not respect the commit message format'
        .PHP_EOL
        .'Please write a log message in the following format'
        .PHP_EOL
        .$pattern
        .PHP_EOL
        .'original message as follows:'
        .PHP_EOL
        .$message
    );
    exit(1);
}