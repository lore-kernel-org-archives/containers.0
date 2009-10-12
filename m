From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Mon, 12 Oct 2009 10:03:56 -0500
Message-ID: <20091012150355.GA5783@us.ibm.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <68e6eac60910110930q74358967o19e3d0e88e111bd5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hi all,
> 
> I'm new to LXC but have been playing around with it some.
> 
> I ran into a few issues:
> 1) PIDs for container processes show up on the controlling host (ps, top,
> etc). In OpenVZ there is a way to hide them.

Hmm, yes, it's basically by design, and 'fixing' it will sully the
clean hierarchical pidns design.

The easiest way to emulate that would be to have the host, during
boot, have init split off two child pid namespaces - one for most of the
host applications like the xserver, host's sshd, etc, and the other for
spawning off containers.  Then management of pid namespaces by the
host has to be done either from the init pid-ns, or from the pid-ns
which spawns off containers.

> 2) All controlling host mounts show up in containers.

Same.

> 3) A "kill -9 -1" run from a user in the controlling host kills all
> processes in all containers where the owner of the process has the same UID
> as the UID of the outside user. (At least the reverse is not the case).

You can prevent this from happening using selinux or smack.

Properly fixing this requires more work on the user namespace.  I am (as
always) hoping to get time to work on that soon.

> 4) In a opensuse container when I execute "halt" it is not just the
> container that halts, but the controlling host as well that shuts down.

Make sure that the container is launched with CAP_SYS_BOOT removed from
the capability bounding set.

> It does not make any difference where I mount /proc on the outside into the
> container, or from inside the container, the behavior above stays the same.
> 
> I'm binding mounting the outside /dev to the container /dev mountpoints.
> 
> I'm running Linux 2.6.30.6 and lxc 0.6.3
> 
> In opensuse I was able to successfuly start the container only after
> commenting out si::bootwait:/etc/init.d/boot in /etc/inittab.
> Same for archlinux, I disabled rc::sysinit:/etc/rc.sysinit in /etc/inittab.
> I'm not concerned about having to do that.
> 
> 
> I'm looking for any insight or needed configuration changes for these issue.

-serge
