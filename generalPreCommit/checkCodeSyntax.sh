#!/usr/bin/php
<?php
$error = false;
$errorMessage = '';

$repos = $argv[1];
$txn = $argv[2];

// Check changed files for correct syntax ...
$info = array();
exec('svnlook changed -t ' . $txn . ' ' . $repos, $info);
$infoCount = count($info);
for ( $i=0; $i<$infoCount; ++$i ) {
    $fileInfo = explode('   ', $info[$i]);
    $file = '';
    $file = '/' . trim($fileInfo[1]);
    if ( preg_match('/^(.*)\.(phtml|php)$/i', $file) ) {
        // Fetch code and store it ...
        exec('svnlook cat -t ' . $txn . ' ' . $repos . ' ' . $file . ' > /tmp/svn.tmp');
        // Check syntax ...
        $lintErrors = '';
        exec('php -l /tmp/svn.tmp', $lintErrors);
        if ( count($lintErrors) > 2 ) {
            $error = true;
            $errorMessage .= 'FILE: ' . $file . "\n------------------------\n" . implode("\n", $lintErrors);
        }
        // Delete temp code file ...
        exec('rm -f /tmp/svn.tmp');
    }
}

if ($error) {
    fwrite(
        STDERR, 
        'Your commit has been blocked because of invalid PHP'
        .PHP_EOL
        .'Please write a log message describing the purpose of your changes and then try committing again.'
        .PHP_EOL
        .$errorMessage
    );
    exit(1);
}
exit(0);