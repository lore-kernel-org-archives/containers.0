From: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] lib/kobject_uevent.c: add uevent forwarding function
Date: Thu, 10 Sep 2015 08:43:28 +0300
Message-ID: <CAA2m6vcnUz4EeS-FH2P=GjKSquXit=j1NE5Yut8_baLA+TvjJA@mail.gmail.com>
References: <cover.1441762578.git.michael.coss@alcatel-lucent.com>
	<3456750fe7a5a5eb709e315618facf5704cc1885.1441762578.git.michael.coss@alcatel-lucent.com>
	<20150909035527.GB5153@kroah.com>
	<55F0875C.6060108@alcatel-lucent.com>
	<20150909201123.GC9328@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150909201123.GC9328-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Michael J Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 9, 2015 at 11:11 PM, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
>
> On Wed, Sep 09, 2015 at 03:24:12PM -0400, Michael J Coss wrote:
> > On 9/8/2015 11:55 PM, Greg KH wrote:
> > > On Tue, Sep 08, 2015 at 10:10:29PM -0400, Michael J. Coss wrote:
> > >> Adds capability to allow userspace programs to forward a given event to
> > >> a specific network namespace as determined by the provided pid.  In
> > >> addition, support for a per-namespace kobject_sequence counter was
> > >> added.  Sysfs was modified to return the correct event counter based on
> > >> the current network namespace.
> > >>
> > >> Signed-off-by: Michael J. Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
> > >> ---
> > >>  include/linux/kobject.h     |  3 ++
> > >>  include/net/net_namespace.h |  3 ++
> > >>  kernel/ksysfs.c             | 12 ++++++
> > >>  lib/kobject_uevent.c        | 90 +++++++++++++++++++++++++++++++++++++++++++++
> > >>  4 files changed, 108 insertions(+)
> > >>
> > >> diff --git a/include/linux/kobject.h b/include/linux/kobject.h
> > >> index 637f670..d1bb509 100644
> > >> --- a/include/linux/kobject.h
> > >> +++ b/include/linux/kobject.h
> > >> @@ -215,6 +215,9 @@ extern struct kobject *firmware_kobj;
> > >>  int kobject_uevent(struct kobject *kobj, enum kobject_action action);
> > >>  int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
> > >>                    char *envp[]);
> > >> +#if defined(CONFIG_UDEVNS) || defined(CONFIG_UDEVNS_MODULE)
> > >> +int kobject_uevent_forward(char *buf, size_t len, pid_t pid);
> > >> +#endif
> > >>
> > >>  __printf(2, 3)
> > >>  int add_uevent_var(struct kobj_uevent_env *env, const char *format, ...);
> > >> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> > >> index e951453..a4013e5 100644
> > >> --- a/include/net/net_namespace.h
> > >> +++ b/include/net/net_namespace.h
> > >> @@ -134,6 +134,9 @@ struct net {
> > >>  #if IS_ENABLED(CONFIG_MPLS)
> > >>    struct netns_mpls       mpls;
> > >>  #endif
> > >> +#if defined(CONFIG_UDEVNS) || defined(CONFIG_UDEVNS_MODULE)
> > >> +  u64                             kevent_seqnum;
> > >> +#endif
> > >>    struct sock             *diag_nlsk;
> > >>    atomic_t                fnhe_genid;
> > >>  };
> > >> diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
> > >> index 6683cce..4bc15fd 100644
> > >> --- a/kernel/ksysfs.c
> > >> +++ b/kernel/ksysfs.c
> > >> @@ -21,6 +21,9 @@
> > >>  #include <linux/compiler.h>
> > >>
> > >>  #include <linux/rcupdate.h>       /* rcu_expedited */
> > >> +#if defined(CONFIG_UDEVNS) || defined(CONFIG_UDEVNS_MODULE)
> > >> +#include <net/net_namespace.h>
> > >> +#endif
> > > #if isn't needed here, right?
> > >
> > >>
> > >>  #define KERNEL_ATTR_RO(_name) \
> > >>  static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
> > >> @@ -33,6 +36,15 @@ static struct kobj_attribute _name##_attr = \
> > >>  static ssize_t uevent_seqnum_show(struct kobject *kobj,
> > >>                              struct kobj_attribute *attr, char *buf)
> > >>  {
> > >> +#if defined(CONFIG_UDEVNS) || defined(CONFIG_UDEVNS_MODULE)
> > >> +  pid_t p = task_pid_vnr(current);
> > >> +  struct net *n = get_net_ns_by_pid(p);
> > >> +
> > >> +  if (n != ERR_PTR(-ESRCH)) {
> > >> +          if (!net_eq(n, &init_net))
> > >> +                  return sprintf(buf, "%llu\n", n->kevent_seqnum);
> > >> +  }
> > >> +#endif
> > >>    return sprintf(buf, "%llu\n", (unsigned long long)uevent_seqnum);
> > >>  }
> > >>  KERNEL_ATTR_RO(uevent_seqnum);
> > >> diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
> > >> index d791e33..7589745 100644
> > >> --- a/lib/kobject_uevent.c
> > >> +++ b/lib/kobject_uevent.c
> > >> @@ -379,6 +379,96 @@ int kobject_uevent(struct kobject *kobj, enum kobject_action action)
> > >>  }
> > >>  EXPORT_SYMBOL_GPL(kobject_uevent);
> > >>
> > >> +#if defined(CONFIG_UDEVNS) || defined(CONFIG_UDEVNS_MODULE)
> > >> +/**
> > >> + * kobject_uevent_forward - forward event to specified network namespace
> > >> + *
> > >> + * @buf: event buffer
> > >> + * @len: event length
> > >> + * @pid: pid of network namespace
> > >> + *
> > >> + * Returns 0 if kobject_uevent_forward() is completed with success or the
> > >> + * corresponding error when it fails.
> > >> + */
> > >> +int kobject_uevent_forward(char *buf, size_t len, pid_t pid)
> > >> +{
> > >> +  int retval = 0;
> > >> +#if defined(CONFIG_NET)
> > >> +  struct uevent_sock *ue_sk;
> > >> +  struct net *pns;
> > >> +  char *p;
> > >> +  u64 num;
> > >> +
> > >> +  /* grab the network namespace of the provided pid */
> > >> +  pns = get_net_ns_by_pid(pid);
> > >> +  if (pns == ERR_PTR(-ESRCH))
> > >> +          return -ESRCH;
> > >> +
> > >> +  /* find sequence number in buffer */
> > >> +  p = buf;
> > >> +  num = 0;
> > >> +  while (p < (buf + len)) {
> > >> +          if (strncmp(p, "SEQNUM=", 7) == 0) {
> > >> +                  int r;
> > >> +
> > >> +                  p += 7;
> > >> +                  r = kstrtoull(p, 10, &num);
> > >> +                  if (r) {
> > >> +                          put_net(pns);
> > >> +                          return r;
> > >> +                  }
> > >> +                  break;
> > >> +          }
> > >> +          p += (strlen(p) + 1);
> > >> +  }
> > > Ok, that's crazy, replacing an existing sequence number with a sequence
> > > number of the namespace?  An interesting hack, yes, but something we
> > > want to maintain for the next 20+ years, no.  Surely there's a better
> > > way to do this?
> > >
> > > But again, I'm not sold on this whole idea anyway.
> > >
> > > greg k-h
> > >
> > Re: the #if
> > The #if is only needed because the new udevns code references a
> > structure defined in that header.  Obviously it could be included
> > without consequences but I #if it to show it was part of the forwarding
> > code.
>
> That's not an issue, we don't put #ifdefs in .c code if at all possible,
> you will note that you added a bunch of them :(
>
> > Re: sequence #
> > I wanted it as transparent as possible, without this the udevd running
> > inside the container has issues with the values of the sequence numbers
> > seen, by making it tied to the namespace, udevd could run unchanged.
>
> Oh I know why you did it, I just don't like it :)
>
> > Our goal was to minimize the changes to a linux distro and still be able
> > to run a full desktop inside a container.  But even in absence of our
> > use case, the first question is should uevents be broadcasts to every
> > network namespace?  I don't think that broadcasting is the correct
> > action.  And follow on questions are what if anything should be done
> > with regards to uevents and containers.
>
> I don't think you should be running udevd within a container, as a
> device is never bound to a namespace (network devices are the only
> exception), it's a false thing to think that a uevent is only for a
> single namespace as well.  I understand your wish to change only the
> kernel to get unmodified userspace to run, but I suggest modifying your
> userspace instead :)

Greg,

I fully agree with you that running unmodified distro inside a
container is not a justified
cause for kernel changes.

However, I would like to highlight the point that udev is not the only
consumer of uevents,
so changing userspace, as you rightfully suggested, may not be as
simple as you imagine.

For example, in our Android use case, we have no intention of running
unmodified Android
inside container and modifying Android's ueventd is not an issue for us.
Android userspace uses uevents extensively. For example, vold uses uevents to be
notified of SDCARD insert event and that is just one example.
We can get around vold and maybe we can get around every other open
source Android tool
that make use of uevents, but phone vendors tend to use uevents to communicate
messages between their drivers and proprietary software and this is
were we must have
a way to filter those uevents in the kernel.

You argue that "device is never bound to a namespace" (and that it
never will be)
and I don't disagree with that.
However, as Eric said, the "broadcast everything" logic does not make
much sense.
In a way, the broadcast logic is opposite to your suggestion to modify
userspace.
In almost every existing implementation of containers, only the root namespace
owns responsibility for booting the machine and configuring devices, so if all
containers were running modified userspace, there would have been no need to
broadcast uevents to all namespaces.

At the very least, you should be able to consent with the idea of
having the broadcast
policy decided by userspace. Legacy distros can keep broadcast on by default to
not break unmodified userspace programs.
Modern distros, that were modified to run inside containers, be them
systemd driven or other,
can turn broadcast off and let the daemons running in root ns be in charge.

Many of us would like the feature that this patch set is set to achieve.
Can you please provide constructive feedback to Michael's work,
pointing at the parts you think can go into kernel this way or another
and the parts
for which you see a valid userspace alternative.

Thanks,
Amir.

>
> sorry,
>
> greg k-h
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
