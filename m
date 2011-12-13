From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic
Date: Tue, 13 Dec 2011 23:22:13 +0000
Message-ID: <20111213232213.GC4637__367.563663940196$1323818571$gmane$org@redhat.com>
References: <1320765670-14181-1-git-send-email-fweisbec@gmail.com>
	<20111108135111.6a74f1d2.akpm@linux-foundation.org>
	<20111124132442.GA18579@somewhere.redhat.com>
	<4EE7B926.9030702@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EE7B926.9030702-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Dec 13, 2011 at 03:44:22PM -0500, Daniel J Walsh wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 11/24/2011 08:24 AM, Frederic Weisbecker wrote:
> > On Tue, Nov 08, 2011 at 01:51:11PM -0800, Andrew Morton wrote:
> >> On Tue,  8 Nov 2011 16:21:10 +0100 Frederic Weisbecker
> >> <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> 
> >>> To solve this, keep the original cgroup of each thread in the
> >>> thread group cached in the flex array and pass it to
> >>> can_attach_task()/attach_task() and cancel_attach_task() so
> >>> that the correct common ancestor between the old and new cgroup
> >>> can be safely retrieved for each task.
> >> 
> >> OK, thanks.
> >> 
> >> We need to work out what to do with this patchset.  ie: should we
> >> merge it.  I'm not sure that the case has been made?
> >> 
> >> Let's please drag this thing onto the table and poke at it for a
> >> while. Probably everyone has forgotten everything so we'll need
> >> to start again, sorry.  Perhaps you can (re)start proceedings by
> >> telling us why it's useful to our users and why we should merge
> >> it?
> > 
> > Right, so the main purpose is to have a suitable forkbomb
> > protection in the lxc containers. It seems that these days, using
> > NR_PROC rlimit is the prime choice to protect against forkbombs.
> > But we can't use this for containers because if they run under the
> > same user, they can starve each others by generating high number of
> > processes. So we need the limit on number of processes to be per
> > container.
> > 
> > The basic requirement is to be able to run untrustee process inside
> > a container while protecting against attacks from there without
> > impacting the rest of the system.
> > 
> > I'm adding in Cc some Lxc people who could perhaps provide more
> > details and testify we really need this.
> > 
> >> Some mental notes:
> >> 
> >> Tim says it would be useful for the things he's doing but
> >> doesn't appear to have confirmed/tested that.
> > 
> > Yeah, I'm waiting for more details from him. Tim?
> > 
> >> Kay has said that it would not be useful for his plumber's
> >> wishlist item, which is a shame.
> > 
> > Indeed. I mean it would work but this cgroup subsystem is too much
> > overhead to be used by an init process (and then all other
> > processes).
> > 
> >> I seem to recall complaining that it doesn't address the forkbomb
> >> issue for non-cgroups setups, so the forkbomb issue remains
> >> unaddressed.
> > 
> > Right. Now if we can find a generic solution to protect against all
> > forkbombs, something deterministic that can react soon enough so
> > that it doesn't impact the rest of system, in order to avoid
> > running into some DDOS, then we will consider it.
> > 
> > Thanks.
> 
> 
> I have heard that this is being held up because of a lack of
> justification.  Here is my attempt.  I would like to use the ability
> to prevent a fork bomb and guaranteed killall for three different
> tools that I work on.
> 
> 1.  Kiosk/xguest user.  Currently we tell people to log out of a
> system on the kiosk and the pam stack attempts to kill all processes
> running in the kiosk user session.  The kiosk user is not allowed to
> login to the system if a process is still running as the user.  The
> reason for this is we want to guarantee no previous user left a trojan
> process waiting to track your activity.  If the login program can not
> kill all user processes at logout, then the next user will not be able
> to login.
> 
> 2.  Sandbox Desktop tools are used to write one or more processes
> within a lockeddown environment.  The idea here is to run untrusted
> code and potentially this code could trigger a fork bomb, you want to
> be able to kill the session.
> 
> 3.  Secure containers, similarly to sandboxes allow users to run
> multiple Linux Containers in a locked down manner.  We would like to
> be guaranteed that we can kill all processes within a secure
> containers at exit.

More generally when libvirt uses the kernel's namespace+cgroups support
to spawn the LXC container, we want to be able to put an upper bound on
the number of process an individual container can run. The existing
RLIMIT_NPROC doesn't work, because you can get multiple containers running
processes with the same real UID, and each container can also run processes
under different real UIDs. libvirt places each container created inside a
dedicated cgroups, for the purpose of resource control, so task limits
attached to cgroups easily lets us limit per-container process creation.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
