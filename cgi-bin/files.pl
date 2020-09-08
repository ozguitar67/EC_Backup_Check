#!/usr/bin/perl
use Time::Local;

#############################################
## Author: Chris Perez                      # 
## Date: 06/26/2019                         #
## Brief: Cisco backup check results page   #
## Full: Outputs a list of all the backup   #
## files from each primary EC/DTACS and     #
## returns which host and the average file  #
## size over 30 days for each file.         #
#############################################

my @KEYNFS = ("http://172.21.151.57:8092/","http://172.21.151.59:8092/","http://172.21.151.61:8092/");
my @FRENFS = ("http://10.32.211.5:8092/","http://10.32.211.3:8092/");
my @BLTNFS = ("http://10.35.149.163:8092/","http://10.35.149.147:8092/","http://10.35.149.165:8092/","http://10.35.149.167:8092/","http://10.35.149.169:8092/","http://10.35.149.171:8092/","http://10.35.149.173:8092/");
my @GBRNFS = ("http://10.34.98.52:8092/","http://10.34.98.49:8092/","http://10.34.98.51:8092/");
@days = ("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
@months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
%Controllers = (
   "10.34.107.228" => "CPA1 EC Host A,Keystone",
   "10.34.107.242" => "CPA1 EC Host B,Keystone",
   "10.34.107.229" => "CPA1 DTACS Host A,Keystone",
   "10.34.107.243" => "CPA1 DTACS Host B,Keystone",
   "10.34.113.196" => "CPA2 EC Host A,Keystone",
   "10.34.113.210" => "CPA2 EC Host B,Keystone",
   "10.34.113.197" => "CPA2 DTACS Host A,Keystone",
   "10.34.113.211" => "CPA2 DTACS Host B,Keystone",
   "10.34.69.228" => "Pitt EC Host A,Keystone",
   "10.34.69.242" => "Pitt EC Host B,Keystone",
   "10.34.69.229" => "Pitt DTACS Host A,Keystone",
   "10.34.69.243" => "Pitt DTACS Host B,Keystone",
   "10.32.216.136" => "Alexandria EC Host A,Beltway",
   "10.32.216.140" => "Alexandria EC Host B,Beltway",
   "10.32.216.137" => "Alexandria DTACS Host A,Beltway",
   "10.32.216.141" => "Alexandria DTACS Host B,Beltway",
   "10.32.216.72" => "Carroll(Westminster) EC Host A,Beltway",
   "10.32.216.76" => "Carroll(Westminster) EC Host B,Beltway",
   "10.32.216.73" => "Carroll(Westminster) DTACS Host A,Beltway",
   "10.32.216.77" => "Carroll(Westminster) DTACS Host B,Beltway",
   "10.33.219.200" => "Chesterfield EC Host A,Beltway",
   "10.33.219.204" => "Chesterfield EC Host B,Beltway",
   "10.33.219.201" => "Chesterfield DTACS Host A,Beltway",
   "10.33.219.205" => "Chesterfield DTACS Host B,Beltway",
   "10.32.216.168" => "Dale City EC Host A,Beltway",
   "10.32.216.172" => "Dale City EC Host B,Beltway",
   "10.32.216.169" => "Dale City DTACS Host A,Beltway",
   "10.32.216.173" => "Dale City DTACS Host B,Beltway",
   "10.32.216.104" => "Dover EC Host A,Beltway",
   "10.32.216.108" => "Dover EC Host B,Beltway",
   "10.32.216.105" => "Dover DTACS Host A,Beltway",
   "10.32.216.109" => "Dover DTACS Host B,Beltway",
   "10.32.216.40" => "Howard/Harford EC Host A,Beltway",
   "10.32.216.44" => "Howard/Harford EC Host B,Beltway",
   "10.32.216.41" => "Howard/Harford DTACS Host A,Beltway",
   "10.32.216.45" => "Howard/Harford DTACS Host B,Beltway",
   "10.33.216.196" => "Staunton EC Host A,Beltway",
   "10.33.216.200" => "Staunton EC Host B,Beltway",
   "10.33.216.197" => "Staunton DTACS Host A,Beltway",
   "10.33.216.201" => "Staunton DTACS Host B,Beltway",
   "10.35.93.196" => "Cherry Hill EC Host A,Freedom",
   "10.35.93.200" => "Cherry Hill EC Host B,Freedom",
   "10.35.93.197" => "Cherry Hill DTACS Host A,Freedom",
   "10.35.93.201" => "Cherry Hill DTACS Host B,Freedom",
   "10.35.117.196" => "Monmouth EC Host A,Freedom",
   "10.35.117.200" => "Monmouth EC Host B,Freedom",
   "10.35.117.197" => "Monmouth DTACS Host A,Freedom",
   "10.35.117.201" => "Monmouth DTACS Host B,Freedom",
   "172.21.33.164" => "Hamden EC Host A,New England",
   "172.21.33.179" => "Hamden EC Host B,New England",
   "172.21.33.165" => "Hamden DTACS Host A,New England",
   "172.21.33.180" => "Hamden DTACS Host B,New England",
   "172.21.37.164" => "Londonderry EC Host A,New England",
   "172.21.37.179" => "Londonderry EC Host B,New England",
   "172.21.37.165" => "Londonderry DTACS Host A,New England",
   "172.21.37.180" => "Londonderry DTACS Host B,New England",
   "172.21.33.196" => "Plymouth EC Host A,New England",
   "172.21.33.211" => "Plymouth EC Host B,New England",
   "172.21.33.197" => "Plymouth DTACS Host A,New England",
   "172.21.33.212" => "Plymouth DTACS Host B,New England",
);
$primaries;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$setTime = timelocal(0,0,10,$mday,$mon,$year);
if($hour >= 10) {
   my $setTime = timelocal(0,0,10,$mday,$mon,$year);
   utime($setTime,$setTime,$0);
}
$dayName = $days[$wday];
$monAbr = $months[$mon];
$nowYear = $year + 1900;
if ($wday == 0) { $yNum = 6; }
else { $yNum = $wday - 1; }
$yesterday = $days[$yNum];
$wantFileDate = yesterday();

print ("Content-Type:text/html\n\n");
print <<EOM;
<!DOCTYPE html>
<html>
<head>
<title>Cisco Backup Info</title>
<script src="/TABLES/jquery.min.js"></script>
<link href="/TABLES/datatables.css" rel="stylesheet" type="text/css">
<link href="/TABLES/dataTables.tableTools.css" rel="stylesheet" type="text/css">
<script src="/TABLES/dataTables.js"></script>
<script src="/TABLES/dataTables.tableTools.js"></script>
</head>
<body>

<script>
\$(document).ready( function () {
    \$('#Files').DataTable({
	paging: false,
	order: [[0,'asc'],[1,'asc'],[3,'asc'],[4,'asc']]
	});
} );

</script>

<table id="Files" cellspacing="1" class="stripe">
<thead title="Shift+Click to sort on multiple columns">
  <tr>
     <th>Region</th>
     <th>Controller</th>
     <th>IP</th>
     <th>Path</th>
     <th>Filename</th>
     <th>FileDate</th>
     <th>Size</th>
     <th>Avg Size</th>
  </tr>
</thead>
<tbody>
EOM

foreach my $NFS (@KEYNFS) {
checkFiles($NFS);
}
printInfo();

foreach my $NFS (@FRENFS) {
checkFiles($NFS);
}
printInfo();

foreach my $NFS (@BLTNFS) {
checkFiles($NFS);
}
printInfo();

foreach my $NFS (@GBRNFS) {
checkFiles($NFS);
}
printInfo();

print <<EOM;
</tbody>
</table>
</body>
</html>
EOM

sub checkFiles {
   my $URL = $_[0];
   $CONTENT = `/usr/bin/curl -s $URL`;
   my @serverlist = getControllerIPs($CONTENT);

   foreach $server (@serverlist) {
      $server = $URL . $server . $yesterday . "\n";
      my $tServ = checkPrimary($server, $wantFileDate);
      if ($tServ ne "0") { $primaries = "$primaries$tServ,"; }
   }
}

sub getControllerIPs {
   my @tList;
   my $tIndex = 0;
   for my $line (split /\n/, $_[0]) {
      if ($line =~ /href="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/"/) {
         my $match = $line =~ /href="([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/)"/;
         $tList[$tIndex] = $1;
         $tIndex++;
      }
   }
   return @tList;
}

sub checkPrimary {
   my $CNT = 0;	
   my $url = $_[0];
   $url =~ s!/*$!/!;
   my $CONTENT = `/usr/bin/curl -s $url`;
   for my $line (split /\n/, $CONTENT) {
      if ($line =~ /href=".{2,4}\/"/) {
         my $match = $line =~ /$_[1]/;
         $CNT = $CNT + $match;
      }
    }
   if ($CNT == 2) {
   	chomp(my $DIR = $_[0]);
   	$DIR = $DIR . "/DBKF/";
   	return $DIR;
   }
   else { return 0; }
}

sub yesterday {
   my $yTime = time - 86400;
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($yTime);
   my $tYear = $year + 1900;
   my $rDate = $mday . "-" . $months[$mon] . "-" . $tYear;

   return $rDate;
}

sub checkServerFiles {
   my $url = $_[0];
   my $CONTENT = `/usr/bin/curl -s $url`;
   my $tController = findController($url);
   for my $line (split /\n/, $CONTENT) {
      if ($line =~ />.*gz/) {
         my $match = $line =~ /.gz">(.*\.gz)<.*\s([0-9]{1,2}-[A-Za-z]{1,3}-[0-9]{1,4} [0-9]{1,2}:[0-9]{1,2})\s+([0-9]+?\.?[0-9]+?[A-Za-z]{1})/;
         printLine($tController,$url,$1,$2,$3);
      }
    }
   findFSfiles($url,$tController);
}

sub findFSfiles {
   my $url = $_[0];
   $url =~ s/DBKF/FS/;
   my $CONTENT = `/usr/bin/curl -s $url`;
   for my $line (split /\n/, $CONTENT) {
      if ($line =~ /\/">.*?d.*s_.*\//) {
         my $match = $line =~ /\/">(.*?d.*s_.*?\/)/;
         chomp(my $FSdir = $1);
         $url = $url . $FSdir;
         $CONTENT = `/usr/bin/curl -s $url`;
         for my $line (split /\n/, $CONTENT) {
            if ($line =~ />.*gz/) {
            my $match = $line =~ /.gz">(.*\.gz)<.*\s([0-9]{1,2}-[A-Za-z]{1,3}-[0-9]{1,4} [0-9]{1,2}:[0-9]{1,2})\s+([0-9]+?\.?[0-9]+?[A-Za-z]{1})/;
            printLine($_[1],$url,$1,$2,$3);
            }
         }
      }
   }   
}

sub printInfo {
   $primaries =~ s/,$//;
   for my $tPrimary (split /,/, $primaries) {
      checkServerFiles($tPrimary);
   }
   undef $primaries;
}

sub findController {
   my $tURL = $_[0];
   my $match = $tURL =~ /:8092\/(.*?)\//;
   my $tIP = $1; 
   foreach my $key (keys %Controllers) {
      if ($key eq $tIP) {
         return "$Controllers{$key},$key";
      }
   }
}

sub printLine {
   my $path = $_[1];
   my $filename = $_[2];
   my $fileDate = $_[3];
   my $size = $_[4];
   my ($controller,$region,$IP) = split(/,/,$_[0],);
   my $mTS = (stat($0))[9];
   my $meanFS = checkAvgSize($controller,$filename,$size,$mTS);
   print <<EOM;
   <tr>
        <td>$region</td>
        <td>$controller</td>
        <td>$IP</td>
        <td>$path</td>
        <td>$filename</td>
        <td>$fileDate</td>
        <td>$size</td>
        <td>$meanFS</td>
   </tr>
EOM
}

sub checkAvgSize {
   my $CTLR = $1 if ($_[0] =~ /(^.*? EC|^.*? DTACS)/);
   $CTLR =~ s|[ /\(\)]|_|g;
   my $NAME = $_[1];
   $NAME =~ s/@.*$//;
   my $avgFileName = "FILES/" . $CTLR . "_" . $NAME . ".txt";
   if (-e $avgFileName) {
      $fmTime = (stat($avgFileName))[9];
   }
   else {
      open FC, ">", $avgFileName;
      close FC;
   }
   
 my $fSIZE = (stat($avgFileName))[7];
   if (($_[3] > $fmTime) || ($fSIZE = 0)) {
      open(FW, ">>", $avgFileName); #open filehandle FW (FileWrite) to append the file size
      print FW "$_[2]\n";
      close FW;
   }   
   #calculates the average file size and limits data stored to 30 entries (30 days)
   my $AFS = calcAvgSize($avgFileName);
   return $AFS;
}

sub calcAvgSize {
   my $tFile = $_[0];
   $totalSize = 0;
   my @lines;
   open FR, "<", $tFile;
   while (<FR>) {
      push @lines, $_;
      my $match = $_ =~ /(^.*?)([a-zA-Z])$/;
      my $sizeNumber = $1;
      my $sizeLetter = $2;
      #Determines denomination of data size and converts to megabytes, then keeps a sum of the amount
      if ($sizeLetter eq "K") {
         $sizeNumber = $sizeNumber / 1024;
         $totalSize = $totalSize + $sizeNumber;
      }
      elsif ($sizeLetter eq "M") {
         $totalSize = $totalSize + $sizeNumber;
      }
      elsif ($sizeLetter eq "G") {
         $sizeNumber  = $sizeNumber * 1024;
         $totalSize = $totalSize + $sizeNumber;
      }
   }

   my $avgFileSize = $totalSize / $.;
   my $lineCount = $.; #$. variable is the current line number from filehandle
   close FR;

   if ($lineCount > 30) {
      shift @lines;
      open FW, ">", $tFile;
      print FW @lines;
      close FW;
   }
   #Added logic to figure out K,M,G to return and correct number value
   if ($avgFileSize < 1) {
      $avgFileSize = $avgFileSize * 1024;
      $avgFileSize = sprintf("%.1f", $avgFileSize) . "K";
   }
   elsif ($avgFileSize >= 1024) {
      $avgFileSize = $avgFileSize / 1024;
      $avgFileSize = sprintf("%.1f", $avgFileSize) . "G";
   }
   else {
      $avgFileSize = sprintf("%.1f", $avgFileSize) . "M";
   }
   return $avgFileSize;
}  
