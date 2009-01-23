From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: commit 7534432dcc3c654a8671b6b0cdffd1dbdbc73074
Date: Thu, 22 Jan 2009 17:31:06 -0800
Message-ID: <6599ad830901221731r31b17404xea454d0e9943ddcd@mail.gmail.com>
References: <20090122184754.GA17511@us.ibm.com>
	<6599ad830901221507x796c154ck5fe4f95cc3eb8e0e@mail.gmail.com>
	<6599ad830901221535w6c723eb6xd0adced0ff6a1fb6@mail.gmail.com>
	<6599ad830901221626o2fd5025fib3c1c6d182e52e63@mail.gmail.com>
	<1232673997.8007.183.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1232673997.8007.183.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 22, 2009 at 5:26 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>        I see what you mean. I am still mystified how rcu_read_lock() around
> the cgroup iterator in cgroupstats_build() hid/prevented the problem
> though :/.

I think the problem was in git bisect - the problematic commit was a
couple later than the one Serge pointed at.

>
>        Incrementing the root_count early dissociates root_count and the
> addition to root list, doesn't it? How about only decrementing the count
> if we're on the list as in the patch below?

That's basically the patch that I already sent out. That check was
there originally, but removed in
e5f6a8609bab0c2d7543ab1505105e011832afd7 as a "redundant check".

Paul
