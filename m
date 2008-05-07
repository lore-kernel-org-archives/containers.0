From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Wed, 7 May 2008 08:17:12 -0500
Message-ID: <20080507131712.GA8580__22760.2085601122$1210166350$gmane$org@sergelap.austin.ibm.com>
References: <20080211141646.948191000@bull.net>
	<20080211141813.354484000@bull.net>
	<12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
	<481EC917.6070808@bull.net>
	<1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
	<20080506180527.GA8315@sergelap.austin.ibm.com>
	<48214007.7050800@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48214007.7050800-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nadia Derbey (Nadia.Derbey-6ktuUTfB/bM@public.gmane.org):
> Serge E. Hallyn wrote:
>> Quoting Luck, Tony (tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org):
>>>> Well, this printk had been suggested by somebody (sorry I don't remember 
>>>> who) when I first submitted the patch. Actually I think it might be 
>>>> useful for a sysadmin to be aware of a change in the msgmni value: we 
>>>> have the message not only at boot time, but also each time msgmni is 
>>>> recomputed because of a change in the amount of memory.
>>>
>>> If the message is directed at the system administrator, then it would
>>> be nice if there were some more meaningful way to show the namespace
>>> that is affected than just printing the hex address of the kernel 
>>> structure.
>>>
>>> As the sysadmin for my test systems, printing the hex address is mildly
>>> annoying ... I now have to add a new case to my scripts that look at
>>> dmesg output for unusual activity.
>>>
>>> Is there some better "name for a namespace" than the address? Perhaps
>>> the process id of the process that instantiated the namespace???
>> I agree with Tony here.  Aside from the nuisance it is to see that
>> message on console every time I unshare a namespace, a printk doesn't
>> seem like the right way to output the info.
>
> But you agree that this is happening only because you're doing tests 
> related to namespaces, right?

Yup :)

> I don't think that in a "standard" configuration this will happen very 
> frequently, but may be I'm wrong.
>
>>  At most I'd say an audit
>> message.
>
> That's a good idea. Thanks, Serge. I'll do that.

It'll probably still end up a printk for me, but it'll be my own fault
for not setting up audit.

> Regards,
> Nadia

thanks,
-serge
