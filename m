From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: uevent when moving nic between network namespaces?
Date: Fri, 12 Oct 2012 17:17:11 -0500
Message-ID: <20121012221711.GA23227@sergelap>
References: <20121012031328.GA5472@sergelap> <871uh4pdzd.fsf@xmission.com>
	<20121012191828.GA12200@sergelap> <87sj9jmqew.fsf@xmission.com>
	<20121012215650.GA22665@sergelap> <87bog7mjhm.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bog7mjhm.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Dan Kegel <dank-XdDNpL9cdsoAvxtiuMwx3w@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> I am not currently working on a patch for this, but I will be happy to
> >> review one. At a quick glance it looks like this could just be as
> >> simple as calling kobject_uevent at the proper time, but testing and
> >> reading through the relevant code paths is probably a good idea as there
> >> always seems to be gotchas in that code.
> >> 
> >> Eric
> >
> > This (the simple fix) works for me, actually.
> >
> > I do notice the ifdef shouldn't be needed, all the better.
> 
> Should we have a KOBJ_ADD in the new network namespace or is the
> KOBJ_MOVE sufficient?

I was wondering about that...  the KOBJ_ADD is technically not sufficient
imo, since a MOVE (for a device which udev/upstart has never seen before)
doesn't necessarily mean "configure this."  So when I pass one end of a
veth into a running ubuntu container, there is no network-interface or
network-interface-security upstart job for it, whereas if I do a
ip link add type veth inside the container, those do get the jobs.

Now, ISTM passing an endpoing into a container is mainly done at
startup, and upstart will end up configuring it anyway.  Nothing is
really breaking in any of the container usages I've seen because of this.
But it would definately be cleaner to pass a KOBJ_ADD before the KOBJ_MOVE.
Otherwise, udev has to guess what the MOVE meant.

If there's no objection, I'll add that (and test it) and send to netdev
on monday.

-serge
