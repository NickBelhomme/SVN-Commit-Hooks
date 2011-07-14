#!/usr/bin/php
<?php
$repos = $argv[1];
$rev = $argv[2];

exec('svnlook info ' . $repos . ' -r ' . $rev, $info);
$author = $info[0];
$time = $info[1];
$change_size = $info[2];
$message = array_slice($info, 3);
$message = implode("\n", $message);

// remove "PATH_TO_REPO"
$repoPath = '/var/...PATH_TO_REPO.../';
$revisionUrlRoot = substr($argv[1], strlen($repoPath));
$webSvnUri = 'http://yourdomain/websvn/revision.php?repname='.$revisionUrlRoot.'&path=/&rev='.$rev;

$comment = '['.$author.']' . "\n"
         . $message . "\n"
         . 'websvn: '.$webSvnUri;


if (preg_match('/(issue|resolves): #(\d+)/', $message, $matches)) {
    $taskId = $matches[2];
    $isResolved = ('resolves' == $matches[1]);

    $options = array(
        CURLOPT_COOKIE => 'flyspray_userid=[FLYSPRAY_USER_ID]; flyspray_passhash=[FLYSPRAY_USER_PASS_HASH];'
    );

    // handle the message
    $post = array(
        'action' => 'addcomment',
        'task_id' => $taskId,
        'comment_text' => $comment,
    );
    curl_post('http://[FLYSPRAY_DOMAIN_HERE]/index.php?do=details&task_id='.$taskId, $post, $options);

    //handle the progressbar
    if ($isResolved) {
        $post = array(
            'field' => 'progress',
            'task_id' => $taskId,
            'value' => 90,
        );
        curl_post('http://[FLYSPRAY_DOMAIN_HERE]/javascript/callbacks/savequickedit.php', $post, $options);
    }
}


function curl_post($url, array $post = NULL, array $options = array())
{
    $defaults = array(
        CURLOPT_POST => 1,
        CURLOPT_HEADER => 0,
        CURLOPT_URL => $url,
        CURLOPT_FRESH_CONNECT => 1,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_FORBID_REUSE => 1,
        CURLOPT_TIMEOUT => 4,
        CURLOPT_POSTFIELDS => http_build_query($post)
    );

    $ch = curl_init();
    curl_setopt_array($ch, ($options + $defaults));
    if( ! $result = curl_exec($ch))
    {
        trigger_error(curl_error($ch));
    }
    curl_close($ch);
    return $result;
}
