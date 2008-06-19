From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] cgroup: support checking of subsystem dependencies
Date: Thu, 19 Jun 2008 08:43:18 +0800
Message-ID: <4859ABA6.4000904@cn.fujitsu.com>
References: <4858C0ED.2080905@cn.fujitsu.com> <6599ad830806181413y5d0ef1bfyfc54c17ee904d744@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757671AbYFSApA@vger.kernel.org>
In-Reply-To: <6599ad830806181413y5d0ef1bfyfc54c17ee904d744@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

>>  static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>>  {
>>        int ret = 0;
>> @@ -852,6 +871,10 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>>        if (ret)
>>                goto out_unlock;
>>
>> +       ret = check_subsys_dependency(opts.subsys_bits);
>> +       if (ret)
>> +               goto out_unlock;
>> +
> 
> Can we just call this from one place, in parse_cgroupfs_options() ?
> 

I think yes we can. I'll revise it.
