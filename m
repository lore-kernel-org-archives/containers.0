From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Possible race between cgroup_attach_proc and de_thread, and
	questionable code in de_thread.
Date: Mon, 15 Aug 2011 21:09:35 +0200
Message-ID: <20110815190935.GA17589__24674.8164100156$1313435684$gmane$org@redhat.com>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110814174000.GA2381@redhat.com>
	<20110815101144.39812e9f@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110815101144.39812e9f-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Paul  E.McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/15, NeilBrown wrote:
>
> de_thread can change the group_leader of a thread_group, and release_task can
> remove a non-leader while leaving the rest of the thread_group intact.  So
> any while_each_thread() loop needs some extra care to ensure that it doesn't
> loop infinitely, because the "head" that it is looking for might not be there
> any more.
> Maybe there are other rules that ensure this can never happen, but they sure
> aren't obvious to me (i.e. if you know them - please tell ;-)

No, I don't know ;)

And note also that if g != leader, then while_each_thread(g, t) can hang
simply because g exits. I am still trying to invent something simple to
fix while_each_thread-under-rcu.

This looks possible, but I am starting to think that, say, zap_threads()
needs locking anyway. With any fix I can imagine, it can miss a thread
we should care about.

Oleg.
