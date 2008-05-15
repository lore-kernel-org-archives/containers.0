From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Thu, 15 May 2008 00:19:39 -0700
Message-ID: <6599ad830805150019v5ba23fe1xe5a6e8b80bc194f5@mail.gmail.com>
References: <6599ad830805140144k583f7426k4024dd17a6cd3eb8@mail.gmail.com>
	<20080515062318.5F1BA5A07@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080515062318.5F1BA5A07-Pcsii4f/SVk@public.gmane.org>
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
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 14, 2008 at 11:23 PM, YAMAMOTO Takashi
<yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
>  > >
>  >
>  > You need to be able to sleep in order to take mmap_sem, right?
>
>  yes.

OK, well in the thread on balbir's vm limit controller, we discussed
the idea of having mmap_sem held across calls to
mm_update_next_owner(), and hence the cgroup callbacks. Would that
help if mmap_sem were already held when you get the mm_owner_changed()
callback.

>
>  > A few comments on the patch:
>  >
>  > - you're not really limiting swap usage, you're limiting swapped-out
>  > address space. So it looks as though if a process has swapped out most
>  > of its address space, and forks a child, the total "swap" charge for
>  > the cgroup will double. Is that correct?
>
>  yes.
>
>
>  > If so, why is this better
>  > than charging for actual swap usage?
>
>  its behaviour is more determinstic and it uses less memory.
>  (than nishimura-san's one, which charges for actual swap usage.)
>

Using less memory is good, but maybe not worth it if the result isn't so useful.

I'd say that it's less deterministic than nishimura-san's controller -
with his you just need to know how much swap is in use (which you can
tell by observing the app on a real system) but with yours you also
have to know whether there are any processes sharing anon pages (but
not mms).

Now it's true that if all the apps you need to run do an execve()
after forking, then the number of swap ptes really does track the
amount of swap space in use pretty accurately, since there's not going
to be any sharing of anon memory between mms. And it might be that
people decide that the reduced memory overhead justifies this
limitation. But I think it should be made explicit in the patch
description and documentation that this controller achieves its
reduced overhead at the cost of giving (IMO) bogus results on a rather
ancient but still perfectly legitimate class of Unix application. (The
apache httpd server used to work this way, for instance. It may still
but I've not looked at it in a while).

>
>  > - what will happen if someone creates non-NPTL threads, which share an
>  > mm but not a thread group (so each of them is a thread group leader)?
>
>  a thread which is most recently assigned to a cgroup will "win".
>

Doesn't that risk triggering the BUG_ON(mm->swap_cgroup != oldscg) in
swap_cgroup_attach() ?

>
>  > - if you were to store a pointer in the page rather than the
>
>  "a pointer"?  a pointer to what?

Oops, sorry - I meant to say "a pointer to the mm". So from there you
can get to mm->owner, and hence to mm->owner->cgroups[swap]

Paul
