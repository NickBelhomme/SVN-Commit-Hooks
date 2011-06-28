#!/usr/bin/php
<?php
$repos = $argv[1];
$txn = $argv[2];

exec('svnlook info ' . $repos . ' -t ' . $txn, $info);
$author = $info[0];
$time = $info[1];
$changeSize = $info[2];
$message = '';
$infoCount = count($info);
for ( $i=3; $i<$infoCount; ++$i ) {
    $message .= $info[$i];
}

// Check message has at least a number of Chars ...
if ( strlen($message) < 10 ) {
    fwrite(
        STDERR, 
        'Your commit has been blocked because you did not give any log message or your log message was too short.'
        .PHP_EOL
        .'Please write a log message describing the purpose of your changes and then try committing again.'
    );
    exit(1);
}
exit(0);