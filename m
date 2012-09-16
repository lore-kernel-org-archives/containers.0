From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Controlling devices and device namespaces
Date: Sun, 16 Sep 2012 10:49:07 -0700
Message-ID: <87zk4pluy4.fsf@xmission.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<20120915022037.GA6438@mail.hallyn.com>
	<87wqzv7i08.fsf_-_@xmission.com>
	<20120915220520.GA11364@mail.hallyn.com> <87y5kazuez.fsf@xmission.com>
	<20120916122112.3f16178d@pyramind.ukuu.org.uk>
	<87sjaiuqp5.fsf@xmission.com> <87d31mupp3.fsf@xmission.com>
	<5055D4D1.3070407@hallyn.com> <87k3vuqc5l.fsf@xmission.com>
	<20120916171316.517ad0fd@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120916171316.517ad0fd-38n7/U1jhRXW96NNrWNlrekiAK3p4hvP@public.gmane.org> (Alan Cox's
	message of "Sun, 16 Sep 2012 17:13:16 +0100")
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
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> writes:

>> At least with a recent modern distro I can't imagine this to be an
>> issue.  I expect we could have a kernel build option that removed the
>> mknod system call and a modern distro wouldn't notice.
>
> A few things beyond named pipes will break. PCMCIA I believe still
> depends on ugly mknod hackery of its own. You also need it for some
> classes of non detectable device.
>
> Basically though you could.

Ah yes fifos.  I had forgotten mknod created them.  I am half surprised
there isn't a mkfifo system call.

>> For migration with direct access to real hardware devices we must treat
>> it as hardware hotunplug.  There is nothing else we can do.
>
> That is demonstrably false for a shared bus or a network linked device.
> Consider a firewire camera wired to two systems at once. Consider SAN
> storage.

Sort of.

If you are talking to the device directly there is usually enough state
with the path changing that modelling it as a hotunplug/hotplug is about
all that is practical.  There is all of that intermediate state for in
progress DMAs in the end system controllers etc.

Now if you have a logical abstraction like a block device in between the
program and the SAN storage, then figuring out how to preserve device
names and numbers becomes interesting.  At least far enough to keep
device and inode numbers for stat intact.

A fully general solution for preserving device names, and numbers
requires rewriting sysfs.  I expect a lot of the infrastructure someone
needs is there already from my network namespace work but after having
done the network namespace I am sick and tired of manhandling that
unreasonably conjoined glob of device stuff.

Eric
