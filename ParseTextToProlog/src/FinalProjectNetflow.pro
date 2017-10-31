%Jonathan Frazier and Ranjith Kumar
%Load Netflow Database
%---------------------------------------------------------------------------------------
openFileForReading(FILE):-
	Name is select_file(o, "All Files", ".txt"),
	%FILE is open("C:\\Users\\hokie\\Desktop\\Netflow.txt", "r").
	FILE is open(Name, "r").
readFile(FILE):-
	feof(FILE),
	close(FILE).

readFile(FILE):-
	not(feof(FILE)),
	Line is readln(FILE),
	T is scan(Line),
	asserta(T),
	readFile(FILE).
%Loads Netflow Facts in format:
%netflow_Facts(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcAddr,Sport,Dir,DstAddr,Dport,State,sTos,dTos,TotPkts,TotBytes,SrcBytes,Label).
loadNetflowDataBase():-
	openFileForReading(FILE),
	readFile(FILE).
%---------------------------------------------------------------------------------------


%Helper Queries
%---------------------------------------------------------------------------------------
%Calculate the sum of List
sumList([],0.0).

sumList([H|Durations],H+Duration):-
	sumList(Durations,Duration).

%Count Items in List
countList([],0).

countList([H],1).

countList([H|Durations],Count+1):-
	countList(Durations,Count).

%Find Item in List at certain location
findItem([],0,_,_).

findItem([H|List],Count+1,Location,Item):-
	Count=\=Location,
	findItem(List,Count,Location,Item).


findItem([H|List],Count+1,Location,Item):-
	Count=Location,
	H=Item.


%Remove Duplicates from List
removeDuplicates([],_).

removeDuplicates([H|List],FilteredList):-
	member(H,FilteredList),
	removeDuplicates(List,FilteredList).

removeDuplicates([H|List],[H|FilteredList]):-
	not(member(H,FilteredList)),
	removeDuplicates(List,FilteredList).

%Print List Contents
printList([]).

printList([H|T]):-
	write(H),
	write("\n"),
	printList(T).

%---------------------------------------------------------------------------------------


%Aggregate Queries
%---------------------------------------------------------------------------------------

%Create list of Unique Dest IP addresses 
findUniqueDestIP(DestIPsFiltered):-
	findall(DestIP,netflow_Facts(_,_,_,_,_,_,_,_,_,DestIP,_,_,_,_,_,_,_,_),DestIPs),
	removeDuplicates(DestIPs,DestIPsFiltered).

%Create list of Unique Src IP addresses 
findUniqueSrcIP(SrcIPsFiltered):-
	findall(SrcIP,netflow_Facts(_,_,_,_,_,_,SrcIP,_,_,_,_,_,_,_,_,_,_,_),SrcIPs),
	removeDuplicates(SrcIPs,SrcIPsFiltered).

%Create list of Unique Src IP addresses for a DestIP
findUniqueSrcIPforDestIP(DestIP,SrcIPsFiltered):-
	findall(SrcIP,netflow_Facts(_,_,_,_,_,_,SrcIP,_,_,DestIP,_,_,_,_,_,_,_,_),SrcIPs),
	removeDuplicates(SrcIPs,SrcIPsFiltered).

%Create list of Unique Dest IP addresses for a SrcIP
findUniqueDestIPforSrcIP(SrcIP,DestIPsFiltered):-
	findall(DestIP,netflow_Facts(_,_,_,_,_,_,SrcIP,_,_,DestIP,_,_,_,_,_,_,_,_),DestIPs),
	removeDuplicates(DestIPs,DestIPsFiltered).



%Determine and Print to Screen IPs communicating with Dest node
uniqueIPsCommunicateWithDestIP([]).

uniqueIPsCommunicateWithDestIP([H|FilteredList]):-
	not(findUniqueSrcIPforDestIP(H,DestIPsFiltered)),
	uniqueIPsCommunicateWithDestIP(FilteredList).

uniqueIPsCommunicateWithDestIP([H|FilteredList]):-
	findUniqueSrcIPforDestIP(H,SrcIPsFiltered),
	write("Destination IP: "+H),
	write("\nSource IPs communicating with Destination IP: \n"),
	write(SrcIPsFiltered),
	write("\n\n"),
	uniqueIPsCommunicateWithDestIP(FilteredList).

