From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 8/9] [RFC] Example multi-bindable subsystem: a per-cgroup
	notes field
Date: Thu, 2 Jul 2009 00:22:43 -0700
Message-ID: <6599ad830907020022y106a2d8epf78d8ce67ebe7c9a@mail.gmail.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021133.14469.35140.stgit@menage.mtv.corp.google.com>
	<20090702114829.df04c885.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907011956i33769d5ek5401e93553d75c59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907011956i33769d5ek5401e93553d75c59-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 1, 2009 at 7:56 PM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> Hmm, do we need to this "info" file as subsys ? How about making this as
>> default file set ? (if there are users.)
>>
>
> That would certainly be possible, and would be an alternative to
> having multi-bindable subsystem support.
>
> The advantage of adding multi-bindable subsystems is that you can
> avoid bloating the core cgroups code, by putting individual small
> cgroups features in their own code modules, and you get to decide at
> mount time which features are actually mounted; if they were part of
> the core cgroups files, then there would either need to be special
> mount options for each separate feature, or else no way to pick which
> features were mounted on each hierarchy.

BTW, just to give a balanced argument: I agree that these example
multi-bindable subsystems are somewhat weak justifications for the new
feature - they each supply a single control file, they're not
connected to anything in the kernel outside of the core cgroups
framework, and they're almost zero overhead if they're not actively
used, so making them part of the cgroups framework directly wouldn't
be totally unreasonable.

An example of a less-trivial multi-bindable subsystem could be cpuacct
- logically there's no reason that you couldn't track CPU usage in
multiple different hierarchies, keeping totals aggregated in different
ways for the groupings in different hierarchies, and the overhead
associated with tracking would mean that you wouldn't want to
automatically link cpuacct into every hierarchy. The practical problem
with this would be that finding the cgroup for a process would be
slower since there wouldn't be a 1:1 mapping from a task to a cpuacct
cgroup state object.

Instead each task would have multiple such states and to update the
usage accounting on each of them you'd have to do a list traversal
rather than a direct lookup (and worse, right now that list traversal
can only be done while holding cgroup_mutex, which is impossible when
doing cpuacct charging from the guts of the scheduler). I can see how
to extend the multi-bindable support to make it cheaper and to require
less synchronization (i.e. walking an RCU-safe array to find the
various state objects rather than doing a list traversal).

Although before doing that I guess it would be worth asking whether
anyone would actually *want* to aggregate CPU usage different ways for
different hierarchies, even if it makes logical sense to be able to do
so.

Paul
