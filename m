From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] [PATCH -mm] cgroup: limit the amount of dirty file pages
Date: Tue, 09 Sep 2008 18:39:12 +0200
Message-ID: <48C6A6B0.8090606__48816.3348557011$1220978598$gmane$org@gmail.com>
References: <48C6987D.2050905@gmail.com>
	<11118085.1220977593430.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <11118085.1220977593430.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: David Radford <dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, Fernando Luis V?zquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Matt Heaton <matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Naveen Gupta <ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org wrote:
> ----- Original Message -----
>> This is a totally experimental patch against 2.6.27-rc5-mm1.
>>
>> It allows to control how much dirty file pages a cgroup can have at any
>> given time. This feature is supposed to be strictly connected to a
>> generic cgroup IO controller (see below).
>>
>> Interface: a new entry "filedirty" is added to the file memory.stat,
>> reporting the number of dirty file pages (in pages), and a new file
>> memory.file_dirty_limit_in_pages is added in the cgroup filesystem to
>> show/set the current limit.
>>
> Before staring patch review, why not dirty_ratio per memcg ?
> Is there difficult implementation issue ?

mmmh.. maybe it's a bit more complex (would add some overhead?) to
translate the limit from dirty_ratio into pages or bytes, because we
need to evaluate it in function of the per-cgroup dirtyable memory (lru
pages and free pages I suppose). Maybe it's enough to implement it
directly in determine_dirtyable_memory().

I can try to implement it and post a new patch.

-Andrea
