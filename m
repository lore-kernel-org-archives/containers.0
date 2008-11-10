From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mm] mm: fine-grained dirty_ratio_pcm and
	dirty_background_ratio_pcm (v2)
Date: Mon, 10 Nov 2008 14:15:29 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0811101410170.2108@chino.kir.corp.google.com>
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>
	<20080912131816.e0cfac7a.akpm@linux-foundation.org>
	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>
	<48EB4236.1060100@linux.vnet.ibm.com> <48EB851D.2030300@gmail.com>
	<20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com>
	<48ECB215.4040409@linux.vnet.ibm.com>
	<48EE236A.90007@gmail.com> <4918A074.1050003@gmail.com>
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
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 10 Nov 2008, Andrea Righi wrote:

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

I think the idea is for a dynamic dirty_ratio based on a static value 
dirty_amount_in_bytes:

	dirtyable_memory = determine_dirtyable_memory() * PAGE_SIZE;
	dirty_ratio = dirty_amount_in_bytes / dirtyable_memory;

> But anytime the dirtyable memory changes (as well as the total memory in
> the system) we should update both values accordingly to preserve the
> coherency between them.
> 

Only dirty_ratio is actually updated if dirty_amount_in_bytes is static.

This allows you to control how many pages are NR_FILE_DIRTY or 
NR_UNSTABLE_NFS and gives you the granularity that you want with 
dirty_ratio_pcm, but on a byte scale instead of percent.

It's also a clean interface:

	echo 200M > /proc/sys/vm/dirty_ratio_bytes
