From: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Announce] Checkpoint-restore tool v0.1
Date: Tue, 31 Jul 2012 14:30:07 +0400
Message-ID: <20120731103007.GE2007@moon>
References: <500D1116.7070301@parallels.com>
	<CAFLxGvwUhEPNdQvUnue2QFu_EipmBKD3nf0MfMWkqwLTf7jd5Q@mail.gmail.com>
	<50179CF0.7050200@parallels.com>
	<CAFLxGvygCxER3gHfj-onwnm_m6xugOVkynGyJU2CDheD3A2HOQ@mail.gmail.com>
	<5017A053.9000206@parallels.com>
	<CAFLxGvy396+BfYSaSnvAwJb0GO4WZCKbPXSbU7YfrOJTo6zk6A@mail.gmail.com>
	<5017AB41.60700@parallels.com>
	<CAFLxGvwu8-ii7hDbDfco3JrgKgOK+hsdTN_Q--AHbom0Ni8WYA@mail.gmail.com>
	<20120731101603.GD2007@moon>
	<CAFLxGvxgq9HJJvRgz=z48D7V_j=dTv4jSCLqEZcE=oCBAXnSug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAFLxGvxgq9HJJvRgz=z48D7V_j=dTv4jSCLqEZcE=oCBAXnSug-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "lwn-T1hC0tSOHrs@public.gmane.org" <lwn-T1hC0tSOHrs@public.gmane.org>, cgroups mailinglist <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 31, 2012 at 12:21:58PM +0200, richard -rw- weinberger wrote:
> On Tue, Jul 31, 2012 at 12:16 PM, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > On Tue, Jul 31, 2012 at 12:08:22PM +0200, richard -rw- weinberger wrote:
> >> On Tue, Jul 31, 2012 at 11:54 AM, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> >> >> Yeah, but I fear it's not that easy.
> >> >> We'd have to change crtools to work without ptrace().
> >> >
> >> > Well, this is hard. Using ptrace saved us from having many special-purpose
> >> > APIs for dumping various stuff (there will be an article about it). Thus I
> >> > don't know which way is simpler -- stop using ptrace or teach ptrece to allow
> >> > several tracers to attach to one task %)
> >>
> >> Allowing multiple tracers in a safe way is IMHO even more harder.
> >>
> >> BTW:  While reading prctl_set_mm() I noticed two things.
> >> 1.  Why isn't the return value of find_vma() verified?
> >
> > prctl_set_mm
> >         vma = find_vma(mm, addr);
> >         ...
> >         if (!vma) {
> >                 error = -EFAULT;
> >                 goto out;
> >         }
> >
> > these values are used in procfs statistics only. So I don't get
> > which verify you mean here.
> 
> If I do PR_SET_MM_START_BRK the if(!vma) will never be executed because
> there a break in case PR_SET_MM_START_BRK.

Yes, and this is done by purpose, since we need to setup _completely_
new memory map on restore procedure.

There is a minimal check for value being sane

	if (addr >= TASK_SIZE || addr < mmap_min_addr)
		return -EINVAL;

and the address belongs to mm::start_data|end_data area. But sure,
better to add checks that at least code/data areas do exist, otherwise
the proc output will not reflect the real state of memory maps.

	Cyrill
