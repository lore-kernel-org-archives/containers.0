From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [systemd-devel] How to use cgroups within containers?
Date: Mon, 20 Oct 2014 18:49:10 +0200
Message-ID: <54453D06.9020101__42765.4327395887$1413823769$gmane$org@nod.at>
References: <CAFLxGvxzmfhLZPsmsFG9qdB0oDf9ayvNaWNNOXqcAkW3yATffg@mail.gmail.com>
	<20141020162445.GA4008@gardel-login>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141020162445.GA4008@gardel-login>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Am 20.10.2014 um 18:24 schrieb Lennart Poettering:
> On Fri, 17.10.14 23:35, Richard Weinberger (richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> 
>> Dear systemd and container folks,
>>
>> at Plumbers the question raised how to provide cgroups to a systemd that lives
>> in a container (with user namespaces).
>> Due to the GDL train strikes I had to leave very soon and had no chance to
>> talk to you in person.
>>
>> Was a solution proposed?
>> All I want to know is how to provide cgroups in a sane and secure way
>> to systemd. :-)
> 
> The cgroups setup systemd requires to be able to run cleanly without
> changes in a container is documented here:
> 
> http://www.freedesktop.org/wiki/Software/systemd/ContainerInterface/
> 
> You have to mount the full cgroupfs hierarchies into the containers,
> so that /proc/$PID/cgroup makes sense inside the containers (that file
> lists absolute paths...). They can be mounted read-only up to the
> container's root, but further down they need to be writable to the
> container, so that systemd inside the container can do its job.

And what solution do you propose?
Will cgroup namespaces make systemd finally happy?

Thanks,
//richard
