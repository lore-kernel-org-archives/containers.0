From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH v2] ns: do not block exit_task_namespaces() for a long time
Date: Mon, 16 Jul 2012 18:22:25 +0100
Message-ID: <20120716172225.GO31729@ZenIV.linux.org.uk>
References: <20120713140806.b3d0fda8.akpm@linux-foundation.org>
	<1342451364-14787-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20120716165301.GN31729@ZenIV.linux.org.uk>
	<20120716171634.GA21620@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120716171634.GA21620-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jul 16, 2012 at 08:16:34PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jul 16, 2012 at 05:53:01PM +0100, Al Viro wrote:
> > On Mon, Jul 16, 2012 at 06:09:24PM +0300, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > > 
> > > On exiting of the last task in a namespace we need to trigger freeing of
> > > the namespace. Currently, we call synchronize_rcu() and free_nsproxy()
> > > directly on do_exit() path.
> > > 
> > > On my machine synchronize_rcu() blocks for about 0.01 seconds. For
> > > comparing: normal exit_group() syscall takes less than 0.0003 seconds.
> > > 
> > > Let's offload synchronize_rcu() and free_nsproxy() to a workqueue.
> > > 
> > > I also move synchronize_rcu() inside free_nsproxy(). It fixes racy
> > > put_nsproxy() which calls free_nsproxy() without synchronize_rcu().
> > > I guess it was missed during switch to RCU (see cf7b708).
> > 
> > NAK.  Making final umounts of anything in that namespace asynchronous,
> > even though nothing is holding the stuff on them busy is simply
> > wrong.  Note that they can take a _long_ time, so we are talking about
> > minutes worth of delay in the worst case.  It's user-visible and
> > it's a serious potential for trouble.
> 
> Good point.
> 
> Now in worst case we have a process which hang for a few minutes in
> exit_group() syscall in D state, right? Why is that any better?
> Does it provide better user experience or better accounting or what?

"Session that was using that USB stick has still not finished exiting;
might be still busy writing stuff there, so better not pull it out yet".
