From: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Subject: Re: [systemd-devel] How to use cgroups within containers?
Date: Mon, 20 Oct 2014 19:04:43 +0200
Message-ID: <20141020170442.GA4271__14900.2687925988$1413824700$gmane$org@gardel-login>
References: <CAFLxGvxzmfhLZPsmsFG9qdB0oDf9ayvNaWNNOXqcAkW3yATffg@mail.gmail.com>
	<20141020162445.GA4008@gardel-login> <54453D06.9020101@nod.at>
	<20141020165129.GA4179@gardel-login> <54453E6F.6000202@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <54453E6F.6000202-/L3Ra7n9ekc@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 20.10.14 18:55, Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org) wrote:

> Am 20.10.2014 um 18:51 schrieb Lennart Poettering:
> > On Mon, 20.10.14 18:49, Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org) wrote:
> > 
> >> Am 20.10.2014 um 18:24 schrieb Lennart Poettering:
> >>> On Fri, 17.10.14 23:35, Richard Weinberger (richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >>>
> >>>> Dear systemd and container folks,
> >>>>
> >>>> at Plumbers the question raised how to provide cgroups to a systemd that lives
> >>>> in a container (with user namespaces).
> >>>> Due to the GDL train strikes I had to leave very soon and had no chance to
> >>>> talk to you in person.
> >>>>
> >>>> Was a solution proposed?
> >>>> All I want to know is how to provide cgroups in a sane and secure way
> >>>> to systemd. :-)
> >>>
> >>> The cgroups setup systemd requires to be able to run cleanly without
> >>> changes in a container is documented here:
> >>>
> >>> http://www.freedesktop.org/wiki/Software/systemd/ContainerInterface/
> >>>
> >>> You have to mount the full cgroupfs hierarchies into the containers,
> >>> so that /proc/$PID/cgroup makes sense inside the containers (that file
> >>> lists absolute paths...). They can be mounted read-only up to the
> >>> container's root, but further down they need to be writable to the
> >>> container, so that systemd inside the container can do its job.
> >>
> >> And what solution do you propose?
> > 
> > Solution? For what problem precisely?
> 
> Running systemd inside Linux container (including user namespaces). :-)
> 
> >> Will cgroup namespaces make systemd finally happy?
> > 
> > I have no idea about cgroup namespaces and what they entail.
> > 
> > systemd is quite happy already, if you follow the guidelines for
> > container managers we put together...
> 
> Have you ever used systemd inside a container?
> Say, LXC or libvirt-lxc...

Have you read the link I posted?

Yes, I test systemd inside containers. Daily. Actually it's my primary
way of testing systemd, since it is extremely quick and allows me to
attach from the host with debugging tools...

As long as you follow the suggestions in the document I linked systemd
will work without modifications in container managers. At least
libvirt-lxc and nspawn follows these suggestions, not sure about the
other container managers.

Also read:

http://www.freedesktop.org/wiki/Software/systemd/writing-vm-managers/

We have documented this all so nicely, I can only recommend to
actually take the time to read this. Thanks!

Lennart

-- 
Lennart Poettering, Red Hat
