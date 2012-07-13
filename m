From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH] ns: move free_nsproxy() out of do_exit() path
Date: Sat, 14 Jul 2012 01:23:24 +0300
Message-ID: <20120713222319.GA13343@shutemov.name>
References: <1342180088-22647-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20120713140806.b3d0fda8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120713140806.b3d0fda8.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 13, 2012 at 02:08:06PM -0700, Andrew Morton wrote:
> On Fri, 13 Jul 2012 14:48:08 +0300
> "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> 
> > From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > 
> > free_nsproxy() is too heavy to be on exit path. Let's free namespaces
> > asynchronously to not block exit_group() syscall.
> 
> Please be specific, and complete.
> 
> Why is it "too heavy"?  Where is the time being spent?  Is it spent in
> D state or is it spent burning CPU cycles?  Does the patch simply
> offload the work into kernel threads, providing no net gain?

Unpatched switch_task_namespaces() takes 0.010 - 0.011 seconds on my
machine. About 0.008 of the time is synchronize_rcu().

So it's mostly waiting with wait_for_completion() in wait_rcu_gp().
It means D state.

> > The patch also fixes bug with free namespace without synchronize_rcu() through
> > put_nsproxy().
> 
> I just don't understand this description.

IIUC current locking model requires synchronize_rcu() before
free_nsproxy(). put_nsproxy() calls free_nsproxy() without
synchronize_rcu(). So it's racy.

I guess it was missed during switch to RCU (see cf7b708).
Pavel, am I right?

> Please send a new one which
> includes all details about the bug, including a description of
> the user-visible effects of the bug.

Okay, I will.

-- 
 Kirill A. Shutemov
