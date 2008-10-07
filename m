From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [PATCH -mm 0/2] memcg: per cgroup dirty_ratio
Date: Tue, 07 Oct 2008 16:34:22 +0530
Message-ID: <48EB4236.1060100__42009.3805682429$1223377682$gmane$org@linux.vnet.ibm.com>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <532480950809221641y3471267esff82a14be8056586-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Michael Rubin wrote:
> On Fri, Sep 12, 2008 at 1:18 PM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>> One thing to think about please: Michael Rubin is hitting problems with
>> the existing /proc/sys/vm/dirty-ratio.  Its present granularity of 1%
>> is just too coarse for really large machines, and as
>> memory-size/disk-speed ratios continue to increase, this will just get
>> worse.
> 
> Re-sending since I top-posted before. Never again. Also adding more
> thoughts on a byte based interface.
> 
> Currently the problem we are hitting is that we cannot specify pdflush
> to have background limits less than 1% of memory. I am currently
> finishing up a patch right now that adds a dirty_ratio_millis
> interface.  I hope to submit the patch to LKML by the end of the week.
> 
> The idea is that we don't want to break backwards compatibility and we
> also don't want to have two conflicting knobs in the sysctl or
> /proc/sys/vm/ space. I thought adding a new knob for those who want to
> specify finer grained functionality was a compromise. So the patch has
> a vm_dirty_ratio and a vm_dirty_ratio_millis interface. The first to
> specify 0-100% and the second to specify .0 to .999%.
> 
> So to represent 0.125% of RAM we set
> vm_dirty_ratio = 0
> vm_dirty_ratio_millis = 125
> 
> The same for the background_ratio.
> 
> I would also prefer using a bytes interface but I am not sure how to
> offer that without  either removing the legacy interface of the ratios
> or by offering a concurrent interface that might be confusing such as
> when users are looking at the old one and not aware of a new one.
> 

Just provide a vm_dirty_ration_in_bytes interface and keep it in sync with
vm_dirty_ratio (they are just two representations of the same internal value)
and for higher resolution propose that users use the bytes interface.



-- 
	Balbir
