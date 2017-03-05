From: Dmitry Vyukov via Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Subject: Re: ucount: use-after-free read in inc_ucount & dec_ucount
Date: Sun, 5 Mar 2017 11:53:14 +0100
Message-ID: <CACT4Y+bYAbsxsRWA2o+c7x25f1JPSqZKX-8a8NJq4nab-PyYig@mail.gmail.com>
References: <C4CB953C-4712-43F3-9E75-1A12C14B8A4B@gmail.com>
	<180fb7dc-790e-8e82-0cc1-c6e15ddcd20b@gmail.com>
	<87pohy1fx6.fsf@xmission.com>
	<1aafd5e9-d9de-e5d9-a77d-cf245c5a5c6a@gmail.com>
	<CACT4Y+a043_qFN=2uzvYhDFwF4JS9_p3jnOykpMk=RcpqQfKGQ@mail.gmail.com>
	<CACT4Y+Yev63VXYm+kZdii5kheV_ACBn2cehFcFdz6LBVam3Q2g@mail.gmail.com>
	<CACT4Y+b7YXnoOkdYTjp6D6XH-zuYRx063hMayOVMyJVc735dtQ@mail.gmail.com>
	<c69f8f03-4324-f934-eed2-643c91d703c0@gmail.com>
	<CACT4Y+avCy8Susvb09DLHkGym0K_15+EeZ8yBH7tcgjvnb3Yhw@mail.gmail.com>
	<CACT4Y+YWEq66QXbTMR4yGtgc0ULN+TurAnRzcDASaja1z5XNjA@mail.gmail.com>
	<87shmsoar7.fsf@xmission.com>
