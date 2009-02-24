From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: debugging threaded apps running under a clone(CLONE_NEWPID)
Date: Tue, 24 Feb 2009 13:09:40 +0100
Message-ID: <49A3E384.2050308@fr.ibm.com>
References: <499EE0D1.1010001@fr.ibm.com>  <20090223182153.GD13151@us.ibm.com> <49A3C314.6010806@fr.ibm.com> <1235474932.12827.62.camel@bahia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755091AbZBXMKA@vger.kernel.org>
In-Reply-To: <1235474932.12827.62.camel@bahia>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Greg Kurz wrote:
> On Tue, 2009-02-24 at 10:51 +0100, Cedric Le Goater wrote:
>> Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
>> ---
>>  fs/proc/base.c |   19 +++++++++++++++++++
>>  1 file changed, 19 insertions(+)
>>
>> Index: 2.6.27-mcr.git/fs/proc/base.c
>> ===================================================================
>> --- 2.6.27-mcr.git.orig/fs/proc/base.c
>> +++ 2.6.27-mcr.git/fs/proc/base.c
>> @@ -2444,6 +2444,23 @@ static int proc_tgid_io_accounting(struc
>>  }
>>  #endif /* CONFIG_TASK_IO_ACCOUNTING */
>>
>> +static int proc_pid_vpids(struct task_struct *task, char *buffer)
>> +{
>> +	struct pid_namespace *pid_ns = task->nsproxy->pid_ns;
>> +
> 
> This breaks if task is a zombie...

Indeed. I'll be careful to fix this case in the next patch if it becomes more 
than a concept.

Thanks,

C. 
