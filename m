From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH v2] /proc/pid/status: show all sets of pid according to ns
Date: Thu, 29 May 2014 11:21:16 +0200
Message-ID: <5386FC0C.9000307__1644.39842706106$1401355696$gmane$org@nod.at>
References: <1401272683-1659-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5385DA19.2060008@parallels.com> <20140528182824.GA5057@cachalot>
	<53863889.9080509@parallels.com> <20140529055954.GA10354@cachalot>
	<5386F8EA.8050501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5386F8EA.8050501-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 29.05.2014 11:07, schrieb Pavel Emelyanov:
> On 05/29/2014 09:59 AM, Vasily Kulikov wrote:
>> On Wed, May 28, 2014 at 23:27 +0400, Pavel Emelyanov wrote:
>>> On 05/28/2014 10:28 PM, Vasily Kulikov wrote:
>>>> On Wed, May 28, 2014 at 16:44 +0400, Pavel Emelyanov wrote:
>>>> It will be simplier
>>>> to parse the file -- if 'ns_ids' file contains some ID then this ID for
>>>> every ns can be obtained regardless of the specific ID name (SID, PID,
>>>> PGID, etc.).
>>>
>>> True, but given a task PID how to determine which pid namespaces it lives in
>>> to get the idea of how PIDs map to each other? Maybe we need some explicit
>>> API for converting (ID, NS1, NS2) into (ID)?
>>
>> AFAIU the idea of the patch is to add a new debugging information which
>> can be trivially obtained via 'cat /proc/...':
> 
> I agree, but this ability will be very useful by checkpoint-restore project
> too and I'd really appreciate if the API we have for that would be scalable
> enough. Per-task proc file works for me, but how about sid-s and pgid-s?

What kind of information does CRIU need?

Thanks,
//richard
