<?php

function param($a /*comma-separated string*/) {
    $b=explode('|', preg_replace(array("/[^A-Za-z0-9,'-\s|]*/", "/'/"), array('', "''"), urldecode($a)));
    
    return $b;
}

function where($d /*fieldname*/, $a /*array of legal STRING values*/, $e=true /*is_string?*/) {
    $c=' and (';
    $f = 0;
    if ($e!=false) {
    foreach ($a as $b){
    $f++; if ($f>1) {$c.=' or';}
    $c.=' '.$d." = '".$b."'";
    }
    }
    else {
    foreach ($a as $b){
    $f++; if ($f>1) {$c.=' or';}
    $c.=' '.$d." = ".$b."";
    }
    }
    $c.=')';
    return $c;
}

$dbconn = pg_connect("host=localhost port=5432 dbname=rmosolgo user=rmosolgo password=a1dd4t4")
   or die('Could not connect: ' . pg_last_error());

$r = $_REQUEST['r'];

if ($r == 'ag'){
    $d = param($_REQUEST['donor']);
    $r = param($_REQUEST['recipient']);
    $p = param($_REQUEST['purpose']);
    $y = param($_REQUEST['year']);
    
    $dq = isset($_REQUEST['donor']);
    $rq = isset($_REQUEST['recipient']);
    $pq = isset($_REQUEST['purpose']);
    $yq = isset($_REQUEST['year']);
    
    $q = 'select '.(($dq) ?  'donor, ' : '').(($rq) ?  'recipient, ' : '').(($pq) ?  'coalesced_purpose_code as purpose,' : '').
        'year, count(*) as record_count, sum(commitment_amount_usd_constant) as usd_2009 from aiddata2 where aiddata_id is not null'.
        (($dq) ? where('donor', $d, true) : '').
        (($rq) ? where('recipient', $r, true) : '').
        (($yq) ? where('year', $y, false) : '').
        (($pq) ? where('coalesced_purpose_code', $p, true) : '').
        ' group by '.(($dq) ?  'donor, ' : '').(($rq) ?  'recipient, ' : '').(($pq) ?  'coalesced_purpose_code,' : '').' year;';
    $r = pg_query($q);
    if (!$r) {echo pg_last_error().'
    
    ';}
    $e.='{ "data": [';
    $f = 0;
    while ($v = pg_fetch_array($r, null, PGSQL_ASSOC)){
        $f++; if ($f>1) {$e.=',';}
        $e.=' { ';
        $c = 0;
    foreach($v as $key => $value) {
        $c++;
        if ($c>1){$e.=', ';}
        $e.= "\"$key\":\"$value\"";

    }
    $e.='}';
    }
    
    $e.=']}';
    
}

echo $e;

pg_close($dbconn);
?>