%Determine and Print to Screen IPs Src node is sending data to
uniqueIPsSrcIPCommunicateWith([]).

uniqueIPsSrcIPCommunicateWith([H|FilteredList]):-
	not(findUniqueDestIPforSrcIP(H,DestIPsFiltered)),
	uniqueIPsSrcIPCommunicateWith(FilteredList).

uniqueIPsSrcIPCommunicateWith([H|FilteredList]):-
	findUniqueDestIPforSrcIP(H,DestIPsFiltered),
	write("Source IP: "+H),
	write("\nDestination IPs that Source IP is Communicating with: \n"),
	write(DestIPsFiltered),
	write("\n\n"),
	uniqueIPsSrcIPCommunicateWith(FilteredList).
	
	
%Display all unique IP addresses communicating with Dest IP address
ipCommunicatingWithDestIP():-
	findUniqueDestIP(DestIPsFiltered),
	uniqueIPsCommunicateWithDestIP(DestIPsFiltered).

%Display all unique IP addresses Src IP address is communicating with
srcIPCommunicatingWithDestIP():-
	findUniqueSrcIP(SrcIPsFiltered),
	uniqueIPsSrcIPCommunicateWith(SrcIPsFiltered).

%Filter out Flows that have Duration Less than Specified
filterDurationsLessThanMinDuration(_,[],_).

filterDurationsLessThanMinDuration(MinDurationToFind,[H|List],FilteredList):-
	write("\nMade it 1\n"),
	findItem(H,Count,5,Duration),
	Duration<MinDurationToFind,
	filterDurationsLessThanMinDuration(MinDurationToFind,List,FilteredList).


filterDurationsLessThanMinDuration(MinDurationToFind,[H|List],[H|FilteredList]):-
	write("\nMade it 2\n"),
	findItem(H,Count,5,Duration),
	Duration>=MinDurationToFind,
	filterDurationsLessThanMinDuration(MinDurationToFind,List,FilteredList).

%Finds all flows that have specified criteria
findallDurationGreaterThanXPercentOfAvgDuration(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,
	MinDurationToFind,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes]):-
		netflow_Facts(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,_,DestIP,DestP,_,_,_,TotPackets,TotalBytes,_,_),
		Dur>MinDurationToFind.
%Finds all flows that have specified criteria (Elephant Flow)
findallLongDurationHighBandWidthFlows(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth,
	MinDurationToFind,BandWidthLimit,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth]):-
		netflow_Facts(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,_,DestIP,DestP,_,_,_,TotPackets,TotalBytes,_,_),
		Dur>MinDurationToFind,
		R is float(TotalBytes),
		AvgBandwidth=(R/Dur),
		AvgBandwidth>=BandWidthLimit.

%Finds all flows that have specified criteria (Mouse Flow)
findallLongDurationLowBandWidthFlows(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth,
	MinDurationToFind,BandWidthLimit,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth]):-
		netflow_Facts(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,_,DestIP,DestP,_,_,_,TotPackets,TotalBytes,_,_),
		Dur>MinDurationToFind,
		R is float(TotalBytes),
		AvgBandwidth=(R/Dur),
		AvgBandwidth<BandWidthLimit.



%Find Flows with Duration greater than X percent of average Duration of all flows
findDurationsGreaterThanXPercent(XPercent,List):-
	averageFlowDuration(AvgDuration),
	MinDurationToFind=AvgDuration*XPercent,	
	findall([StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes],
		findallDurationGreaterThanXPercentOfAvgDuration(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,
	MinDurationToFind,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes]),List).
	%filterDurationsLessThanMinDuration(MinDurationToFind,List,FilteredList),

%Find Flows with utilizing greater than 1% of available bandwidth for long Duration(Greater than 200% average flow duration)
findLargeBandWidthFlows(XPercent,BandWidthLimit,List):-
	averageFlowDuration(AvgDuration),
	MinDurationToFind=AvgDuration*XPercent,	
	findall([StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth],
		findallLongDurationHighBandWidthFlows(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth,
	MinDurationToFind,BandWidthLimit,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth]),List).
	%filterDurationsLessThanMinDuration(MinDurationToFind,List,FilteredList),

