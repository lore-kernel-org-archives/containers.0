From: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Subject: Re: [Devel] Re: [lxc-devel] Containerized syslog
Date: Wed, 26 May 2010 16:25:15 +0200
Message-ID: <20100526142515.GA31480@nibiru.local>
References: <4BEAC1E8.1070506@univ-nantes.fr> <4BEB1A59.6010905@free.fr>
Reply-To: weigelt-EU+a56NjgY8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BEB1A59.6010905-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

* Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> schrieb:

> I thing a consensus was not reach. The big deal with syslog is netfilter 
> logs in an interrupt context where it is difficult to find the right log 
> buffer ring as we are not in the process context making possible to 
> identify the namespace.

That's one of the BIG problems in the Linux kernel, we've recently
stumbled with in another project (artificial disk bw limits): 
far too much happening within interrupt context. 

Interrupts were originally as _short time_ step-ins for time critical 
signaling. What's happening here is an abuse of that concept, w/ really
bad implications (eg. arbitrary users can create loads to bring down 
the whole system on extreme load). A clean and more robust solution 
IMHO could be that the interrupt handler only loads the received l1 
frames and enqueue them for an kernel thread (or multiple ones) - an 
containerized setup then would have separate queues and kthreads on 
per-container basis.


cu
-- 
---------------------------------------------------------------------
 Enrico Weigelt    ==   metux IT service - http://www.metux.de/
---------------------------------------------------------------------
 Please visit the OpenSource QM Taskforce:
 	http://wiki.metux.de/public/OpenSource_QM_Taskforce
 Patches / Fixes for a lot dozens of packages in dozens of versions:
	http://patches.metux.de/
---------------------------------------------------------------------
