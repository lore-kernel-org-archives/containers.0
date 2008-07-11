From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Transactional CGroup task attachment
Date: Fri, 11 Jul 2008 13:41:34 -0700
Message-ID: <6599ad830807111341x7cbe91c0k777e72840fe969a1@mail.gmail.com>
References: <6599ad830807092346j1fdb2ef9l2ca2b52e2e68096a@mail.gmail.com>
	<48778677.3040308@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48778677.3040308-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "\"Daisuke Miyakawa (?? ??)\"" <dmiyakawa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 11, 2008 at 9:12 AM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> This would ideally be recursive mutexes, Linus does not like recursive mutexes.

But we already have them in function, if not in name, with things like
cpu_hotplug.lock, which is an open-coded reader-writer mutex with
recursion.

>>
>> int prepare_attach_sleep(struct cgroup_attach_state *state);
>>
>
> Is _sleep really required to be specfied? The function name sounds as if the
> callback processor will sleep.

I wasn't quite sure about the name of that method either. We could
call it prepare_attach_maysleep(); just prepare_attach() seems a
little under-descriptive.

>> Called with group_mutex (which prevents any other task movement
>> between cgroups) held plus any mutexes/semaphores taken by earlier
>> subsystems's callbacks.
>>
>
> This sounds almost like the BKL for cgroups :)

Yes, cgroup_mutex is indeed currently the BKL for cgroups. I'm working
separately to reduce that with things like the per-subsystem
hierarchy_mutex, which will also protect against task movements.

>
> 1. Prepare_attach() the subsystem does it's or fails

Did you miss a word here?

> 2. If someone failed, send out failed notifications to successfull callbacks
> 3. On receiving a failed notification (due to a different cgroup failure),
> clients undo their operation (done in prepare_attach())
> 4. If all was successful, move the task and call attached() after the task is
> attached.

That's pretty much what we have - except that I've got two
prepare_attach() methods to handle the case that some subsystems might
need mutexes and others might need spinlocks in order to handle
synchronization between the move and their resource charge/uncharge
mechanisms - because any mutexes (and memory allocations) need to be
handled before spinlocks.

>
> I read through the rest of it. The sleep/nosleep might make sense (to help the
> task acquire the type of lock it wants to acquire), but isn't sleep a generic
> case for nosleep as well?

Can you clarify what you mean by that?

Paul
