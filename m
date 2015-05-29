From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netlink and user namespaces
Date: Fri, 29 May 2015 11:14:11 -0500
Message-ID: <87vbfb4azw.fsf__15265.8726707616$1432916370$gmane$org@x220.int.ebiederm.org>
References: <1432901907.7545.30.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1432901907.7545.30.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Alexander Larsson's
	message of "Fri, 29 May 2015 14:18:27 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Now that I'm using a non-privileged user namespace for my desktop
> sandboxing system all kind of network status things are breaking. The
> reason for this is that they use netlink to enumerated interfaces, and
> to verify that the replies are from the kernel (apparently anyone can
> send anyone netlink messages) this code is verifying that the
> SCM_CREDENTIAL sender of the netlink messages is uid 0.
>
> For instance: 
> http://git.0pointer.net/avahi.git/commit/avahi-core/netlink.c?id=37b2be93e63ceff95698f24cd91cb11774eb621c
> and:
> https://git.gnome.org/browse/glib/tree/gio/gnetworkmonitornetlink.c#n340
>
> This obviously breaks when uid is not mapped (as it can't be in an
> unprivileged user namespace), as uid will be overflowuid.
>
> Is there any other way to check that a netlink message is from the
> kernel?

*scratches my head*  Those are weird pieces of code.

The answer is the way you do this with any other socket.

Call recvfrom or recvmsg.
Looking at the senders address.
If in the senders address nl_pid == 0 then the message is from
the kernel.  Otherwise the message is from userspace.

Looking anywhere else at anything else is bogus.

And a note.  nl_pid is short for netlink port id.  It is not a process id.

Eric
