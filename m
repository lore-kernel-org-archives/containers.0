From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Thu, 7 Aug 2008 14:23:38 -0500
Message-ID: <20080807192338.GA2050@us.ibm.com>
References: <20080731183213.GA12033@us.ibm.com>
	<20080801172811.FEC3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080801172811.FEC3.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Quoting KOSAKI Motohiro (kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org):
> Hi
> 
> fork() is very important for system performance.
> I worry about performance regression if this feature isn't used.
> 
> Could you mesure spawn benchmark in unixbench?

Sigh, well I did run some benchmarks on a machine on our grid, but none
seem to be giving useful or consistent results.  Unixbench results are
attached in the following files:

unixbench results:
	elm3b165.nohijack.1: result of './Run 1' on plain 2.6.27-rc1
	elm3b165.nohijack.4: result of './Run 4' on plain 2.6.27-rc1
	elm3b165.withhijack.1: result of './Run 1' on 2.6.27-rc1 with hijack patch
	elm3b165.withhijack.4: result of './Run 4' on 2.6.27-rc1 with hijack patch

I suppose I could have automated these to get more runs, but as it is
the results seem meaningless to me.

I also ran dbench and tbench.  All tbench instances were with
5 clients, all dbench with 4 clients.  I ran both dbench and tbench 10
times on each kernel, and here are the mean throughput +/- 95% confidence
interval:

Plain 2.6.27-rc1 kernel:
tbench: 520.355900 +/- 17.104307
dbench: 671.337900 +/- 146.785891

2.6.27-rc1 with hijack:
tbench: 523.213300 +/- 19.726943
dbench: 437.324400 +/- 169.086289

The tbench ones are solidly within the confidence bounds.  The dbench
results aren't really believable.  Cron wasn't running on the machine,
and nothing else *should* have been, but alas I don't own the machine
so don't know what could have been running.

