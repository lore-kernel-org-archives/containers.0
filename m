From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: ucount: use-after-free read in inc_ucount & dec_ucount
Date: Sun, 05 Mar 2017 12:41:16 -0600
Message-ID: <87y3wjlg6r.fsf@xmission.com>
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
	<CACT4Y+bYAbsxsRWA2o+c7x25f1JPSqZKX-8a8NJq4nab-PyYig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CACT4Y+bYAbsxsRWA2o+c7x25f1JPSqZKX-8a8NJq4nab-PyYig-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Dmitry Vyukov's message of "Sun, 5 Mar 2017 11:53:14 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:
>
> Nice. I think it should work.
>
> I would also do:
>
> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 8a11fc0cb459..233c8e46acd5 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -143,19 +143,18 @@ static struct ucounts *get_ucounts(struct
> user_namespace *ns, kuid_t uid)
>
>                 new->ns = ns;
>                 new->uid = uid;
> -               atomic_set(&new->count, 0);
> +               atomic_set(&new->count, 1);
>
>                 spin_lock_irq(&ucounts_lock);
>                 ucounts = find_ucounts(ns, uid, hashent);
>                 if (ucounts) {
> +                       atomic_inc(&ucounts->count);
>                         kfree(new);
>                 } else {
>                         hlist_add_head(&new->node, hashent);
>                         ucounts = new;
>                 }
>         }
> -       if (!atomic_add_unless(&ucounts->count, 1, INT_MAX))
> -               ucounts = NULL;
>         spin_unlock_irq(&ucounts_lock);
>         return ucounts;
>  }

No.  As that allows ucounts->count to be incremented to the point
it goes negative.  Counter wrap-around is just as bad as imperfect
locking if you can trigger it, and has been a cause of use-after-free
errors etc.

So it is a feature that if the count is maxed out for a given kuid that
get_ucounts will fail.

Eric
