From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11391] New: Kernel NULL pointer dereference
	in do_notify_parent()
Date: Thu, 21 Aug 2008 16:58:15 -0500
Message-ID: <20080821215815.GA19191@us.ibm.com>
References: <bug-11391-10286@http.bugzilla.kernel.org/>
	<20080821092322.76621dab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080821092322.76621dab.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 21 Aug 2008 05:58:52 -0700 (PDT) bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11391
> > 
> >            Summary: Kernel NULL pointer dereference in do_notify_parent()
> >            Product: Process Management
> >            Version: 2.5
> >      KernelVersion: 2.6.26.3
> 
> Should have been 2.6.26.4?
> 
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: process_other-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
> >         ReportedBy: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
> > 
> > 
> > Latest working kernel version: 2.6.26.3
> > 
> > Earliest failing kernel version: 2.6.25.4 (didn't test with former kernels)

I'm sorry, I'm confused.  Which kernel version exactly fails?  I don't
see 2.6.26.4 on kernel.org, and Linus' tree (just pulled) doesn't fail
for me.

thanks,
-serge
