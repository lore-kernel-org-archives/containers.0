From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Controlling devices and device namespaces
Date: Sun, 16 Sep 2012 04:56:06 -0700
Message-ID: <87sjaiuqp5.fsf@xmission.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<20120915022037.GA6438@mail.hallyn.com>
	<87wqzv7i08.fsf_-_@xmission.com>
	<20120915220520.GA11364@mail.hallyn.com> <87y5kazuez.fsf@xmission.com>
	<20120916122112.3f16178d@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120916122112.3f16178d-38n7/U1jhRXW96NNrWNlrekiAK3p4hvP@public.gmane.org> (Alan Cox's
	message of "Sun, 16 Sep 2012 12:21:12 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> writes:

>> One piece of the puzzle is that we should be able to allow unprivileged
>> device node creation and access for any device on any filesystem
>> for which it unprivileged access is safe.
>
> Which devices are "safe" is policy for all interesting and useful cases,
> as are file permissions, security tags, chroot considerations and the
> like.
>
> It's a complete non starter.

There are a handful of device nodes that the kernel creates with mode
0666.  Esentially it is just /dev/tty /dev/null /dev/zero and a few
others.  Enourmous numbers of programs won't work without them.  Making
them both interesting and useful.

In very peculiar cases I can see not wanting to have access to generally
safe devices, like in other peculiar cases we don't have want access to
the network stack.


As for the general case device nodes for real hardware in a container
which I think is the "interesting" case you were referring to.  I
personally find that case icky and boring.

The sanest way I can think of handling real hardware device nodes is a
tmpfs (acting like devtmpfs) mounted on /dev in the containers mount
namespace, but also visible outside to the global root mounted somewhere
interesting.  We have a fuse filesystem pretending to be sysfs and
relaying file accesses from the real sysfs for just the devices that we
want to allow to that container.

Then to add a device in a container the managing daemon makes the
devices available in the pretend sysfs, calls mknod on the tmpfs
and fakes the uevents.


The only case I don't see that truly covering is keeping the stat data
the same for files of migrated applications.  Shrug perhaps that will
just have to be handled with another synthesized uevent.  Hey userspace I
just hot-unplugged and hot-plugged your kernel please cope.

Eric
