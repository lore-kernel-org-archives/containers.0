From: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
Subject: Re: [Bugme-new] [Bug 11391] New: Kernel NULL pointer dereference in
	do_notify_parent()
Date: Fri, 22 Aug 2008 08:33:52 +0200
Message-ID: <48AE5DD0.5070904@exasol.com>
References: <bug-11391-10286@http.bugzilla.kernel.org/>
	<20080821092322.76621dab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821092322.76621dab.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=11391
>>
>>            Summary: Kernel NULL pointer dereference in do_notify_parent()
>>            Product: Process Management
>>            Version: 2.5
>>      KernelVersion: 2.6.26.3
> 
> Should have been 2.6.26.4?
> 
>> [...]
>>
>> Latest working kernel version: 2.6.26.3
>>
>> Earliest failing kernel version: 2.6.25.4 (didn't test with former kernels)
> 
> Appears to be a regression in -stable.   Did any namespacy things go into
> 2.6.26.4?

Oops, my mistake. I accidentially marked 2.6.26.3 as the latest working 
kernel. I didn't mean to do so (I tested 2.6.25.4, 2.6.26.2 and 2.6.26.3 
and all of these kernels crashed).

As far as I understand the problem and the appropriate source code right 
now, I assume that this problem was introduced with PID namespaces in 
2.6.24 and did not affect former kernels (because these didn't have this 
feature).

I'll try Oleg's posted patch as soon as possible and look what happens.

Sorry for that confusion!

Thanks,
Robert
