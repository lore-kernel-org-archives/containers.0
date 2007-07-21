From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm PATCH 1/8] Memory controller resource counters (v3)
Date: Sat, 21 Jul 2007 22:30:57 +0530
Message-ID: <46A23BC9.2050003@linux.vnet.ibm.com>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop> <20070720082403.20752.68425.sendpatchset@balbir-laptop> <6599ad830707201320q25c0ded9v937a365a53d9a77@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757139AbXGURBV@vger.kernel.org>
In-Reply-To: <6599ad830707201320q25c0ded9v937a365a53d9a77@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric W Biederman <ebiederm@xmission.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> +
>> +ssize_t res_counter_read(struct res_counter *counter, int member,
>> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
>> +{
>> +       unsigned long *val;
>> +       char buf[64], *s;
>> +
>> +       s = buf;
>> +       val = res_counter_member(counter, member);
>> +       s += sprintf(s, "%lu\n", *val);
>> +       return simple_read_from_buffer((void __user *)userbuf, nbytes,
>> +                       pos, buf, s - buf);
>> +}
> 
> I think it should be possible to use the support built-in to task
> containers to export a uint64 rather than having to create a separate
> function here.
> 

That sounds like an easy thing to do, but that means we need to standardize
on the uint64 data type for all platforms.

>> +
>> +ssize_t res_counter_write(struct res_counter *counter, int member,
>> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
>> +{
>> +       int ret;
>> +       char *buf, *end;
>> +       unsigned long tmp, *val;
>> +
>> +       buf = kmalloc(nbytes + 1, GFP_KERNEL);
>> +       ret = -ENOMEM;
>> +       if (buf == NULL)
>> +               goto out;
>> +
>> +       buf[nbytes] = '\0';
>> +       ret = -EFAULT;
>> +       if (copy_from_user(buf, userbuf, nbytes))
>> +               goto out_free;
>> +
>> +       ret = -EINVAL;
>> +       tmp = simple_strtoul(buf, &end, 10);
>> +       if (*end != '\0')
>> +               goto out_free;
>> +
>> +       val = res_counter_member(counter, member);
>> +       *val = tmp;
>> +       ret = nbytes;
>> +out_free:
>> +       kfree(buf);
>> +out:
>> +       return ret;
>> +}
> 
> I should probably add a generic "write uint64" wraper to task
> containers as well.
> 

Sounds good, that will be really helpful.

> Paul
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
