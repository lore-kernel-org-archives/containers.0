From: Milan Broz <mbroz@redhat.com>
Subject: Re: [dm-devel] clone() with CLONE_NEWNET breaks kobject_uevent_env()
Date: Fri, 19 Aug 2011 13:59:55 +0200
Message-ID: <4E4E503B.3050406@redhat.com>
References: <4E4CDF44.5080109@redhat.com> <m17h69sr03.fsf@fess.ebiederm.org> <4E4E395B.7070106@redhat.com> <m1liup4oes.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1liup4oes.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: device-mapper development <dm-devel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kay Sievers <kay.sievers@vrfy.org>, "David S. Miller" <davem@davemloft.net>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On 08/19/2011 01:43 PM, Eric W. Biederman wrote:
> Milan Broz <mbroz@redhat.com> writes:
> 
>> On 08/19/2011 11:13 AM, Eric W. Biederman wrote:
>>> Milan Broz <mbroz@redhat.com> writes:
>>>
>>> I think the proper fix is to remove the error return from
>>> kobject_uevent_env and kobject_uevent, and make it harder to get calling
>>> of this function wrong.  Possibly in conjunction with that tag all of
>>> the memory allocations of kobject_uevent_env with GFP_NOFAIL or
>>> something so the memory allocator knows that this path is totally
>>> not able to deal with failure.
>>>
>>> Is kobject_uevent_env anything except an asynchronous best effort
>>> notification to user-space that a device has come or gone?
>>
>> Unfortunately it is for device-mapper. libdevmapper
>> depends on information that uevent was sent because udev rules uses
>> semaphore to inform that some action was taken.
>> So if dm-ioctl returns flag that uevent was not sent, it fallback
>> to different error path (otherwise it waits for completion forever).
>> (TBH I am more and more convinced this was not quite clever concept.)
> 
> If I understand your description and the code right the guarantee that
> you need is that kobject_uevent will return success only if it has
> queued a packet in every listening netlink socket.

I think so. IOW success == event was sent to all active listeners.

> We already ignore ENOBUFS so the guarantee you appear to need in
> libdevmapper does not appear to be present in kobject_uevent.
> 
> Does the libdevmapper code work despite getting a spurious failure?

BTW I do not see ENOBUFS but ESRCH (from netlink_broadcast_filtered).

If spurious failure is that event is sent (even partially) but it reports
failure, it is the exact situation I see now - libdevmapper will try
to decrement system semaphore which is already removed from udev rules.

Final state is correct, just it prints ugly warnings. IOW it recovers
from this situation correctly.

But Kay's suggestion to use netlink_has_listeners() seems like good
idea. IOW if there is no listener, it should skip quietly and not
fail the whole call...

Milan
