From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Mon, 18 Feb 2008 10:19:08 +0100
Message-ID: <47B94D8C.8040605__49508.5936425768$1203326586$gmane$org@bull.net>
References: <20080211141646.948191000@bull.net>	<20080211141813.354484000@bull.net>
	<20080215215916.8566d337.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080215215916.8566d337.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Mon, 11 Feb 2008 15:16:47 +0100 Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
> 
> 
>>[PATCH 01/08]
>>
>>This patch computes msg_ctlmni to make it scale with the amount of lowmem.
>>msg_ctlmni is now set to make the message queues occupy 1/32 of the available
>>lowmem.
>>
>>Some cleaning has also been done for the MSGPOOL constant: the msgctl man page
>>says it's not used, but it also defines it as a size in bytes (the code
>>expresses it in Kbytes).
>>
> 
> 
> Something's wrong here.  Running LTP's msgctl08 (specifically:
> ltp-full-20070228) cripples the machine.  It's a 4-way 4GB x86_64.
> 
> http://userweb.kernel.org/~akpm/config-x.txt
> http://userweb.kernel.org/~akpm/dmesg-x.txt
> 
> Normally msgctl08 will complete in a second or two.  With this patch I
> don't know how long it will take to complete, and the machine is horridly
> bogged down.  It does recover if you manage to kill msgctl08.  Feels like
> a terrible memory shortage, but there's plenty of memory free and it isn't
> swapping.
> 
> 
> 

Before the patchset, msgctl08 used to be run with the old msgmni value: 
16. Now it is run with a much higher msgmni value (1746 in my case), 
since it scales to the memory size.
When I call "msgctl08 100000 16" it completes fast.

Doing the follwing on the ref kernel:
echo 1746 > /proc/sys/kernel/msgmni
msgctl08 100000 1746

makes th test block too :-(

Will check to see where the problem comes from.

Rgards,
Nadia
