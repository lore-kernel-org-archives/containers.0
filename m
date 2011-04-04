From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 04 Apr 2011 10:40:08 -0500
Message-ID: <1301931608.31531.49.camel__28854.5821946629$1301931724$gmane$org@tp-t61>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com> <1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110404151017.GA4857-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2011-04-04 at 10:10 -0500, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > On Sun, 2011-04-03 at 14:03 -0500, Serge E. Hallyn wrote:
> > > Quoting ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > > Only a pid namespace init task - the child process produced by a call
> > > > to clone(2) with CLONE_NEWPID - is allowed to call these.  The state
> > > 
> > > So you make this useful for your cases by only using this with
> > > application containers - created using lxc-execute, or, more precisely,
> > > using lxc-init as the container's init.  So a container running a stock
> > > distro can't be checkpointed.
> > 
> > Correct, a conventional distro init won't work, and application
> > containers are my focus for now, at least.
> > 
> > 
> > > Is this just to keep the patch simple for now, or is there some reason
> > > to keep this limitation in place?
> > 
> > I guess you're asking whether non-pid-init processes could be allowed to
> > use the syscalls?
> 
> No.  I'm asking whether you are intending to later on change the checkpoint
> API to allow an external task to checkpoint a pid-init process, rather than
> the pid-init process having to initiate it itself.

No, that is not the intention.  I can see how that would be problematic
for those wanting to run minimally-modified distro containers, but I
think running a patched pid-init is a reasonable tradeoff to ask users
to make in order to get c/r.  And there's nothing to keep the standard
distro inits from growing c/r capability.
