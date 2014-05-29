From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2] /proc/pid/status: show all sets of pid according to ns
Date: Thu, 29 May 2014 13:41:09 +0400
Message-ID: <538700B5.5070601@parallels.com>
References: <1401272683-1659-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5385DA19.2060008@parallels.com> <20140528182824.GA5057@cachalot>
	<53863889.9080509@parallels.com> <20140529055954.GA10354@cachalot>
	<5386F8EA.8050501@parallels.com> <5386FC0C.9000307@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5386FC0C.9000307-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 05/29/2014 01:21 PM, Richard Weinberger wrote:
> Am 29.05.2014 11:07, schrieb Pavel Emelyanov:
>> On 05/29/2014 09:59 AM, Vasily Kulikov wrote:
>>> On Wed, May 28, 2014 at 23:27 +0400, Pavel Emelyanov wrote:
>>>> On 05/28/2014 10:28 PM, Vasily Kulikov wrote:
>>>>> On Wed, May 28, 2014 at 16:44 +0400, Pavel Emelyanov wrote:
>>>>> It will be simplier
>>>>> to parse the file -- if 'ns_ids' file contains some ID then this ID for
>>>>> every ns can be obtained regardless of the specific ID name (SID, PID,
>>>>> PGID, etc.).
>>>>
>>>> True, but given a task PID how to determine which pid namespaces it lives in
>>>> to get the idea of how PIDs map to each other? Maybe we need some explicit
>>>> API for converting (ID, NS1, NS2) into (ID)?
>>>
>>> AFAIU the idea of the patch is to add a new debugging information which
>>> can be trivially obtained via 'cat /proc/...':
>>
>> I agree, but this ability will be very useful by checkpoint-restore project
>> too and I'd really appreciate if the API we have for that would be scalable
>> enough. Per-task proc file works for me, but how about sid-s and pgid-s?
> 
> What kind of information does CRIU need?

We need to know what pid namespaces a task lives in and how pid, sid and
pgid look in all of them. A short example with pids only

Task t1 with pid 2, lives in init pid ns calls clone(CLONE_NEWPID), creates
ns1 with task t2 having pid (3, 1), then t2 calls clone(CLONE_NEWPID) again
and creates ns2 with task t3 having pid (4, 5, 1). I.e. the trees look like 
this:

    init_pid_ns    ns1         ns2
t1  2
t2   `- 3          1 
t3       `- 4      `- 5        1

Also note, that /proc/pid/ns will show us that t1 lives in init_pid_ns,
t2 lives in ns1 and t3 lives in ns2.

Now if we come from init pid ns with criu and try to dump task with pid 3
(i.e. the t2), the existing kernel API can tell us that:

a) t2 lives in ns1 != init_pid_ns (via /proc/pid/ns link)
b) t3 lives in ns2 != init_pid_ns
c) t2 has pid 3 (via init's /proc) in init ns and pid 1 in its ns (via t2's /proc)
d) t3 has pid 4 in init ns and pid 1 in its ns

what we also need to know and don't yet have an API for is

e) ns2 is the child of ns1
f) t3 has pid 5 in ns1

Thanks,
Pavel
