From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Fri, 02 Oct 2009 17:22:16 -0400
Message-ID: <4AC66F08.6050405@librato.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
	<20091002093050.GA4189@count0.beaverton.ibm.com>
	<4AC644C8.2070905@librato.com>
	<20091002202726.GC4189@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091002202726.GC4189-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:

[...]

>>>> s/ckpt_obj_collect/ckpt_collect_file/
>>> OK. Seems like we might recurse here though if the file is an epoll
>>> file and there's a cycle in the epoll sets (e.g. epoll set A includes the fd
>>> for epoll set B, epoll set B includes the fd for epoll set A).
>>> So I think I'll do:
>> I doubt if an epoll file can epoll an epoll file ...
>> (eg. see line 1265 in fs/eventpoll.c)
> 
> I am certain it can. The testcase I have proves it and the man page mentions
> it too. Since it has a poll op I believe it can be epoll'd (line 691 of
> fs/eventpoll.c).
> 
> I haven't double checked, but I believe the line you cited just prevents the
> epoll set from including its own fd.

Duh ... you are totally correct. Sorry for the noise.

[...]

>>> Otherwise I wonder if it would be better to join the prefmt and fmt
>>> strings by just defining our own, new, conversion specifiers.
>>>
>> Thought about it, but that would limit us in the conversion specifiers
>> that we can use, because many are used by printf already. Perhaps one
>> way to do it is use
>> 	"%Zxyz"
>> where "%Z" tells the following letters indicate a ckpt_write_err()
>> format, and then "xyz" are the letters from the current @prefmt.
> 
> Would %( work better? The ( suggests that there's more to it.

Sounds cool. Care to work out the details with a patch ?

Oren.