%Find Flows with utilizing less than 0.01% of available bandwidth for long Duration(Greater than 200% average flow duration)
findSmallBandWidthFlows(XPercent,BandWidthLimit,List):-
	averageFlowDuration(AvgDuration),
	MinDurationToFind=AvgDuration*XPercent,	
	findall([StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth],
		findallLongDurationLowBandWidthFlows(StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth,
	MinDurationToFind,BandWidthLimit,
	[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,AvgBandwidth]),List).
	%filterDurationsLessThanMinDuration(MinDurationToFind,List,FilteredList),

	
%-----------------------------------------------------------------------------------------------------


%Flow Statistic Queries
%-----------------------------------------------------------------------------------------------------
%Calculate the average duration of a flow to a destination
averageDurations(Durations,AvgDuration,Count):-
	sumList(Durations,Duration),
	countList(Durations,Count),
	Count>0,
	AvgDuration = Duration/Count.

%Calculate Average Duration for Flow to DestIP,Port
averageFlowDurationDestPort(DestIP,Dport,AvgDuration,Count):-
	findall(Dur,netflow_Facts(_,_,_,_,Dur,_,_,_,_,DestIP,Dport,_,_,_,_,_,_,_),Durations),
	averageDurations(Durations,AvgDuration,Count).
	

%Calculate Average Duration for Flow to DestIP
averageFlowDurationDest(DestIP,AvgDuration,Count):-
	findall(Dur,netflow_Facts(_,_,_,_,Dur,_,_,_,_,DestIP,_,_,_,_,_,_,_,_),Durations),
	averageDurations(Durations,AvgDuration,Count).


%Calculate Average Duration for Flows from SrcIP
averageFlowDurationSrc(SrcIP,AvgDuration,Count):-
	findall(Dur,netflow_Facts(_,_,_,_,Dur,_,SrcIP,_,_,_,_,_,_,_,_,_,_,_),Durations),
	averageDurations(Durations,AvgDuration,Count).

%Calculate Average Duration for Flow from SrcIP,Port
averageFlowDurationSrcPort(SrcIP,SrcP,AvgDuration,Count):-
	findall(Dur,netflow_Facts(_,_,_,_,Dur,_,SrcIP,SrcP,_,_,_,_,_,_,_,_,_,_),Durations),
	averageDurations(Durations,AvgDuration,Count).

%Calculate Average Duration for Flow from SrcIP,Port with bytes sent above threshold
averageFlowDurationSrcPortOverCertainDataCriteria(SrcIP,SrcP,MinTotalBytesSent,AvgDuration,Count):-
	findall(Dur,(netflow_Facts(_,_,_,_,Dur,_,SrcIP,SrcP,_,_,_,_,_,_,_,TotBytes,_,_),TotBytes>MinTotalBytesSent),Durations),
	averageDurations(Durations,AvgDuration,Count).

%Calculate the average duration for all flows
averageFlowDuration(AvgDur):-
	findall(Dur,netflow_Facts(_,_,_,_,Dur,_,_,_,_,_,_,_,_,_,_,_,_,_),Durations),
	averageDurations(Durations,AvgDur,Count).

%Total Bytes sent by a sourceIP
totalBytesSent(SrcIP,TotalBytes):-
	findall(TotBytes,netflow_Facts(_,_,_,_,_,_,SrcIP,_,_,_,_,_,_,_,_,TotBytes,_,_),Bytes),
	sumList(Bytes,TotalBytes).

%Total Bytes sent by a sourceIP, sourcePort
totalBytesSent(SrcIP,SrcP,TotalBytes):-
	findall(TotBytes,netflow_Facts(_,_,_,_,_,_,SrcIP,SrcP,_,_,_,_,_,_,_,TotBytes,_,_),Bytes),
	sumList(Bytes,TotalBytes).

%Total Bytes sent by a sourceIP, sourcePort
totalBytesSentByIP(SrcIP,SrcP,TotalBytes):-
	findall([DestIP, DestP, TotBytes],netflow_Facts(_,_,_,_,_,_,SrcIP,SrcP,_,DestIP,DestP,_,_,_,_,TotBytes,_,_),Bytes),
	%sumList(Bytes,TotalBytes)
	write(Bytes).
%--------------------------------------------------------------------------------------------------------------------------	

