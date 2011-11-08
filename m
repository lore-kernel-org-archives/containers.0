From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic
Date: Tue, 8 Nov 2011 13:51:11 -0800
Message-ID: <20111108135111.6a74f1d2.akpm@linux-foundation.org>
References: <1320765670-14181-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320765670-14181-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue,  8 Nov 2011 16:21:10 +0100
Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> To solve this, keep the original cgroup of each thread in the thread
> group cached in the flex array and pass it to can_attach_task()/attach_task()
> and cancel_attach_task() so that the correct common ancestor between the old
> and new cgroup can be safely retrieved for each task.

OK, thanks.

We need to work out what to do with this patchset.  ie: should we merge
it.  I'm not sure that the case has been made?

Let's please drag this thing onto the table and poke at it for a while.
Probably everyone has forgotten everything so we'll need to start
again, sorry.  Perhaps you can (re)start proceedings by telling us why
it's useful to our users and why we should merge it?


Some mental notes:

Tim says it would be useful for the things he's doing but doesn't
appear to have confirmed/tested that.

Kay has said that it would not be useful for his plumber's wishlist
item, which is a shame.

I seem to recall complaining that it doesn't address the forkbomb issue
for non-cgroups setups, so the forkbomb issue remains unaddressed.
