From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject and driver
	model
Date: Wed, 10 Oct 2007 07:16:48 -0600
Message-ID: <m14pgzun27.fsf@ebiederm.dsl.xmission.com>
References: <11902755392688-git-send-email-htejun@gmail.com>
	<20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com>
	<m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com>
	<20071005062302.GB16914@kroah.com>
	<m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com>
	<20071009225139.GF21228@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071009225139.GF21228-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> (Greg KH's message of "Tue, 9
	Oct 2007 15:51:39 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kay.sievers-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> writes:

> On Fri, Oct 05, 2007 at 06:12:41AM -0600, Eric W. Biederman wrote:
>> Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> writes:
>> >
>> >>   Also fun is that the dev file implementation needs to be able to
>> >>   report different major:minor numbers based on which mount of
>> >>   sysfs we are dealing with.
>> >
>> > Um, no, that's not going to happen.  /dev/sda will _always_ have the
>> > same major:minor number, as defined by the LSB spec.  You can not break
>> > that at all.  So while you might not want to show all mounts
>> > /sys/devices/block/sda/ the ones that you do, will all have the LSB
>> > defined major:minor number assigned to it.
>> 
>> Hmm.  If that is in the LSB it must come from
>> Documentation/devices.txt
>
> Yes, that is the requirement.
>
>> I'm not after changing the user visible major/minor assignments.
>
> Oh, I misunderstood what you wrote above then.

My above sentence is slightly misleading.  That should have been.
I am not after changing the device name to major:minor assignments
as specified in Documentation/devices.txt.

So within a single device namespace everything is normal and as it
always has been.  Weirdness only ensues when you look across device
namespaces.

>> Let me see if a concrete example will help.  Suppose I have
>> have a SAN with two disks:  disk-1 and disk-2.  I have
>> two machines A and B.  On machine A I get the mapping:
>> sda -> disk-1, sdb ->disk-2.  On machine B I wind up with
>> a different probe order so I get the mapping: sda -> disk-2
>> sdb ->disk-1.
>
> Ok.
>
>> To be very clear by sda I mean the block device with major 8 and
>> minor 0, and by sdb I mean the block device with major 8 and minor
>> 16.
>
> Ok.
>
>> So I decide I want an environment on machine B that looks just
>> like the environment on machine A, so I can bring transfer over
>> a running program or whatever.  So I run around looking at UUID
>> labels and what not and I discover that the machine B knows disk-1 as
>> sdb and that machine A knows disk-1 as sda.  So I want to say:
>> /sys/devices/block/sdb show up in this other device namespace as
>> /sys/devices/block/sda.

>
> Ah, but if you do that then the "other" device namespace would have
> /sys/devices/block/sda/dev be 8:16, right? 

No. The "other" device namespace I would construct on machine B to
look just like the device namespace that existed on machine A.
Making /sys/devices/block/sda would still be 8:0.

So to be very clear on machine B when talking about disk-1 I would have.
initial device namespace:
  /sys/devices/block/sdb
  /sys/devices/block/sdb/dev 8:16

"other" device namespace:
  /sys/devices/block/sda
  /sys/devices/block/sda/dev 8:0

Similarly on machine B when talking about disk-2 I would have.
initial device namespace:
  /sys/devices/block/sda
  /sys/devices/block/sda/dev 8:0

"other" device namespace:
  /sys/devices/block/sdb
  /sys/devices/block/sdb/dev 8:16

So between the two devices namespaces on machine B the two disks
would exchange their user visible identities.

Eric
