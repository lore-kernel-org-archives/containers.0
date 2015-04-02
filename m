From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Thu, 02 Apr 2015 13:12:05 +0300
Message-ID: <1427969525.3559.120.camel@HansenPartnership.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
	<1427807248.2117.117.camel@HansenPartnership.com>
	<CALCETrWKA4ZdHfdLuW0_W5xxJOSCJdt_fiRWs6vDk+8ZQ9n9iA@mail.gmail.com>
	<1427808184.2117.122.camel@HansenPartnership.com>
	<CALCETrW8v1NFa7fcJbyJKXk9Msudht5BJ7Zy1Rg7ZC_TS-2Y-Q@mail.gmail.com>
	<1427810118.2117.126.camel@HansenPartnership.com>
	<CALCETrU1vKf3fXPt8nS-ABDgfp8NxrFjHwTc68rA0rtvg2Lufg@mail.gmail.com>
	<1427810886.2117.129.camel@HansenPartnership.com>
	<1427811444.4411.20.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1427811444.4411.20.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2015-03-31 at 16:17 +0200, Alexander Larsson wrote:
> On tis, 2015-03-31 at 17:08 +0300, James Bottomley wrote:
> > On Tue, 2015-03-31 at 06:59 -0700, Andy Lutomirski wrote:
> > > 
> > > I don't think that this is correct.  That user can already create a
> > > nested userns and map themselves as 0 inside it.  Then they can mount
> > > devpts.
> > 
> > I don't mind if they create a container and control the isolated ttys in
> > that sub container in the VPS; that's fine.  I do mind if they get
> > access to the ttys in the VPS.
> > 
> > If you can convince me (and the rest of Linux) that the tty subsystem
> > should be mountable by an unprivileged user generally, then what you
> > propose is OK.
> 
> That is controlled by the general rights to mount stuff. I.e. unless you
> have CAP_SYS_ADMIN in the VPS container you will not be able to mount
> devpts there. You can only do it in a subcontainer where you got
> permissions to mount via using user namespaces.

OK let me try again.  Fine, if you want to speak capabilities, you've
given a non-root user an unexpected capability (the capability of
creating a ptmx device).  But you haven't used a capability separation
to do this, you've just hard coded it via a mount parameter mechanism.

If you want to do this thing, do it properly, so it's acceptable to the
whole of Linux, not a special corner case for one particular type of
container.

Security breaches are created when people code in special, little used,
corner cases because they don't get as thoroughly tested and inspected
as generally applicable mechanisms.

What you want is to be able to use the tty subsystem as a non root user:
fine, but set that up globally, don't hide it in containers so a lot
fewer people care.

James
