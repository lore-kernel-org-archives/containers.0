From: Mike Heffner <mikeh-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org>
Subject: Re: Mapping PIDs from parent->child namespaces
Date: Tue, 04 Jan 2011 15:17:48 -0500
Message-ID: <4D23806C.5040806@fesnel.com>
References: <4D225579.6030106@fesnel.com> <4D23451B.6060807@free.fr>
	<4D234E77.6000605@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D234E77.6000605-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/04/2011 11:44 AM, Cedric Le Goater wrote:
> On 01/04/2011 05:04 PM, Daniel Lezcano wrote:
>> On 01/04/2011 12:02 AM, Mike Heffner wrote:
>>> Hi,
>>>
>>> Is it possible for a process running in a parent PID namespace to map
>>> the PID of a process running in a child's namespace from the
>>> parent->child's namespace? For example, if I span the process "myproc"
>>> with CLONE_NEWPID then a call to getpid() inside myproc will return "1"
>>> whereas in the parent's namespace that process could actually be PID
>>> "23495". I'd like to be able to know that 23495 maps to 1 in the new NS.
>>> Obviously, just mapping the first PID is straightforward since I can
>>> just look at the result of clone(). However, mapping the PIDs of
>>> processes subsequently forked from "myproc" -- in this example -- I
>>> haven't been able to figure out.
>>
>> AFAIK, it is not possible.
>>
>> That would be very nice to show the pid<->  vpid association.
>>
>> The procfs is a good candidate to show these informations.
>>
>> That would makes sense to show the content of /proc/<pid>/status with
>> the pid relatively to the namespace.
>>
>> Let me give an example:
>>
>> Assuming the process '1234' creates a new pid namespace, and the child
>> which is '1' in the new namespace has the real pid '4321'. This one
>> mounts its /proc.
>>
>> If the process '1234' looks at /proc/4321/root/proc/1/status, it sees:
>>
>> ...
>> Tgid:	1
>> Pid:	1
>> PPid:	0
>> ...
>>
>>
>> It could be:
>>
>> ...
>> Tgid:	4321
>> Pid:	4321
>> PPid:	1234
>> ...
>>
>> as the file is inspected from the parent namespace. Of course, if the
>> file is looked from the child namespace context, we will see '1', '1'
>> and '0'.
>>
>> I suppose the patch in the kernel should very small also.
>>
>> Thoughts ?
>
> we use the following patch to get the pid of a task as seen from its
> pid namespace. It can be useful to identify tasks writing pids in files.
>

Great, I'll try it out. Has there been any interest in getting this into 
the mainline? Are there negatives to advertising child vpid's?


Cheers,

Mike
