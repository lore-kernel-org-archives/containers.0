From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Thu, 05 Mar 2009 09:20:42 +0100
Message-ID: <49AF8B5A.4080505__32024.0621957511$1236241406$gmane$org@free.fr>
References: <20090227203425.F3B51176@kernel>	<20090227203435.98735E54@kernel>
	<20090302133754.GA8033@us.ibm.com>	<20090302095917.6cfeda55@thinkcentre.lan>	<1236011251.26788.450.camel@nimitz>	<20090302112247.76bb3662@thinkcentre.lan>	<1236015052.26788.471.camel@nimitz>
	<20090302174433.GA12708@us.ibm.com>
	<1236017600.26788.488.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236017600.26788.488.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Mon, 2009-03-02 at 11:44 -0600, Serge E. Hallyn wrote:
>> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>> On Mon, 2009-03-02 at 11:22 -0600, Nathan Lynch wrote:
>>>> No.. I mean what if a process 1234 does
>>>>
>>>> f = fopen("/proc/1234/stat", "r");
>>>>
>>>> and is then checkpointed.  Can that path be resolved during restart,
>>>> before pid 1234 is alive?
>>> Heh, that's a good one.
>>>
>>> It does mean that we can't do restore like this:
>>>
>>> 	for_each_cr_task()
>>> 		restore_task_struct()
>>> 		restore_files()
>>> 		...
>>>
>>> We have to do:
>>>
>>> 	for_each_cr_task()
>>> 		restore_task_struct()
>>> 	for_each_cr_task()
>>> 		restore_files()
>>>
>> Which is what we actually do, right?
> 
> OK, I have a really evil one.
> 
> What if task 1234 does:
> 
> 	open(O_RDONLY, "/proc/5678/fdinfo/44");
> 
> and task 5678 does:
> 
> 	open(O_RDONLY, "/proc/5678/fdinfo/55");
> 
> There is no right order.
> 
> The only right way I can think to do it is that we have to loop on the
> restore and defer files that we can't seem to find right now, hoping
> that they'll show up as the restore progresses.

or the restore algorithm should support recursion. for example, epoll, 
attached 'struct files' to af_unix socket, pipes (2 ends), fifos (idem),
connected socket (you need the listening end), etc. 

C.

> Basically:
> 
> 	for_each_cr_task()
> 		deferred_files = restore_files()
> retry:
> 	making_progress = 0
> 	for_each(deferred_file)
> 		restore(deferred_file)
> 	if (making_progress)
> 		goto retry;
