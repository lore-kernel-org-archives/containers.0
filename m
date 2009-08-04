From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Mon, 3 Aug 2009 18:11:01 -0700
Message-ID: <2f86c2480908031811l3374659aq6577189f8e900bc6__14638.2353887477$1249348298$gmane$org@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<4A7652E7.4020206@cn.fujitsu.com>
	<2f86c2480908031756j557e7aebmbf7951da6a1aadb0@mail.gmail.com>
	<6599ad830908031805y31136eceqeff0bab455100d6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908031805y31136eceqeff0bab455100d6c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 3, 2009 at 6:05 PM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Aug 3, 2009 at 5:56 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> No, the idea is that even though we had a reference that we already
>> dropped, we in effect "traded" the newcg to the task for its oldcg,
>> giving it our reference on newcg and gaining its reference on oldcg. I
>> believe the cgroup_mutex guarantees that it'll still be there when we
>> do the trade - perhaps a BUG_ON(tsk->cgroups != oldcg) is wanted
>> inside the second task_lock section there?
>
> I don't think that's safe, since the task could exit and drop its
> reference (and switch to init_css_set).

Yes, but while holding the task's lock while trading the pointers we
first do a PF_EXITING check, so it can't have gone away if we
successfully traded.

>>>
>>> I think it's more intuitive to return 1 if found and 0 if not found.
>>
>> I was sticking with the convention of nonzero return values indicating
>> failure, as is used everywhere else in this context.
>>
>
> Make it a bool, so that it's intuitively more obvious that true==success?

ok.
