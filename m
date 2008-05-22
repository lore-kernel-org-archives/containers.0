From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH -mm] remove node_ prefix_from ns subsystem
Date: Thu, 22 May 2008 01:36:12 -0700
Message-ID: <20080522013612.cb196653.akpm@linux-foundation.org>
References: <48344409.9090903@fr.ibm.com>
	<20080521220657.12e8e8c9.akpm@linux-foundation.org>
	<6599ad830805220011u77313ed7s2c0c9d4a658133cc@mail.gmail.com>
	<20080522003213.d677ba30.akpm@linux-foundation.org>
	<48352277.4010703@fr.ibm.com>
	<20080522011053.680f7f65.akpm@linux-foundation.org>
	<6599ad830805220123t7a3848eeg244393723d5fd08d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830805220123t7a3848eeg244393723d5fd08d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 22 May 2008 01:23:35 -0700 "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Hi Andrew,
> 
> On Thu, May 22, 2008 at 1:10 AM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >
> > What the change is, why it is being made, what the user-visible
> > presentation is, what the impact upon users is, why we think it won't
> > be a problem, etc?  The stuff which should have been right there from
> > day one, before the code change was even made?
> 
> The change is that previously when cgroup_clone() was called
> (currently only from the unshare path in ns_proxy cgroup, you'd get a
> new group named "node_$pid" whereas now you'll get a group named after
> just your pid.)
> 
> The only users who would notice it are those who are using the
> ns_proxy cgroup subsystem to auto-create cgroups when namespaces are
> unshared - something of an experimental feature, which I think really
> needs more complete container/namespace support in order to be useful.
> I suspect the only users are Cedric and Serge, or maybe a few others
> on containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cuFJUID1Z7QI@public.gmane.org And in fact it would only be
> noticed by the users who make the assumption about how the name is
> generated, rather than getting it from the /proc/<pid>/cgroups file
> for the process in question.
> 
> Whether the change is actually needed or not I'm fairly agnostic on,
> but I guess it is more elegant to just use the pid as the new group
> name rather than adding a fairly arbitrary "node_" prefix on the
> front.
> 

Well I suppose that as a non-back-compatible change we should feed it
into 2.6.25.x as well.  It's a bit unusual, but so doing will reduce the
number of hey-where-did-my-file-go discoveries.
