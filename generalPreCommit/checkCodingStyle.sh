#!/usr/bin/php
<?php
$repos = $argv[1];
$txn = $argv[2];

exec('svnlook info ' . $repos . ' -t ' . $txn, $info);
$author = $info[0];
$time = $info[1];
$changeSize = $info[2];
$message = array_slice($info, 3);
$message = implode("\n", $message);
if (strpos($message, '[NOPHPCS]') === false) {
    passthru("/usr/bin/scripts/phpcs-svn-pre-commit --standard=Zend $repos -t $txn", $returnStatus);
    exit($returnStatus);
}
exit(0);