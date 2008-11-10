From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH -mm] mm: fine-grained dirty_ratio_pcm and
	dirty_background_ratio_pcm (v2)
Date: Mon, 10 Nov 2008 14:12:56 -0800
Message-ID: <20081110141256.05214dbe.akpm@linux-foundation.org>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
	<48EB4236.1060100@linux.vnet.ibm.com> <48EB851D.2030300@gmail.com>
	<20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com>
	<48ECB215.4040409@linux.vnet.ibm.com> <48EE236A.90007@gmail.com>
	<4918A074.1050003@gmail.com>
	<20081110131255.ce71ce60.akpm@linux-foundation.org>
	<4918AFA1.4000102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4918AFA1.4000102-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 10 Nov 2008 23:03:13 +0100
Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On 2008-11-10 22:12, Andrew Morton wrote:
> > On Mon, 10 Nov 2008 21:58:28 +0100
> > Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > 
> >> The current granularity of 5% of dirtyable memory for dirty pages writeback is
> >> too coarse for large memory machines and this will get worse as
> >> memory-size/disk-speed ratio continues to increase.
> >>
> >> These large writebacks can be unpleasant for desktop or latency-sensitive
> >> environments, where the time to complete each writeback can be perceived as a
> >> lack of responsiveness by the whole system.
> >>
> >> Following there's a similar solution as discussed in [1], but a little
> >> bit simplified in order to provide the same functionality (in particular
> >> to avoid backward compatibility problems) and reduce the amount of code
> >> needed to implement an in-kernel parser to handle percentages with
> >> decimals digits.
> >>
> >> The kernel provides the following parameters:
> >>  - dirty_ratio, dirty_background_ratio in percentage (1 ... 100)
> >>  - dirty_ratio_pcm, dirty_background_ratio_pcm in units of percent mille (1 ... 100,000)
> > 
> > hm, so how long until dirty_ratio_pcm becomes too coarse...
> > 
> > What happened to the idea of specifying these in units of kilobytes?
> 
> The conclusion was that with units in KB requires much more complexity
> to keep in sync the old dirty_ratio (and dirty_background_ratio)
> interface with the new one.
> 
> The KB limit is a static value, the other depends on the dirtyable
> memory. If we want to preserve the same behaviour we should do the
> following:
> 
> - when dirty_ratio changes to x:
>   dirty_amount_in_bytes = x * dirtyable_memory / 100.
> 
> - when dirty_amount_in_bytes changes to x:
>   dirty_ratio = x / dirtyable_memory * 100
> 
> But anytime the dirtyable memory changes (as well as the total memory in
> the system) we should update both values accordingly to preserve the
> coherency between them.

OK.

> I wonder if setting also PERCENT_PCM (that is 1% expressed in
> fine-grained units) as a parameter could be a better long-term solution.
> And also use another name for it, because in this case this would be not
> a milli-percent value anymore.

How about we forget the percentage thing and create
/proc/sys/vm/dirty_ratio_millionths?  That will give us a few more years
of moores_law(memory size)/mores_law(disk speed) too..  
