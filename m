From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 10:10:18 -0500
Message-ID: <20110404151017.GA4857__5884.12601869113$1301929860$gmane$org@hallyn.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1301929228.31531.39.camel@tp-t61>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Sun, 2011-04-03 at 14:03 -0500, Serge E. Hallyn wrote:
> > Quoting ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > Only a pid namespace init task - the child process produced by a call
> > > to clone(2) with CLONE_NEWPID - is allowed to call these.  The state
> > 
> > So you make this useful for your cases by only using this with
> > application containers - created using lxc-execute, or, more precisely,
> > using lxc-init as the container's init.  So a container running a stock
> > distro can't be checkpointed.
> 
> Correct, a conventional distro init won't work, and application
> containers are my focus for now, at least.
> 
> 
> > Is this just to keep the patch simple for now, or is there some reason
> > to keep this limitation in place?
> 
> I guess you're asking whether non-pid-init processes could be allowed to
> use the syscalls?

No.  I'm asking whether you are intending to later on change the checkpoint
API to allow an external task to checkpoint a pid-init process, rather than
the pid-init process having to initiate it itself.


-serge