?-loadNetflowDataBase().
%?-  assert(test(1,2)), test(X,Y), write(X), write(" "), write(Y), nl.	
%?-asserta(netflow_Facts('2011/08/10',09,46,53.047277,3550.182373,udp,"212.50.71.179",39678,"<->","147.32.84.229",13363,con,0,0,12,875,413,"flow=Background-UDP-Established")).
%?-findUniqueDestIP(DestIP).
%?-findUniqueSrcIP(SrcIP,SrcIPsFiltered).
?-write("\nALL SOURCE IP ADDR FOR EACH DESTINATION IP ADDR\n"),
write("\n---------------------------------------------------------------------------------------\n"),
ipCommunicatingWithDestIP(),
write("\nALL DESTINATION IP ADDR FOR EACH SOURCE IP ADDR\n"),
write("\n---------------------------------------------------------------------------------------\n"),
srcIPCommunicatingWithDestIP(),
write("\nSAMPLE OF DIFFERENT DATABASE QUERIES\n"),
write("\n---------------------------------------------------------------------------------------\n"),
write("Query 1 Average Flow Duration for flows to IP Addr:\n"),
write("147.32.84.229 \n"),
averageFlowDurationDest("147.32.84.229",AvgDuration, Count1), 
write("Average Duration: "+AvgDuration+" secs, # of flows: "+Count1+"\n"),

write("\nQuery 2 Average Flow Duration for flows to IP Addr:Port#:\n"),
write("74.125.232.215:443 \n"),
averageFlowDurationDestPort("74.125.232.215",443,AvgDuration2,Count2), 
write("Average Duration: "+AvgDuration2+" secs, # of flows: "+Count2+"\n"),

write("\nQuery 3 Average Flow Duration for flows from IP Addr:\n"),
write("147.32.84.229 \n"),
averageFlowDurationSrc("147.32.84.229",AvgDuration3,Count3), 
write("Average Duration: "+AvgDuration3+" secs, # of flows: "+Count3+"\n"),

write("\nQuery 4 Average Flow Duration for flows from IP Addr:Port#:\n"),
write("147.32.84.229:443\n"),
averageFlowDurationSrcPort("147.32.84.229",443,AvgDuration4,Count4), 
write("Average Duration: "+AvgDuration4+" secs, # of flows: "+Count4+"\n"),

%write("\nQuery 5 Average Flow Duration for flows from IP Addr:Port# with Total Bytes Sent Greater than 100MB:\n"),
%write("147.32.84.229:13363\n"),
%averageFlowDurationSrcPortOverCertainDataCriteria("147.32.84.229",13363,50000,AvgDuration5,Count5), 
%write("Average Duration: "+AvgDuration5+" secs, # of flows: "+Count5).

write("\nQuery 6 total bytes sent from IP Addr:\n"),
write("147.32.84.229\n"),
totalBytesSent("147.32.84.229",TotalBytes), 
write("Total Bytes Sent: "+TotalBytes+"\n"),

write("\nQuery 7 total bytes sent from IP Addr/Port:\n"),
write("147.32.84.229:443\n"),
totalBytesSent("147.32.84.229",443,TotalBytes1), 
write("Total Bytes Sent: "+TotalBytes1+"\n"),

write("\nQUERIES TO FIND HIGH RISK NODES\n"),
write("--------------------------------------------------------------------------------------\n"),

write("\nQuery 8 Average Duration of All Flows: \n"),
averageFlowDuration(AvgDuration5), 
write("Average Duration: "+AvgDuration5+" secs\n"),

write("\nQuery 9 Find Flow with Duration Greater than 200% of Average Flow Duration:\n"),
findDurationsGreaterThanXPercent(2.0,List2),
write("[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes]\n"),
printList(List2),
write("\n"),

write("\nQuery 10 Find Flow with Duration Greater than 200% of Average Flow Duration and Avg."), 
write("Bandwidth greater than 1% of Total Bandwidth(10Mbps Connection[1,000,000bps]):\n"),
findLargeBandWidthFlows(2.0,12500.0,List3),
write("[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,Bandwidth(bps)]\n"),
printList(List3),
write("\n").

%write("\nQuery 11 Find Flow with Duration Greater than 200% of Average Flow Duration and Avg."), 
%write("Bandwidth less than 0.01% of Total Bandwidth(10Mbps Connection[1,000,000bps]):\n"),
%findSmallBandWidthFlows(2.0,100.0,List4),
%write("[StartDate,StartHour,StartMin,StartSec,Dur,Proto,SrcIP,Sport,DestIP,DestP,TotPackets,TotalBytes,Bandwidth(bps)]\n"),
%printList(List4),
%write("\n").




