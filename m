From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Tue, 14 Jul 2009 12:46:17 +0530
Message-ID: <20090714071617.GK5051__45427.6603334167$1247555820$gmane$org@balbir.in.ibm.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090705063850.GX11273@balbir.in.ibm.com>
	<6599ad830907101658i13e4046br70377a487dd6b49b@mail.gmail.com>
	<20090713121138.GC5051@balbir.in.ibm.com>
	<6599ad830907130926v7788af12hdcd76e4ccb3ab6de@mail.gmail.com>
	<20090714055638.GI5051@balbir.in.ibm.com>
	<6599ad830907132349u6cf52060t4fafb6637cbe4ed1@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830907132349u6cf52060t4fafb6637cbe4ed1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-07-13 23:49:16]:

> On Mon, Jul 13, 2009 at 10:56 PM, Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >>
> >> Waiting for the next scheduling point might be too long, since a
> >> thread can block for arbitrary amounts of time and keeping the marker
> >> around for arbitrary time (unless we add a new task_struct field)
> >> would be tricky. Marking the cgroup or tgid as being migrated which
> >> then triggers the extra synchronization in the fork path (but which
> >> isn't needed at other times) is probably where we'll end up.
> >
> >
> > Hmm... but we would not need that information till we schedule the
> > tasks, adding a field to task_struct is what I had in mind.
> 
> Waiting until schedule to move the threads would result in them still
> showing up in the old "tasks" file until they next ran, which would be
> confusing and misleading.
>

Yes, agreed, even first access to the data struture based lazy
migration might not be too helpful, since it can be very context
dependent.
 
> As a first cut, we were planning to add an rwsem that gets taken for
> read in cgroup_fork(), released in cgroup_post_fork(), and taken for
> write when moving an entire process to a new cgroup; not ideal
> performance-wise, but safe.
> 
> If adding a field to task_struct is an option, then the rwsem could be
> per thread-group leader, which would reduce contention.
>

We should also document that moving large processes with several
threads can be expensive.
 

-- 
	Balbir
