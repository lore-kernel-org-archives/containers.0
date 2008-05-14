From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Tue, 13 May 2008 20:27:59 -0700
Message-ID: <6599ad830805132027w7b258257u82f7ddcf6e8c852b@mail.gmail.com>
References: <48231FB6.7000206@linux.vnet.ibm.com>
	<20080514032125.46F7D5A07@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080514032125.46F7D5A07-Pcsii4f/SVk@public.gmane.org>
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

On Tue, May 13, 2008 at 8:21 PM, YAMAMOTO Takashi
<yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
>
>  note that a failure can affect other subsystems which belong to
>  the same hierarchy as well, and, even worse, a back-out attempt can also fail.
>  i'm afraid that we need to play some kind of transaction-commit game,
>  which can make subsystems too complex to implement properly.
>

I was considering something like that - every call to can_attach()
would be guaranteed to be followed by either a call to attach() or to
a new method called cancel_attach(). Then the subsystem would just
need to ensure that nothing could happen which would cause the attach
to become invalid between the two calls.

Or possibly, since for some subsystems that might involve holding a
spinlock, we should extend it to:

After a successful call to can_attach(), either abort_attach() or
commit_attach() will be called; these calls are not allowed to sleep,
and cgroup.c will not sleep between calls.. If commit_attach() is
called, it will be followed shortly by attach(), which is allowed to
sleep.

Paul
