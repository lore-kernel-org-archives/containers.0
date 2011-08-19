From: Milan Broz <mbroz@redhat.com>
Subject: Re: [dm-devel] clone() with CLONE_NEWNET breaks kobject_uevent_env()
Date: Fri, 19 Aug 2011 12:22:19 +0200
Message-ID: <4E4E395B.7070106@redhat.com>
References: <4E4CDF44.5080109@redhat.com> <m17h69sr03.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m17h69sr03.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: device-mapper development <dm-devel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kay Sievers <kay.sievers@vrfy.org>, "David S. Miller" <davem@davemloft.net>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


On 08/19/2011 11:13 AM, Eric W. Biederman wrote:
> Milan Broz <mbroz@redhat.com> writes:
> 
> I think the proper fix is to remove the error return from
> kobject_uevent_env and kobject_uevent, and make it harder to get calling
> of this function wrong.  Possibly in conjunction with that tag all of
> the memory allocations of kobject_uevent_env with GFP_NOFAIL or
> something so the memory allocator knows that this path is totally
> not able to deal with failure.
> 
> Is kobject_uevent_env anything except an asynchronous best effort
> notification to user-space that a device has come or gone?

Unfortunately it is for device-mapper. libdevmapper
depends on information that uevent was sent because udev rules uses
semaphore to inform that some action was taken.
So if dm-ioctl returns flag that uevent was not sent, it fallback
to different error path (otherwise it waits for completion forever).
(TBH I am more and more convinced this was not quite clever concept.)

But the whole concept "send event to the list of namespaces, maybe someone listen"
seems also not quite clever to me :-)

How much time consuming is that? If you create thousand(s) of cloned namespaces,
how it will perform with uevent notification performance?
(IOW first event is sent through netlink and 999+ reports failure... strange.)

Milan
