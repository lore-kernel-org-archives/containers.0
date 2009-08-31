From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 31 Aug 2009 08:40:45 -0500
Message-ID: <20090831134045.GD4837@us.ibm.com>
References: <4A92676A.1080609@free.fr>
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>
	<4A9275CB.7030108@free.fr>
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>
	<4A929F83.80207@free.fr>
	<20090826104312.97ff028f.kamezawa.hiroyu@jp.fujitsu.com>
	<4A952689.9020704@free.fr>
	<ac1c4bf20908260650x3311d5d3q44631a30205089b7@mail.gmail.com>
	<ac1c4bf20908261625g71dff96cu77190056540cbb7@mail.gmail.com>
	<4A97A448.5050506@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A97A448.5050506-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Krzysztof Taraszka wrote:
> > Okey.
> > I made few tests and this two ways work:
> >
> > First way:
> > =======
> > lxc. smack enabled, policy loaded. cgroup not labeled.
> >
> > a) start container
> > b) mount cgroup inside container
> > c) mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
> > d) secure the /cgroup on the host (ie: attr -S -s SMACK64 -V host /cgroup).
> >
> > this step can be done inside lxc tools ;)
> >
> > Second way:
> > ==========
> > lxc. smack enabled, policy loaded. cgroup not labeled.
> >
> > a) do not label whole /cgrop directory (DO NOT DO: attr -S -s SMACK64 -V
> > host /cgroup). Label dedicate files only (for example: /cgroup/cpuset.cpus,
> > /cgroup/vs1/cpuset.cpus, etc). Do not label the /cgrop/vs1 directory. Label
> > with vs1 label only /cgroup/vs1/memory.meminfo. All other files label with
> > host label to do not allow read them.
> > b) start container
> > c) mount cgroup inside container
> > d) mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
> >
> > steps: b, c, d can be done inside lxc tools. step a can't and it is base on
> > the admin policy.
> >
> > I think that the first solution is more automatic and can be done by lxc
> > tools (maybe command line switch? I can prepare a patch for that.
> >   
> 
> I do not know smack, what does smack here ? Will this solution avoid the 
> container to overwrite /proc/meminfo by remounting /proc ?

Right, in the first way he is labeling the whole cgroupfs with a label
which prevents the container from mounting it.  In the second way,
the specific files are labeled.

-serge
