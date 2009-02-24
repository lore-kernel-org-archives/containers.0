From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 09:25:33 +0100
Message-ID: <49A3AEFD.3050705@fr.ibm.com>
References: <20090224030347.GA10913@us.ibm.com>	<20090224030933.GC11441@us.ibm.com> <20090224043512.GA3202@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754957AbZBXIZu@vger.kernel.org>
In-Reply-To: <20090224043512.GA3202@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Mon, Feb 23, 2009 at 09:09:33PM -0600, Serge E. Hallyn wrote:
>> +#ifdef CONFIG_PROC_FS
>> +static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
>> +	void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +	struct ctl_table mq_table;
>> +	memcpy(&mq_table, table, sizeof(mq_table));
>> +	mq_table.data = get_mq(table);
>> +
>> +	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
>> +}
>> +
>> +static int proc_mq_dointvec_minmax(ctl_table *table, int write,
>> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +	struct ctl_table mq_table;
>> +	memcpy(&mq_table, table, sizeof(mq_table));
>> +	mq_table.data = get_mq(table);
>> +
>> +	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
>> +					lenp, ppos);
>> +}
>> +#else /* CONFIG_PROC_FS */
>> +static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
>> +	void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +	return -ENOSYS;
>> +}
>> +
>> +static int proc_mq_dointvec_minmax(ctl_table *table, int write,
>> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +	return -ENOSYS;
>> +}
>> +#endif /* CONFIG_PROC_FS */
> 
> These should be under CONFIG_PROC_SYSCTL and one should define them to
> NULL otherwise.

ipc_sysctl.c and utsname_sysctl.c need to fix the CONFIG_PROC_FS #ifdef.

C.