thanks,
-serge

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elm3b165.nohijack.1"

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8167048.5      216.8
Double-Precision Whetstone                      83.1     1199.0      144.3
Execl Throughput                               188.3     6777.2      359.9
File Copy 1024 bufsize 2000 maxblocks         2672.0   113916.0      426.3
File Copy 256 bufsize 500 maxblocks           1077.0    36714.0      340.9
File Read 4096 bufsize 8000 maxblocks        15382.0   718796.0      467.3
Pipe Throughput                             111814.6  1425864.8      127.5
Pipe-based Context Switching                 15448.6   394297.5      255.2
Process Creation                               569.3    18977.8      333.4
Shell Scripts (8 concurrent)                    44.8     1217.8      271.8
System Call Overhead                        114433.5  2858840.5      249.8
                                                                 =========
     FINAL SCORE                                                     270.3

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8362581.0      221.9
Double-Precision Whetstone                      83.1     1203.5      144.8
Execl Throughput                               188.3     6715.0      356.6
File Copy 1024 bufsize 2000 maxblocks         2672.0   107020.0      400.5
File Copy 256 bufsize 500 maxblocks           1077.0    32403.0      300.9
File Read 4096 bufsize 8000 maxblocks        15382.0   678707.0      441.2
Pipe Throughput                             111814.6  1385493.0      123.9
Pipe-based Context Switching                 15448.6   372454.9      241.1
Process Creation                               569.3    18607.9      326.9
Shell Scripts (8 concurrent)                    44.8     1208.8      269.8
System Call Overhead                        114433.5  2691682.8      235.2
                                                                 =========
     FINAL SCORE                                                     260.7


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elm3b165.nohijack.4"

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8232510.9      218.5
Double-Precision Whetstone                      83.1     1202.4      144.7
Execl Throughput                               188.3     6739.0      357.9
File Copy 1024 bufsize 2000 maxblocks         2672.0   104621.0      391.5
File Copy 256 bufsize 500 maxblocks           1077.0    33092.0      307.3
File Read 4096 bufsize 8000 maxblocks        15382.0   684132.0      444.8
Pipe Throughput                             111814.6  1344322.6      120.2
Pipe-based Context Switching                 15448.6   385326.1      249.4
Process Creation                               569.3    18701.0      328.5
Shell Scripts (8 concurrent)                    44.8     1211.8      270.5
System Call Overhead                        114433.5  2910270.2      254.3
                                                                 =========
     FINAL SCORE                                                     262.6

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8247240.2      218.9
Double-Precision Whetstone                      83.1     1198.4      144.2
Execl Throughput                               188.3     6540.9      347.4
File Copy 1024 bufsize 2000 maxblocks         2672.0    97453.0      364.7
File Copy 256 bufsize 500 maxblocks           1077.0    31134.0      289.1
File Read 4096 bufsize 8000 maxblocks        15382.0   781214.0      507.9
Pipe Throughput                             111814.6  1408780.0      126.0
Pipe-based Context Switching                 15448.6   351906.0      227.8
Process Creation                               569.3    18638.3      327.4
Shell Scripts (8 concurrent)                    44.8     1211.8      270.5
System Call Overhead                        114433.5  2737286.8      239.2
                                                                 =========
     FINAL SCORE                                                     259.3

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elm3b165.withhijack.1"

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8899355.0      236.2
Double-Precision Whetstone                      83.1     1204.8      145.0
Execl Throughput                               188.3     6626.6      351.9
File Copy 1024 bufsize 2000 maxblocks         2672.0   109426.0      409.5
File Copy 256 bufsize 500 maxblocks           1077.0    34428.0      319.7
File Read 4096 bufsize 8000 maxblocks        15382.0   625814.0      406.8
Pipe Throughput                             111814.6  1296658.5      116.0
Pipe-based Context Switching                 15448.6   359970.6      233.0
Process Creation                               569.3    18747.0      329.3
Shell Scripts (8 concurrent)                    44.8     1210.8      270.3
System Call Overhead                        114433.5  2745197.3      239.9
                                                                 =========
     FINAL SCORE                                                     260.2

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8823465.9      234.2
Double-Precision Whetstone                      83.1     1205.6      145.1
Execl Throughput                               188.3     6603.0      350.7
File Copy 1024 bufsize 2000 maxblocks         2672.0   104783.0      392.2
File Copy 256 bufsize 500 maxblocks           1077.0    32153.0      298.5
File Read 4096 bufsize 8000 maxblocks        15382.0   859178.0      558.6
Pipe Throughput                             111814.6  1185154.3      106.0
Pipe-based Context Switching                 15448.6   344165.8      222.8
Process Creation                               569.3    18397.4      323.2
Shell Scripts (8 concurrent)                    44.8     1207.6      269.6
System Call Overhead                        114433.5  2654906.5      232.0
                                                                 =========
     FINAL SCORE                                                     260.3


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elm3b165.withhijack.4"

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8844791.9      234.7
Double-Precision Whetstone                      83.1     1206.1      145.1
Execl Throughput                               188.3     6700.7      355.9
File Copy 1024 bufsize 2000 maxblocks         2672.0   102895.0      385.1
File Copy 256 bufsize 500 maxblocks           1077.0    30585.0      284.0
File Read 4096 bufsize 8000 maxblocks        15382.0   877998.0      570.8
Pipe Throughput                             111814.6  1146617.1      102.5
Pipe-based Context Switching                 15448.6   355382.2      230.0
Process Creation                               569.3    18548.7      325.8
Shell Scripts (8 concurrent)                    44.8     1208.8      269.8
System Call Overhead                        114433.5  2815676.2      246.1
                                                                 =========
     FINAL SCORE                                                     261.2

                     INDEX VALUES            
TEST                                        BASELINE     RESULT      INDEX

Dhrystone 2 using register variables        376783.7  8884179.7      235.8
Double-Precision Whetstone                      83.1     1202.7      144.7
Execl Throughput                               188.3     6543.5      347.5
File Copy 1024 bufsize 2000 maxblocks         2672.0   103051.0      385.7
File Copy 256 bufsize 500 maxblocks           1077.0    32475.0      301.5
File Read 4096 bufsize 8000 maxblocks        15382.0   668682.0      434.7
Pipe Throughput                             111814.6  1269063.8      113.5
Pipe-based Context Switching                 15448.6   357748.7      231.6
Process Creation                               569.3    18862.8      331.3
Shell Scripts (8 concurrent)                    44.8     1206.8      269.4
System Call Overhead                        114433.5  2754854.2      240.7
                                                                 =========
     FINAL SCORE                                                     258.1

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--0OAP2g/MAC+5xKAE--
