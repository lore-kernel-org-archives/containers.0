From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Thu, 21 Aug 2014 08:54:57 -0500
Message-ID: <87zjeyvtfy.fsf@x220.int.ebiederm.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
	<87vbpm4f4y.fsf@x220.int.ebiederm.org> <53F591E7.3010509@nod.at>
	<53F59EC7.6060107@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53F59EC7.6060107-/L3Ra7n9ekc@public.gmane.org> (Richard Weinberger's message of "Thu,
	21 Aug 2014 09:24:55 +0200")
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
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:

> Am 21.08.2014 08:29, schrieb Richard Weinberger:
>> Am 21.08.2014 06:53, schrieb Eric W. Biederman:
>>> The bugs fixed are security issues, so if we have to break a small
>>> number of userspace applications we will.  Anything that we can
>>> reasonably do to avoid regressions will be done.
>>>
>>> Could you please look at my user-namespace.git#for-next branch I have a
>>> fix for at least one regresion causing issue in there.  I think it may
>>> fix your issues but I am not fully certain more comments below.
>> 
>> I'll run this on my LXC testbed today.
>
> Looks good. With these patches applied libvirt works again. :)

Darn I read my email in the wrong order.  I am glad to hear that my
changes were enough to fix libvirt-lxc.

I will aim at pushing this to Linus after the conference is over and I
can trust myself to think clearly.

Eric
