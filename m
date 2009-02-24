From: anqin <anqin.qin@gmail.com>
Subject: Re: [RFC] [PATCH] cgroup: accounting and limitation of disk quota
Date: Tue, 24 Feb 2009 21:10:05 +0800
Message-ID: <d95d44a20902240510i16ae5785ob11b900daf7fe019@mail.gmail.com>
References: <d95d44a20902220437m2fb7af08y8c71fe275fe06a57@mail.gmail.com>
	 <20090223213749.GA945@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756997AbZBXNKZ@vger.kernel.org>
In-Reply-To: <20090223213749.GA945@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>, menage@google.com
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Rolando Martins <rolando.martins@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Thank you for so many valuable comment and advices.

I will fix the patch and provide more valuable development. :)


Thanks again,

Anqin

On Tue, Feb 24, 2009 at 5:37 AM, Serge E. Hallyn <serue@us.ibm.com> wrote:
> Quoting anqin (anqin.qin@gmail.com):
>> The patch presents a cgroup subsystem to control the usage of disk quota.
>>
>> The subsystem for disk quota (disk_cgroup, to be brief) does accounting
>> of inode and block allocated by ext3/ext2 filesystem. Simarily as
>> filesystem quota, the disk_cgroup can do limitation but without needing
>> to open filesytem quota options (e.g. usrquota,grpquota in /etc/fstab).
>>
>> The simple usage of disk_cgroup is as follows:
>>
>> # mount -t cgroup cgroup /mnt/cgrp
>> # lxc-execute -n lxc-template.conf /bin/bash
>> # ls /mnt/cgrp/11457/           // <--  11457 is the pid of bash
>> ...
>> disk.stat
>> disk.usage_in_inode
>> disk.usage_in_block
>> disk.max_usage_in_inode
>> disk.max_usage_in_block
>> disk.limit_in_inode
>> disk.limit_in_inode
>> ...
>>
>> # echo  3 > /mnt/cgrp/11457/disk.max_usage_in_block
>>
>> # touch /tmp/mytestfile1
>> # touch /tmp/mytestfile2
>> # touch /tmp/mytestfile3
>> # touch /tmp/mytestfile4
>> touch: cannot touch `/tmp/mytestfile4': Disk quota exceeded
>>
>> The disk_cgroup is easily extended to manage complex objects
>> of filesystem.
>>
>> Signed-off-by: An Qin <anqin.qin@gmail.com>
>
> It's probably worth sending this to linux-fsdevel as well as the
> ext2 and ext3 maintainers and lists (see MAINTAINERS - at
> least linux-ext4@vger.kernel.org).
>
>> +static struct cgroup_subsys_state *disk_cgroup_create(
>> +                     struct cgroup_subsys *ss, struct cgroup *cont)
>> +{
>> +     struct disk_cgroup *disk;
>> +
>> +     if (!capable(CAP_SYS_ADMIN))
>> +             return ERR_PTR(-EPERM);
>
> On the whole it is preferred to let the cgroup uid permissions
> handle access control, and not check CAP_SYS_ADMIN for cgroup
> creation.
>
>> +     if (!cgroup_is_descendant(cont))
>> +             return ERR_PTR(-EPERM);
>> +
>> +     disk = kzalloc(sizeof(struct disk_cgroup), GFP_KERNEL);
>
> So you are setting all the limits to 0, with 0 meaning unlimited, at
> cgroup create?  What do you think about copying the parent cgroup's
> limits?
>
>> --- linux-2.6.28.5/kernel/Makefile    2009-02-13 01:51:15.000000000 +0800
>> +++ linux-2.6.28.5-cgroup-disk-quota/kernel/Makefile  2009-02-19
>> 06:52:04.000000000 +0800
>> @@ -55,6 +55,7 @@ obj-$(CONFIG_COMPAT) += compat.o
>>  obj-$(CONFIG_CGROUPS) += cgroup.o
>>  obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
>>  obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
>> +obj-$(CONFIG_CGROUP_FREEZER) += cgroup_disk.o
>
> I don't think you wanted to put this under _FREEZER :)
>
>>  obj-$(CONFIG_CPUSETS) += cpuset.o
>>  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
>>  obj-$(CONFIG_UTS_NS) += utsname.o
>
> per-container quota has been mentioned before as a desireable
> feature so thanks for working on this.
>
> -serge
>
