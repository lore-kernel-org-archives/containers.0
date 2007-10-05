From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject
 and	driver model
Date: Fri, 05 Oct 2007 17:03:54 +0400
Message-ID: <4706363A.9030807@sw.ru>
References: <11902755392688-git-send-email-htejun@gmail.com>	<20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com>	<m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com>	<20071005062302.GB16914@kroah.com> <m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762701AbXJENAa@vger.kernel.org>
In-Reply-To: <m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Greg KH <greg@kroah.com> writes:
> 
>>>  Also fun is that the dev file implementation needs to be able to
>>>  report different major:minor numbers based on which mount of
>>>  sysfs we are dealing with.
>>
>>Um, no, that's not going to happen.  /dev/sda will _always_ have the
>>same major:minor number, as defined by the LSB spec.  You can not break
>>that at all.  So while you might not want to show all mounts
>>/sys/devices/block/sda/ the ones that you do, will all have the LSB
>>defined major:minor number assigned to it.
> 
> 
> Hmm.  If that is in the LSB it must come from
> Documentation/devices.txt  I'm not after changing the user
> visible major/minor assignments.
> 
> Let me see if a concrete example will help.  Suppose I have
> have a SAN with two disks:  disk-1 and disk-2.  I have
> two machines A and B.  On machine A I get the mapping:
> sda -> disk-1, sdb ->disk-2.  On machine B I wind up with
> a different probe order so I get the mapping: sda -> disk-2
> sdb ->disk-1.
> 
> To be very clear by sda I mean the block device with major 8 and
> minor 0, and by sdb I mean the block device with major 8 and minor
> 16.
> 
> So I decide I want an environment on machine B that looks just
> like the environment on machine A, so I can bring transfer over
> a running program or whatever.  So I run around looking at UUID
> labels and what not and I discover that the machine B knows disk-1 as
> sdb and that machine A knows disk-1 as sda.  So I want to say:
> /sys/devices/block/sdb show up in this other device namespace as
> /sys/devices/block/sda.

Imho environments to be migratable should have no direct access to the devices.
You can use any of stacked virtual filesystems to hide real
device from container.
You will have problems much bigger than this one otherwise
(imagine access to video, sound etc.)

Kirill
