From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroups: cleanup for dummy root
Date: Mon, 1 Dec 2008 16:15:47 -0800
Message-ID: <6599ad830812011615qe28ac37q7af73920e0f9a429__17656.683168798$1228177096$gmane$org@mail.gmail.com>
References: <492F9D4C.2020204@cn.fujitsu.com> <492FB3FB.6060806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492FB3FB.6060806-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 28, 2008 at 1:03 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> Hmmm...Sorry, this patch is wrong, when a subsystem is inactive thus in
> rootnode, it may still iterate tasks in dummy top cgroup, though currently
> no subsystem does so.

Right - iterating across the tasks in a cgroup for an unmounted
subsystem is a completely valid thing to do. I suppose it might make
sense to optimize that to just scan the tasklist and thread lists in
that case, to avoid the overhead of maintaining the cg links for the
unmounted subsystems, but you'd have to change the cgroup iterator
first, before you stop maintaining the links. Given that I suspect the
main overhead of maintaining the links is taking css_set_lock, I'm not
sure how much it hurts to be keeping the links for the inactive
hierarchies too and keeping the code simpler.

Paul
