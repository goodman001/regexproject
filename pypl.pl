#!/usr/bin/perl
########################### pypl.pl ############################
# author :
# developdate: 20170930
################################################################



##### translate print
sub trans_print
{  
	$line =  $_[0]; 
	#print $line;
	if($line =~ /^(\s*)(print\(\")(.*)(\"\s*\)\s*)$/){# check print("")
		#print($2);
		$line = $1."print \"$3\\n\"";
		#print $line;
		
	}elsif($line =~ /^(\s*)(print\(\s*\")(.*)(\"\s*,\s*end=[\'\"]+\)\s*)$/) # check print("",end='')
	{
		$line = $1."print \"$3\"";
		#print $line."\n";
		
	}elsif($line =~ /^(\s*)(print\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\))/){ # check print(var)
		$line = $1."print \"\$".$3."\\n\"";
		#print $line;
	}
	elsif($line =~ /^(\s*)(print\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\s*,\s*end=['"]+\))/){ # check print(var,end='')
		$line = $1."print \"\$".$3."\"";
		#print $line;
	}elsif($line =~ /^(\s*)(print\(\s*)(.*)(\s*,\s*end=['"]+\))/){ # print(factor0 * factor1,end='')
	    $re = trans_var($3);
		$line = $1."print ".$re."";
		#print $line;
	}elsif($line =~ /^(\s*)(print\(\s*)(\")(.*)(\"\s*)(%\s*)(.*)(\s*\))$/){ #string formatting with the % operator
		#print "get formate \n";
		#print "var * var";
		$spaces = $1;
		$part1 = $4;
		$part2 = $7;
		#print "$spaces \n";
		#print "$part1 \n";
		
		if($part2 =~ /,/){ #print("nHex = %x,nDec = %d,nOct = %o" %(nHex,nHex,nHex))
			$content = "";
			$part2 =~ s/^\s*\(//;
			$part2 =~ s/\)\s*$//;
			@paras = split /,/,$part2;
			print "$part2 \n";
			$i=0;
			foreach $cell (@paras){
				print $cell."\n";
				@paras[$i] =  trans_var($cell);
				$i++;
			}
			$i = 0;
			@targets = split /%[a-zA-Z]+/,$part1;
			foreach $cell (@targets){
				print $cell."\n";
				$content = $content.$cell.@paras[$i];
				$i++;
			}
			#print "$content\n";
			$line = $spaces."print \"".$content." \\n\"";
		}else{
			$content = "";
			$part2 =~ s/^\s*//;
			$part2 =~ s/\s*$//;
			
			#@paras = split /,/,$part2;
			#print "$part2 \n";
			$target = trans_var($part2);
			$i = 0;
			@targets = split /%[a-zA-Z]+/,$part1;
			$i = 0;
			foreach $cell (@targets){
				if($i == 0){
					#print $cell."\n";
					$content = $content.$cell.$target;
				}else{
					$content = $content.$cell;
				}
				$i++;
			}
			#print "$content\n";
			$line = $spaces."print \"".$content." \\n\"";
			
		}
	}
	elsif($line =~ /^(\s*)(print\(\s*)(.*)(\s*\))/){# print(factor0 * factor1)
		#print "var * var";
		$re = trans_var($3);
		$line = $1."print ".$re.", \"\\n\"";
		if(length($re)>0){
			$line = $1."print ".$re.", \"\\n\"";
		}else{
			$line = $1."print \"\\n\"";
		}
		#print $line;
	}
	#print "var * var";
	#print $line;
	#print "\n";
	return $line;
	
} 
###### translate var statement
sub trans_var
{
	$line =  $_[0];
	$line =~ s/ and / && /g; 
	$line =~ s/ or / || /g;
	### handle int()

	
	###
	
	
	@flagarrtmp = ();
	@paraarr = split /[\[\]\(\)\^~=|&<>\/!%*+-]{1,}/,$line; #split statement
	@flagarr = ();
	#print "#```````````#\n";
	foreach $c (@paraarr){
		#push @paraarr,$c;
		#print "$c\n";
		#print "$c\n";
	}
	#print "#####'''''''''''\n";
	@flagarrtmp = $line =~ /(~)|(<<)|(>>)|(||)|(\/\/)|(<>)|([\[\]\)\(\^&\|=<>\/!%\*+-]{1,})/g;
	
	#print "#####\n";
	#### handle with symbol
	foreach $c (@flagarrtmp){
		if($c ne ''){
			if($c ne '~'){
				if($c eq '//'){
					#print $c;
					$c = '/';
				}elsif($c eq '<>'){
					$c = '!=';
				}
				
				if($c =~/\(/){
					$c = $c;
				}elsif($c =~/\)/){
					$c = $c;
				}elsif($c =~/\[/){
					$c = $c;
				}
				elsif($c =~/\]/){
					$c = $c;
				}
				else{
					$c = ' '.$c.' ';
				}
				
			}
			push @flagarr,$c;
			#print "$c\n";
		}
		
	}
	#print "#####\n";
	$cmds = "";
	$len = @flagarr;
	#print "$len\n";
	#### handle with var name
	for($i = 0;$i < @paraarr;$i++){
		#print @paraarr[$i];
		#print "\n";
		$cell = @paraarr[$i];
		if(@paraarr[$i] =~ /STDIN/){
			$cell = "<STDIN>";
		}elsif(@paraarr[$i] =~ /int/)
		{
			$cell = 'int';
		}
		elsif(@paraarr[$i] =~ /not/)
		{
			$cell = 'not';
		}
		elsif(@paraarr[$i] =~ /len/)
		{
			$cell = 'len';
		}
		elsif(@paraarr[$i] =~ /([ ]*\@)([a-zA-Z]{1}[0-9a-zA-Z_]*)/)
		{
			$cell = "\@".$2;
		}
		elsif(@paraarr[$i] =~ /([ ]*)([a-zA-Z]{1}[0-9a-zA-Z_]*)/)
		{
			$cell = "\$".$2;
		}
		
		elsif(@paraarr[$i] =~ /([ ]*)([0-9]*)/)
		{
			$cell = $2;
		}
		if($i < @flagarr){
			$cmds = $cmds.$cell.@flagarr[$i];
		}else
		{
			$cmds = $cmds.$cell;
		}
		#print $cmds ;
		#print "\n";
	}
	#print $cmds;
	#print "\n";
	return $cmds;
	
}
###### translate whgile/if in a line
sub transwhileifline
{
	#print "######whileif one line start\n";
	$line =  $_[0];
	@cellarr = ();
	#
	$line =~ /(while[ ]*|if[ ]*)(.*)(:[ ]*)(.*)/; 
	#print $1;
	#get while condition
	
	$condition = trans_var($2);
	#print $condition;
	push @cellarr,$1."(".$condition.")"." "."{";
	#get do
	@dosth= split /;/,$4;
	foreach $c (@dosth){
		if($c ne ''){
			if($c =~ /^[ ]*print\(/){
				#print "print\n";
				$doline = trans_print($c);
			}elsif($c =~ /break/){
				$doline = "last";
			}elsif($c =~ /continue/){
				$doline = "next";
			}
			else{
				$doline = trans_var($c);
			}
			push @cellarr,"    ".$doline.";";
		}
	}
	push @cellarr,"}";
	#print "\n######whileif one line end\n";
	return @cellarr;
	
}
###### translate whgile/if in muti lines
sub transwhileifformulti
{
	#print "######whileiffor multi line start\n";
	$line =  $_[0];
	$cmd = '';
	if($line =~ /(while[ ]*|if[ ]*|elif[ ]*|else[ ]*)(.*)(:[\s]*)$/){
		$head = $1;
		$cc = $2;
		if($head  =~ /else/){
			$cmd = "".$head ." "."{";
		}elsif($head  =~ /elif/){
			$condition = trans_var($cc);
			$cmd = ""."elsif "."(".$condition.")"." "."{";
		}
		else{
			$condition = trans_var($cc);
			$cmd = $head."(".$condition.")"." "."{";
		}
		#print $cmd."\n";
	}elsif($line =~ /(for\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\s*in\s*range\(\s*)(.*)(\s*\))/){# for i in range(5) or for i in range(0,5)
		#print "$2\n";
		$head = $1;
		$arg = $2;
		$content = $4;
		#print $content;
		my @paraarr = split /,/,$content; 
		#print @paraarr[1];
		$paranew = trans_var(@paraarr[0]);
		$paralen = @paraarr;
		if($paralen == 1){
			#
			$content = "(0..(".$paranew." - 1))";
		}elsif($paralen > 1)
		{
			$paranew2 = trans_var(@paraarr[1]);
			$content = "(".$paranew."..(".$paranew2." - 1))";
		}
		
		#print @paraarr[0];
		#print @paraarr[1];
		
		$cmd = "foreach \$".$arg." ".$content." {";
		#print $cmd;
	}elsif($line =~ /(for\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\s*in\s*)(STDIN)/){
		$cmd = "foreach \$".$2." (<STDIN>) {";
		#print "sysstding".$line."\n";
	}
	return $cmd;
}
###### translate list.append
sub trans_append
{
	#print "######list.append start\n";
	$line =  $_[0];
	$line =~ /^(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\.)(append\(\s*)(.*)(\s*\))/;
	$arrname = $2;
	$content = $5;
	$contentnew = trans_var($content);
	$cmd = "push @".$arrname.", ".$contentnew;
	#print $cmd."\n";
	#print $5."\n";
	return $cmd;
	
}
###### translate list.pop
sub trans_pop
{
	#print "######list.pop start\n";
	$line =  $_[0];
	$line =~ /^(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\.)(pop\(\s*)(.*)(\s*\))/;
	$arrname = $2;
	$content = $5;
	$cmd = ''; 
	if($content =~ /^\s*$/){
		#print "content is number \n ";
		$cmd = "pop @".$arrname;
		
	}
	else{
		$contentnew = trans_var($content);
		$cmd = "delete \$".$arrname."[".$contentnew."]";
	}
	
	#print $cmd."\n";
	#print $5."\n";
	return $cmd;
	
}
###### main func start ########
my $filename = $ARGV[0];
my @line;
if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
	while (my $row = <$fh>) {
	$row =~ s/[\r\n]$//;
	push @line,$row;
	}
} else {
  warn "Could not open file '$filename' $!";
}
@multilinespacelen = ();
foreach $arg (@line) {
	$output = $arg;
	# head line
	if ($output =~ /#!\/usr\/bin\/python3.*/){
		$output = "#!/usr/bin/perl -w"; 
	}
	# import
	if($output =~ /import.*/){
		$output = "";
	}
	# sys.stdout.write
	if($output =~ /^(.*)(sys.stdout.write\(\s*)(.*)(\))/ ){
		$output = $1."print(".$3.",end='')";
	}
	# sys.stdin.readline
	if($output =~ /\s*sys.stdin.readline\(\)\s*/ ){
		$output =~ s/sys.stdin.readline\(\)/STDIN/;
	}
	# sys.stdin
	if($output =~ /\s*sys.stdin[^.]\s*/ ){
		$output =~ s/sys.stdin/STDIN/;
	}
	# sys.stdin.readlines
	if($output =~ /^(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\s*=\s*)(sys.stdin.readlines)/ ){
		#print "readlines\n";
		$spaces = $1;
		$cc = $2;
		$output = $spaces."while (1){\n".$spaces.$spaces."last if eof STDIN;\n".$spaces.$spaces."push @".$cc.", scalar <STDIN>;\n".$spaces."}";
	}
	# len()
	if($output =~ /(len\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\))/ ){
		#$tmpvar = $2;
		$output =~ s/(len\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\))/\@$2/;
		#print $output." sss\n";
	}
	# sorted()
	if($output =~ /(sorted\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\))/ ){
		#$tmpvar = $2;
		$output =~ s/(sorted\(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\))/sort \@$2;/;
		#print $output." sss\n";
	}
	# a = []
	if($output =~ /^(\s*)([a-zA-Z]{1}[0-9a-zA-Z_]*)(\s*=\s*\[\s*\])/){
		$output = "";
	}
	# list.appand
	if($output =~ /^\s*[a-zA-Z]{1}[0-9a-zA-Z_]*\.append\(/){
		#print "appand!\n";
		$output =~ /([ ]*)/;
		$output = $1.trans_append($output);
		$output =  $output.";";
	}
	# list.pop
	if($output =~ /^\s*[a-zA-Z]{1}[0-9a-zA-Z_]*\.pop\(/){
		#print "pop!\n";
		#trans_pop($output);
		$output =~ /([ ]*)/;
		$output = $1.trans_pop($output);
		$output =  $output.";";
	}
	# break
	if($output =~ /break/){
		$output =~ s/break/last/;
		$output = $output.";";
	}
	# continue
	if($output =~ /continue/){
		$output =~ s/continue/next/;
		$output = $output.";";
	}
	# print
	if($output =~ /^[ ]*print\(/){
		#print "print\n";
		$output = trans_print($output);
		$output =  $output.";";
	}
	# var = ...
	if($output =~ /^[ ]*[a-zA-Z]{1}[0-9a-zA-Z_]*[ ]*=[ ]*/ )# var = 
	{
		if($output =~ /\s*sys.stdin.readlines/ ){
			;
		}else{
			$output =~ /([ ]*)/;
			$output = $1.trans_var($output);
			$output =  $output.";";
		}
		
	}
	# loop in line
	if($output =~ /^[ ]*(while|if|elif|else).*:.*[\S]+/){ # while line
		#print "find while";
		$output =~ /( *)/;
		#print $1."find while\n";
		$step = $1;
		@outarr = ();
		@outarr = transwhileifline($output);
		foreach $c (@cellarr){
			print $step.$c."\n";
		}
		next;
	}
	# loop in muti lines
	if($output =~ /^[ ]*(while|if|elif|else|for).*:[\s]*$/){
		#push @multilinespacenum
		#print "getget";
		#check stack for echo "}"
		$mutilineslen = @multilinespacenlen;
		if($mutilineslen > 0){
			#print @multilinespacenlen[ $mutilineslen - 1];
			#print "\n";
			$output =~ /( *)/;
			$step = $1;
			$steplen =  length($1);
			#print "steplen: $steplen \n";
			$tmpvar = @multilinespacenlen[$mutilineslen - 1];
			#print "tmpvar: $tmpvar \n";
			if($steplen <= $tmpvar){
				$i = $mutilineslen - 1;
				while($i >=-1 ){
					$tmpvar = pop@multilinespacenlen;
					if($steplen == $tmpvar){
						$stepstep = "";
						for($j=0;$j<$tmpvar;$j++){
							$stepstep = $stepstep." ";
						}
						print $stepstep."}\n";
						#pop@multilinespacenlen;
						last;

					}
					$stepstep = "";
					for($j=0;$j<$tmpvar;$j++){
						$stepstep = $stepstep." ";
					}
					print $stepstep."}\n";
					#$tmpvar = pop@multilinespacenlen;
					$i = $i - 1;
				}
			}



		}
		$output =~ /( *)/;
		#print $1."find while\n";
		$step = $1;
		$spacelen = length($1);
		push @multilinespacenlen,$spacelen;
		$endcmd = transwhileifformulti($output);
		print $step.$endcmd."\n";
		#print "$spacelen  find muti line\n";
		next;
	}
	#check stack for echo "}"
	$mutilineslen = @multilinespacenlen;
	if($mutilineslen > 0){
		#print @multilinespacenlen[ $mutilineslen - 1];
		#print "\n";
		$output =~ /( *)/;
		$step = $1;
		$steplen =  length($1);
		#print "xxsteplen: $steplen \n";
		$tmpvar = @multilinespacenlen[$mutilineslen - 1];
		#print "tmpvar: $tmpvar \n";
		if($steplen <= $tmpvar){
			$i = $mutilineslen - 1;
			while($i >=-1 ){
				$tmpvar = pop@multilinespacenlen;
				if($steplen == $tmpvar){
					$stepstep = "";
					for($j=0;$j<$tmpvar;$j++){
						$stepstep = $stepstep." ";
					}
					print $stepstep."}\n";
					#pop@multilinespacenlen;
					last;

				}
				$stepstep = "";
				for($j=0;$j<$tmpvar;$j++){
					$stepstep = $stepstep." ";
				}
				print $stepstep."}\n";
				#$tmpvar = pop@multilinespacenlen;
				$i = $i - 1;
			}
		}
		
		
		
	}
	
	
	print $output;
	print "\n";


}
#check stack for echo "}"
$mutilineslen = @multilinespacenlen;
if($mutilineslen > 0){
		#print @multilinespacenlen[ $mutilineslen - 1];
		#print "\n";
		$step = "";
		for($i = $mutilineslen -1;$i >= 0;$i-- ){
			$step = "";
			for($j=0;$j<@multilinespacenlen[$i];$j++){
				$step = $step." ";
			}
			print $step."}\n";
		}
		
		
}
