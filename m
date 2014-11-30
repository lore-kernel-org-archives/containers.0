From: Lennart Poettering <mzerqung-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: [systemd-devel] systemd-cgroups-agent not working in containers
Date: Sun, 30 Nov 2014 23:30:25 +0100
Message-ID: <20141130223025.GC17898__25823.8142160282$1417387169$gmane$org@gardel-login>
References: <54764639.3020100@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <54764639.3020100-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26.11.14 22:29, Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org) wrote:

> Hi!
> 
> I run a Linux container setup with openSUSE 13.1/2 as guest distro.
> After some time containers slow down.
> An investigation showed that the containers slow down because a lot of stale
> user sessions slow down almost all systemd tools, mostly systemctl.
> loginctl reports many thousand sessions.
> All in state "closing".
> 
> The vast majority of these sessions are from crond an ssh logins.
> It turned out that sessions are never closed and stay around.
> The control group of a said session contains zero tasks.
> So I started to explore why systemd keeps it.
> After another few hours of debugging I realized that systemd never
> issues the release signal from cgroups.
> Also calling the release agent by hand did not help. i.e.
> /usr/lib/systemd/systemd-cgroups-agent /user.slice/user-0.slice/session-c324.scope
> 
> Therefore systemd never recognizes that a server/session has no more tasks
> and will close it.
> First I thought it is an issue in libvirt combined with user namespaces.
> But I can trigger this also without user namespaces and also with systemd-nspawn.
> Tested with systemd 208 and 210 from openSUSE, their packages have all known bugfixes.
> 
> Any idea where to look further?

cgroup empty notification is seriously broken unfortunately in the
kernel the way it is currently implemented. And we'll miss the
callouts in a number of cases (for example, if somebody has any dir in
a cgroup still we get no events for it. It's also not available at all
inside of containers, since the callouts take place on the main pid
namespace, and nowhere else).

Our current strategy for still being able to clean everything up is
this:

a) for service units we keep track of main and control PID (control
   PID is the PID of any script or so we invoke to shutdown a service,
   via ExecStop= or so, or for reload via ExecReload, and so on) and
   if they are gone we consider the service dead, and kill all other
   processes of a service forcibly, not waiting for them between
   SIGTERM and SIGKILL, simply because we can't.

b) For scope units (which login sessions are exposed as) things are
   more difficult. While for service units the relevant processes are
   children of PID 1 and we hence get SIGCHLD signals for this is
   usually not the case for scope units, the processes might be child
   processes of arbitrary processes, we hence cannot reliably get
   notifications for. For dealing with this we have two strategies:

   [1] the registrar of the scope must explicitly stop the scope when
   appropriate.

   [2] the registrar of the scope must explicitly "abandon" the scope
   when appropriate.
   
   In the case of logind both stopping and abandoning are available,
   depending on the KillUserProcesses= setting of
   logind.conf. logind triggers the stopping/abandoning as soon as
   either:

   I)  the PAM session end hook is invoked for the specific session

   II) or the session fifo is closed. Each session logind keeps track
       of has one of these. The FIFO is simply created in the PAM open
       session hook, and normally closed in the session end
       hook. Should the session die abnormally though (without going
       through the PAM end hook) logind sees this as POLLHUP on the
       the other end of the FIFO and can act on it. (Note that the
       FIFO is passed with O_CLOEXEC to the PAM session to ensure that
       it only is kept around in the parent process between PAM open
       and end hooks, but not passed to the child processes, which
       then go an and invoke login/bash or whatever else that is the
       user session.

   When a scope is "stopped" this has the effect of killing all the
   scopes processes, immedietely. When it is "abandoned" however we
   iterate through all remaining processes of the scope, add them to a
   wacthlist and wait for a SIGCHLD for them, checking on each one we
   get if the scope is now empty. If it isn't empty then we collect
   the PIDs again at that time. The rationale for this is: the
   abandoning should normally happen when the main process of the
   scope dies. At this time the other processes of the scope (which
   are its children usually) would get reparented to PID 1 (because
   UNIX) which allows us to get SIGCHLD for them again.

Complex? Awful? Disgusting? Yes, absolutely. But as far as I can see
it should actually be good enough to all cases I ran into.

The proper fix in the long run is to get better notifications for
cgroups from the kernel. Great thing is, they are now available, but
only in the new "unified" cgroup hierarchy, which we haven't ported
things to yet. With that in place we finally can watch cgroups
comprehensively and safely without all this madness. Yay!

Now, if the tracking logic described above doesn't work for you, it
would be good if you would first try with pristine upstream systemd. 

In the past we had problems with PAM clients that didn't implement the
PAM session logic correctly and didn't invoke the PAM session close
hooks, didn't keep the parent process around to do so, or
suchlike. What kind of PAM session do you into this problem with?

> How do you run the most current systemd on your distro?

Well, I as a developer just build it from the git tree, after
installing all deps, with 

    ./autogen.sh c && make -j6 && sudo make install

Lennart

-- 
Lennart Poettering, Red Hat
