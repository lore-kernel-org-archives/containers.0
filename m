From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid 	at once
Date: Tue, 04 Aug 2009 09:09:29 +0800
Message-ID: <4A778A49.6040302@cn.fujitsu.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>	
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>	
	<4A7652E7.4020206@cn.fujitsu.com>
	<2f86c2480908031756j557e7aebmbf7951da6a1aadb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480908031756j557e7aebmbf7951da6a1aadb0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Benjamin Blum wrote:
> On Sun, Aug 2, 2009 at 8:00 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> Ben Blum wrote:
>>> +     }
>>> +     write_unlock(&css_set_lock);
>>> +
>>> +     /*
>>> +      * We just gained a reference on oldcg by taking it from the task. As
>> This comment is incorrect, the ref we just got has been dropped by
>> the above put_css_set(oldcg).
> 
> No, the idea is that even though we had a reference that we already
> dropped, we in effect "traded" the newcg to the task for its oldcg,
> giving it our reference on newcg and gaining its reference on oldcg. I
> believe the cgroup_mutex guarantees that it'll still be there when we
> do the trade - perhaps a BUG_ON(tsk->cgroups != oldcg) is wanted
> inside the second task_lock section there? At the very least, a
> clearer comment.
> 

Maybe my English sucks..

By "gained a reference", doesn't it mean get_css_set()? But this
put_css_set() is not against the get() just called.

And in fact the ref can be 0 before this put(), because task_exit
can drop the last ref, but put_css_set() will check this case,
so it's Ok.

>>> +static int css_set_check_fetched(struct cgroup *cgrp, struct task_struct *tsk,
>>> +                              struct css_set *cg,
>>> +                              struct list_head *newcg_list)
>>> +{
>>> +     struct css_set *newcg;
>>> +     struct cg_list_entry *cg_entry;
>>> +     struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
>>> +     read_lock(&css_set_lock);
>>> +     newcg = find_existing_css_set(cg, cgrp, template);
>>> +     if (newcg)
>>> +             get_css_set(newcg);
>>> +     read_unlock(&css_set_lock);
>>> +     /* doesn't exist at all? */
>>> +     if (!newcg)
>>> +             return 1;
>> I think it's more intuitive to return 1 if found and 0 if not found.
> 
> I was sticking with the convention of nonzero return values indicating
> failure, as is used everywhere else in this context.
> 

Quoted from Documentation/CodingStyle:

...Such a value can be represented as an error-code integer
(-Exxx = failure, 0 = success) or a "succeeded" boolean (0 = failure,
non-zero = success).
