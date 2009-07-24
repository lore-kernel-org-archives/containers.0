From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 24 Jul 2009 14:57:36 -0700
Message-ID: <6599ad830907241457x3d1380b6ne613eb5921d6c5a0__32263.9352096759$1248472778$gmane$org@mail.gmail.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724100220.GF11101@hawkmoon.kerlabs.com>
	<2f86c2480907241452m74c50975k522c5a43a62e8459@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907241452m74c50975k522c5a43a62e8459-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 2:52 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> I don't see how css_sets are guaranteed while cgroup_fork_mutex is not held and
>> thus does not prevent new threads from being created right now. Could you
>> elaborate on that?
>
> Prefetching the css sets is independent of the fork lock/race issue.
> The idea is that we build a list, kept locally, that has references on
> all the css_sets we'll need to migrate each thread to the new cgroup.
> Since ordinarily we might need to malloc a new css_set for a thread
> before moving it, and it's possible that that could fail, we need to
> do allocations for all threads to be moved before committing any of
> them. As long as we have the list of prefetched css_sets, they'll stay
> there, and at the end, we drop the extra references we took on them to
> make that guarantee when tearing down the list.

And more specifically, since only the holder of cgroup_mutex can move
a thread to a new cgroup (and hence a potentially new unique css_set),
we know that once we've run through all the threads in the
thread_group and verified that we have the appropriate pre-fetched
css_set objects for all of them, it doesn't matter if any new threads
are created - they'll share one of the pre-fetched css_sets.

Paul