Reply-To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87shmsoar7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Mar 5, 2017 at 12:58 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:
>
>> On Sat, Mar 4, 2017 at 1:15 PM, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>> On Sat, Mar 4, 2017 at 1:10 PM, Nikolay Borisov
>>> <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>
>>>>
>>>> On  4.03.2017 14:01, Dmitry Vyukov wrote:
>>>>> On Sat, Mar 4, 2017 at 12:50 PM, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>>>>>> <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>>>> [Addressing Dmitry Vyukov to ask for syzkaller clarification]
>>>>>>>>
>>>>>>>> On  3.03.2017 18:30, Eric W. Biederman wrote:
>>>>>>>>> Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>>>>>>
>>>>>>>>>> [Added containers ml, Eric Biederman and Jan Kara]. Please,
>>>>>>>>>> next time don't add random people but take the time to see who touched
>>>>>>>>>> the code.
>>>>>>>>>
>>>>>>>>> Comments below.
>>>>>>>>>
>>>>>>>>>> On  3.03.2017 14:16, JongHwan Kim wrote:
>>>>>>>>>>> I've got the following report with syzkaller fuzzer
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> Syzkaller hit 'KASAN: use-after-free Read in dec_ucount' bug on commit .
>>>>>>>>>>>
>>>>>>>>>>> ==================================================================
>>>>>>>>>>> BUG: KASAN: use-after-free in __read_once_size
>>>>>>>>>>> include/linux/compiler.h:254 [inline] at addr ffff88006d399bc4
>>>>>>>>>>> BUG: KASAN: use-after-free in atomic_read
>>>>>>>>>>> arch/x86/include/asm/atomic.h:26 [inline] at addr ffff88006d399bc4
>>>>>>>>>>> BUG: KASAN: use-after-free in atomic_dec_if_positive
>>>>>>>>>>> include/linux/atomic.h:616 [inline] at addr ffff88006d399bc4
>>>>>>>>>>> BUG: KASAN: use-after-free in dec_ucount+0x1e5/0x210 kernel/ucount.c:217
>>>>>>>>>>> at addr ffff88006d399bc4
>>>>>>>>>>> Read of size 4 by task syz-executor3/19713
>>>>>>>>>>> CPU: 1 PID: 19713 Comm: syz-executor3 Not tainted 4.10.0+ #4
>>>>>>>>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>>>>>>>>>>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>>>>>>>>>>> Call Trace:
>>>>>>>>>>>  __dump_stack lib/dump_stack.c:15 [inline]
>>>>>>>>>>>  dump_stack+0x115/0x1cf lib/dump_stack.c:51
>>>>>>>>>>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>>>>>>>>>>>  print_address_description mm/kasan/report.c:200 [inline]
>>>>>>>>>>>  kasan_report_error mm/kasan/report.c:289 [inline]
>>>>>>>>>>>  kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
>>>>>>>>>>>  kasan_report mm/kasan/report.c:331 [inline]
>>>>>>>>>>>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:331
>>>>>>>>>>>  __read_once_size include/linux/compiler.h:254 [inline]
>>>>>>>>>>>  atomic_read arch/x86/include/asm/atomic.h:26 [inline]
>>>>>>>>>>>  atomic_dec_if_positive include/linux/atomic.h:616 [inline]
>>>>>>>>>>>  dec_ucount+0x1e5/0x210 kernel/ucount.c:217
>>>>>>>>>>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>>>>>>>>>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>>>>>>>>>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>>>>>>>>>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>>>>>>>>>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>>>>>>>>>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>>>>>>>>>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>>>>>>>>>>  ____fput+0x15/0x20 fs/file_table.c:244
>>>>>>>>>>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>>>>>>>>>>  exit_task_work include/linux/task_work.h:21 [inline]
>>>>>>>>>>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>>>>>>>>>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>>>>>>>>>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>>>>>>>>>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>>>>>>>>>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>>>>>>>>>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>>>>>>>>>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>>>>>>>>>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>>>>>>>>>>
>>>>>>>>>> So PID 19713 is exitting and as part of it it's freeing its file
>>>>>>>>>> descriptors, one of which is apparently an inotify fd. And this has
>>>>>>>>>> already been freed.
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>> RIP: 0033:0x44fb79
>>>>>>>>>>> RSP: 002b:00007ffd0f00f6d8 EFLAGS: 00000206 ORIG_RAX: 00000000000000ca
>>>>>>>>>>> RAX: fffffffffffffdfc RBX: 0000000000708024 RCX: 000000000044fb79
>>>>>>>>>>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708024
>>>>>>>>>>> RBP: 00000000000ae8e6 R08: 0000000000708000 R09: 000000160000000d
>>>>>>>>>>> R10: 00007ffd0f00f710 R11: 0000000000000206 R12: 0000000000708000
>>>>>>>>>>> R13: 0000000000708024 R14: 00000000000ae8a1 R15: 0000000000000016
>>>>>>>>>>> Object at ffff88006d399b88, in cache kmalloc-96 size: 96
>>>>>>>>>>> Allocated:
>>>>>>>>>>> PID = 19691
>>>>>>>>>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>>>>>>>>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>>>>>>>>>>  set_track mm/kasan/kasan.c:514 [inline]
>>>>>>>>>>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
>>>>>>>>>>>  kmem_cache_alloc_trace+0xfb/0x280 mm/slub.c:2745
>>>>>>>>>>>  kmalloc include/linux/slab.h:490 [inline]
>>>>>>>>>>>  kzalloc include/linux/slab.h:663 [inline]
>>>>>>>>>>>  get_ucounts kernel/ucount.c:140 [inline]
>>>>>>>>>>>  inc_ucount+0x538/0xa70 kernel/ucount.c:195
>>>>>>>>>>>  inotify_new_group+0x309/0x410 fs/notify/inotify/inotify_user.c:655
>>>>>>>>>>>  SYSC_inotify_init1 fs/notify/inotify/inotify_user.c:682 [inline]
>>>>>>>>>>>  SyS_inotify_init1 fs/notify/inotify/inotify_user.c:669 [inline]
>>>>>>>>>>>  sys_inotify_init+0x17/0x80 fs/notify/inotify/inotify_user.c:696
>>>>>>>>>>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>>>>>>>
>>>>>>>>>> However, it has been actually allocated by a different process with pid
>>>>>>>>>> 19691.
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>> Freed:
>>>>>>>>>>> PID = 19708
>>>>>>>>>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>>>>>>>>>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>>>>>>>>>>>  set_track mm/kasan/kasan.c:514 [inline]
>>>>>>>>>>>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
>>>>>>>>>>>  slab_free_hook mm/slub.c:1357 [inline]
>>>>>>>>>>>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>>>>>>>>>>>  slab_free mm/slub.c:2961 [inline]
>>>>>>>>>>>  kfree+0xe8/0x2c0 mm/slub.c:3882
>>>>>>>>>>>  put_ucounts+0x1dd/0x270 kernel/ucount.c:172
>>>>>>>>>>>  dec_ucount+0x172/0x210 kernel/ucount.c:220
>>>>>>>>>>>  dec_inotify_instances fs/notify/inotify/inotify.h:37 [inline]
>>>>>>>>>>>  inotify_free_group_priv+0x6c/0x80 fs/notify/inotify/inotify_fsnotify.c:169
>>>>>>>>>>>  fsnotify_final_destroy_group fs/notify/group.c:37 [inline]
>>>>>>>>>>>  fsnotify_put_group+0x73/0xa0 fs/notify/group.c:110
>>>>>>>>>>>  fsnotify_destroy_group+0xec/0x120 fs/notify/group.c:93
>>>>>>>>>>>  inotify_release+0x37/0x50 fs/notify/inotify/inotify_user.c:280
>>>>>>>>>>>  __fput+0x327/0x7e0 fs/file_table.c:208
>>>>>>>>>>>  ____fput+0x15/0x20 fs/file_table.c:244
>>>>>>>>>>>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>>>>>>>>>>>  exit_task_work include/linux/task_work.h:21 [inline]
>>>>>>>>>>>  do_exit+0xa45/0x1b20 kernel/exit.c:873
>>>>>>>>>>>  do_group_exit+0x149/0x400 kernel/exit.c:977
>>>>>>>>>>>  get_signal+0x7d5/0x1810 kernel/signal.c:2313
>>>>>>>>>>>  do_signal+0x94/0x1f30 arch/x86/kernel/signal.c:807
>>>>>>>>>>>  exit_to_usermode_loop+0x162/0x1e0 arch/x86/entry/common.c:156
>>>>>>>>>>>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>>>>>>>>>>>  syscall_return_slowpath+0x2b6/0x310 arch/x86/entry/common.c:259
>>>>>>>>>>>  entry_SYSCALL_64_fastpath+0xc0/0xc2
>>>>>>>>>>
>>>>>>>>>> And yet we have a third process which freed it, PID 19708. So there is
>>>>>>>>>> some dance happening with this fd, being allocated by one process,
>>>>>>>>>> handed over to 2 more, which are freeing it. Is this a valid usage
>>>>>>>>>> scenario of inotify descriptors?
>>>>>>>>>
>>>>>>>>> They are file descriptors so passing them around is valid.  That is
>>>>>>>>> something unix domain sockets have allowed since the dawn of linux.
>>>>>>>>>
>>>>>>>>> The dance would need to be the fd being passed to the addtional
>>>>>>>>> processes and then closed in the original before being closed
>>>>>>>>> in the processes the fd was passed to.
>>>>>>>>>
>>>>>>>>> If those additional processes last longer than the original process this
>>>>>>>>> is easy to achieve.
>>>>>>>>>
>>>>>>>>> My guess is that someone just taught syskallzer to pass file descriptors
>>>>>>>>> around.  So this may be an old bug.  Either that or syskallzer hasn't
>>>>>>>>> been looking at linux-next with KASAN enabled in the kernel.
>>>>>>>>
>>>>>>>> Dmitry, can you tell if syzkaller tests sending file descriptors across
>>>>>>>> sockets? Since the calltraces here show multiple processes being
>>>>>>>> involved in different operations on the exact same file descriptor.
>>>>>>>>
>>>>>>>> Also JongHwan, can you provide the full, compilable reproducer to try
>>>>>>>> and track this issue down?
>>>>>>>
>>>>>>>
>>>>>>> syzkaller can pass descriptors across sockets, but currently only
>>>>>>> within a single multi-threaded process.
>>>>>>>
>>>>>>> Are you sure it's the same descriptor? It seems to me that it's struct
>>>>>>> ucounts, which is shared via the global ucounts_hashtable, so no
>>>>>>> sharing is required in user processes.
>>>>>>>
>>>>>>> Unless I am missing something, we want:
>>>>>>>
>>>>>>> @@ -154,7 +155,7 @@ static struct ucounts *get_ucounts(struct
>>>>>>> user_namespace *ns, kuid_t uid)
>>>>>>>                         ucounts = new;
>>>>>>>                 }
>>>>>>>         }
>>>>>>> -       if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
>>>>>>> +       if (!atomic_add_unless(&ucounts->count, 1, 0))
>>>>>>>                 ucounts = NULL;
>>>>>>>         spin_unlock_irq(&ucounts_lock);
>>>>>>>         return ucounts;
>>>>>>>
>>>>>>> no?
>>>>>>>
>>>>>>> put_ucounts drops the last reference, then get_ucounts finds the
>>>>>>> ucounts and successfully increments refcount as it's not INT_MAX (it's
>>>>>>> 0) and starts using it, meanwhile put_ucounts proceeds to
>>>>>>> unconditionally deleting the ucounts.
>>>>>>
>>>>>>
>>>>>> It also seems that a concurrent put_ucounts can make get_ucounts fail
>>>>>> _spuriously_, which does not look good.
>>>>>> Don't we want something along the following lines?
>>>>>>
>>>>>> diff --git a/kernel/ucount.c b/kernel/ucount.c
>>>>>> index 8a11fc0cb459..233c8e46acd5 100644
>>>>>> --- a/kernel/ucount.c
>>>>>> +++ b/kernel/ucount.c
>>>>>> @@ -143,19 +143,18 @@ static struct ucounts *get_ucounts(struct
>>>>>> user_namespace *ns, kuid_t uid)
>>>>>>
>>>>>>                 new->ns = ns;
>>>>>>                 new->uid = uid;
>>>>>> -               atomic_set(&new->count, 0);
>>>>>> +               atomic_set(&new->count, 1);
>>>>>>
>>>>>>                 spin_lock_irq(&ucounts_lock);
>>>>>>                 ucounts = find_ucounts(ns, uid, hashent);
>>>>>>                 if (ucounts) {
>>>>>> +                       atomic_inc(&ucounts->count);
>>>>>>                         kfree(new);
>>>>>>                 } else {
>>>>>>                         hlist_add_head(&new->node, hashent);
>>>>>>                         ucounts = new;
>>>>>>                 }
>>>>>>         }
>>>>>> -       if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
>>>>>> -               ucounts = NULL;
>>>>>>         spin_unlock_irq(&ucounts_lock);
>>>>>>         return ucounts;
>>>>>>  }
>>>>>> @@ -166,7 +165,10 @@ static void put_ucounts(struct ucounts *ucounts)
>>>>>>
>>>>>>         if (atomic_dec_and_test(&ucounts->count)) {
>>>>>>                 spin_lock_irqsave(&ucounts_lock, flags);
>>>>>> -               hlist_del_init(&ucounts->node);
>>>>>> +               if (atomic_read(&ucounts->count) == 0)
>>>>>> +                       hlist_del_init(&ucounts->node);
>>>>>> +               else
>>>>>> +                       ucounts = NULL;
>>>>>>                 spin_unlock_irqrestore(&ucounts_lock, flags);
>>>>>>
>>>>>>                 kfree(ucounts);
>>>>>
>>>>>
>>>>> /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
>>>>>
>>>>> This is broken per se. Need something more elaborate.
>>>>>
>>>>
>>>>
>>>> How about this :
>>>>
>>>> diff --git a/kernel/ucount.c b/kernel/ucount.c
>>>> index 8a11fc0cb459..b817ac0e587c 100644
>>>> --- a/kernel/ucount.c
>>>> +++ b/kernel/ucount.c
>>>> @@ -166,11 +166,15 @@ static void put_ucounts(struct ucounts *ucounts)
>>>>
>>>>         if (atomic_dec_and_test(&ucounts->count)) {
>>>>                 spin_lock_irqsave(&ucounts_lock, flags);
>>>> -               hlist_del_init(&ucounts->node);
>>>> -               spin_unlock_irqrestore(&ucounts_lock, flags);
>>>> -
>>>> -               kfree(ucounts);
>>>> +               if (!atomic_read(&ucounts->count)) {
>>>> +                       hlist_del_init(&ucounts->node);
>>>> +                       spin_unlock_irqrestore(&ucounts_lock, flags);
>>>> +                       kfree(ucounts);
>>>> +                       return;
>>>> +               }
>>>>         }
>>>> +
>>>> +       spin_unlock_irqrestore(&ucounts_lock, flags);
>>>>  }
>>>>
>>>>
>>>>
>>>> This makes the atomic_dec_and_test and hashtable removal atomic in essence.
>>>
>>>
>>> This won't work.
>>> Consider the following scenario:
>>> Thread 0 decrements count to 0 here:
>>>   if (atomic_dec_and_test(&ucounts->count)) {
>>> Then thread 1 calls get_ucounts, increments count to 1, then calls
>>> put_ucounts, decrements count to 0 and unhashes and frees ucounts.
>>> Not thread 0 does:
>>>   if (!atomic_read(&ucounts->count)) {
>>> but ucounts is already freed!
>>
>>
>> What may work is if put_ucounts re-lookups the ucounts. If it can
>> still find it and count==0, then it is the right time to delete it. If
>> it can't find the ucounts, then somebody else has beaten it.
>
> I believe what we want is atomic_dec_and_lock_irqsave.
>
> As that does not exist we can just do:
>
> @@ -164,13 +164,16 @@ static void put_ucounts(struct ucounts *ucounts)
>  {
>         unsigned long flags;
>
> +       /* Unless the count is 1 decrement the quick way */
> +       if (atomic_add_unless(&ucounts->count, -1, 1))
> +               return;
> +
> +       spin_lock_irqsave(&ucounts_lock, flags);
>         if (atomic_dec_and_test(&ucounts->count)) {
> -               spin_lock_irqsave(&ucounts_lock, flags);
>                 hlist_del_init(&ucounts->node);
> -               spin_unlock_irqrestore(&ucounts_lock, flags);
> -
>                 kfree(ucounts);
>         }
> +       spin_unlock_irqrestore(&ucounts_lock, flags);
>  }

Nice. I think it should work.

I would also do:

diff --git a/kernel/ucount.c b/kernel/ucount.c
index 8a11fc0cb459..233c8e46acd5 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -143,19 +143,18 @@ static struct ucounts *get_ucounts(struct
user_namespace *ns, kuid_t uid)

                new->ns = ns;
                new->uid = uid;
-               atomic_set(&new->count, 0);
+               atomic_set(&new->count, 1);

                spin_lock_irq(&ucounts_lock);
                ucounts = find_ucounts(ns, uid, hashent);
                if (ucounts) {
+                       atomic_inc(&ucounts->count);
                        kfree(new);
                } else {
                        hlist_add_head(&new->node, hashent);
                        ucounts = new;
                }
        }
-       if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
-               ucounts = NULL;
        spin_unlock_irq(&ucounts_lock);
        return ucounts;
 }



>  static inline bool atomic_inc_below(atomic_t *v, int u)
>
>
> AKA take the spin_lock around the dec_and_test.
>
> Arguably always decrementing under the ucounts_lock that means we can
> stop reduce ucounts->count to a simple integer and just always take the
> lock.  Thus reducing our number of atomic operations and speeding up the
> code a little.
>
> But that might be a bit much for a simple bug fix.
>
> If you folks can verify the fix above closes the race and stops the
> problems I would appreciate it.
