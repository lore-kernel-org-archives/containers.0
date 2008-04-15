From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4] Object creation with a specified id
Date: Tue, 15 Apr 2008 14:52:33 -0400
Message-ID: <4804F971.3020207@cs.columbia.edu>
References: <20080404145129.637145000@bull.net>
	<20080415030623.GA8171@tull.net> <480483C2.3030509@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <480483C2.3030509-6ktuUTfB/bM@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nick Andrew <nick-dnCCA748QAperShJXdIFYw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Nadia Derbey wrote:
> Nick Andrew wrote:
>> On Fri, Apr 04, 2008 at 04:51:29PM +0200, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
>>
>>>   . echo "LONG XX" > /proc/self/next_id
>>>     next object to be created will have an id set to XX
>>>   . echo "LONG<n> X0 ... X<n-1>" > /proc/self/next_id
>>>     next object to be created will have its ids set to XX0, ... X<n-1>
>>>     This is particularly useful for processes that may have several 
>>> ids if
>>>     they belong to nested namespaces.
>>
>>
>> How do you handle race conditions, i.e. you specify the ID for the
>> next object to be created, and then some other thread goes and creates
>> an object before your thread creates one?
>>
>> Nick.
> 
> 
> Sorry for not answering earlier, I just saw your e-mail!

[I too managed to miss that message].

> 
> It's true that the way I've done things, the "create_with_id" doesn't 
> take into account multi-threaded apps, since "self" is related to the 
> thread group leader.
> 
> May be using something like /proc/self/task/<my_tid>/next_id would be 
> better, but I have to think more about it...

That /proc/self links to /proc/TGID slipped my mind. Definitely must
be done on a per-thread basis (and /proc/<TGID>/task/<PID>/next_id
will do the trick).

Oren.

> 
> Regards,
> Nadia
