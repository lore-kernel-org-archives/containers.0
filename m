From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [dm-devel] clone() with CLONE_NEWNET breaks kobject_uevent_env()
Date: Fri, 19 Aug 2011 04:43:39 -0700
Message-ID: <m1liup4oes.fsf@fess.ebiederm.org>
References: <4E4CDF44.5080109@redhat.com> <m17h69sr03.fsf@fess.ebiederm.org>
	<4E4E395B.7070106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E4E395B.7070106@redhat.com> (Milan Broz's message of "Fri, 19
	Aug 2011 12:22:19 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Milan Broz <mbroz@redhat.com>
Cc: device-mapper development <dm-devel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kay Sievers <kay.sievers@vrfy.org>, "David S. Miller" <davem@davemloft.net>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Milan Broz <mbroz@redhat.com> writes:

> On 08/19/2011 11:13 AM, Eric W. Biederman wrote:
>> Milan Broz <mbroz@redhat.com> writes:
>> 
>> I think the proper fix is to remove the error return from
>> kobject_uevent_env and kobject_uevent, and make it harder to get calling
>> of this function wrong.  Possibly in conjunction with that tag all of
>> the memory allocations of kobject_uevent_env with GFP_NOFAIL or
>> something so the memory allocator knows that this path is totally
>> not able to deal with failure.
>> 
>> Is kobject_uevent_env anything except an asynchronous best effort
>> notification to user-space that a device has come or gone?
>
> Unfortunately it is for device-mapper. libdevmapper
> depends on information that uevent was sent because udev rules uses
> semaphore to inform that some action was taken.
> So if dm-ioctl returns flag that uevent was not sent, it fallback
> to different error path (otherwise it waits for completion forever).
> (TBH I am more and more convinced this was not quite clever concept.)

If I understand your description and the code right the guarantee that
you need is that kobject_uevent will return success only if it has
queued a packet in every listening netlink socket.

We already ignore ENOBUFS so the guarantee you appear to need in
libdevmapper does not appear to be present in kobject_uevent.

Does the libdevmapper code work despite getting a spurious failure?

If libdevmapper does not work despite a spurious failure I don't see how
we could possibly fix kobject_uevent when there is more than one netlink
listener.

Eric
