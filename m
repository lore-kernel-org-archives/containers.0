From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [0/5] (Does anyone have an idea about throttling ?)
Date: Fri, 30 Nov 2007 09:29:11 +0900
Message-ID: <20071130092911.e4a98770.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129205324.f9e7ab4e.kamezawa.hiroyu@jp.fujitsu.com>
	<474ECFEB.9090202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474ECFEB.9090202-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Lee Schermerhorn <Lee.Schermerhorn-VXdhtT5mjnY@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 29 Nov 2007 20:12:51 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > == These numbers are stable to some extent.==
> > 2.6.24-rc3-mm2: (Limit: 800M)     
> > Average Optimal -j 32 Load Run:
> > Elapsed Time 358.933---------------------------(*)
> > User Time 1069.63
> > System Time 140.667
> > Percent CPU 337.333
> > Context Switches 220821
> > Sleeps 196912
> > 
> > 2.6.24-rc3-mm2 + throttle (Limit:800M)
> > Average Optimal -j 32 Load Run:
> > Elapsed Time 266.697---------------------------(*)
> > User Time 1105.39
> > System Time 124.423
> > Percent CPU 471.667
> > Context Switches 251797
> > Sleeps 231038
> > 
> > 2.6.24-rc3-mm2 + throttle + High/Low watermark.
> > (low:750M High:780M Limit:800M)
> > Average Optimal -j 32 Load Run:
> > Elapsed Time 266.844---------------------------(*)
> > User Time 1112.9
> > System Time 112.273
> > Percent CPU 473.667
> > Context Switches 251795
> > Sleeps 220339
> > ==
> > 
> 
> Looks good to me, was there any impact on memory.failcnt?
> 
This version o patch doesn't care it. (I'll fix.)
I just wanted to ask someone has (another) throttling patch or idea.

> > Seems throttling reclaim has some good effect (for kernbench).
> > Does anyone have an idea for throttling  reclaiming of memory controller ?
> > 
> 
> In the past I've run workloads of apache+geronimo+open trade, I've run
> linear sequential memory access tests, kernbench, lmbench, database
> benchmarks (DOTS, pgbench, etc). I think Lee Schermerhorn has a very
> interesting setup (that I need to learn to replicate).
> 
Ok, thanks.
I will reflesh and post new one.


Regards
-Kame
