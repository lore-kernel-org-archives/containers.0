From: David Lang <david-gFPdbfVZQbY@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Wed, 26 Jun 2013 16:14:07 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1306261609050.22572__7449.88255105472$1372292552$gmane$org@nftneq.ynat.uz>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAAAKZws1qkSik4G4pRr7z+067Jp9-jHfpx9-euqbvmdHjoN_Zg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Jun 2013, Tim Hockin wrote:

> On Wed, Jun 26, 2013 at 2:20 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> Hello, Tim.
>>
>> On Mon, Jun 24, 2013 at 09:07:47PM -0700, Tim Hockin wrote:
>>> I really want to understand why this is SO IMPORTANT that you have to
>>> break userspace compatibility?  I mean, isn't Linux supposed to be the
>>> OS with the stable kernel interface?  I've seen Linus rant time and
>>> time again about this - why is it OK now?
>>
>> What the hell are you talking about?  Nobody is breaking userland
>> interface.  A new version of interface is being phased in and the old
>
> The first assertion, as I understood, was that (eventually) cgroupfs
> will not allow split hierarchies - that unified hierarchy would be the
> only mode.  Is that not the case?
>
> The second assertion, as I understood, was that (eventually) cgroupfs
> would not support granting access to some cgroup control files to
> users (through chown/chmod).  Is that not the case?

As a bystander, what I understand to be happening is:

1. the Kernel developers are saying that multiple hierarchies is causing lots of 
problems, and so they are starting the migration to a unified hierarchy. In the 
near term this will be optional, at a later (unspecified) point, it will no 
longer be optional.

It is recognized that this is an API break, but the problem is bad enough (too 
much undefined behavior) that it looks like they are going to do this anyway.


2. indpendantly from this, the systemd people have declared that systemd is 
going to take control of this unified hierarchy and all applications had better 
use DBUS calls to systemd to make any cgroup changes or else. (i.e. systemd may 
break whatever you are doing)


I don't think the kernel developers are talking about changing ways to control 
cgroups, just eliminating having multiple hierarchies.



Now, I could be completely misunderstanding this (and I expect to hear about it 
if I am :-)

David Lang
