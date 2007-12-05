From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: namespace acceptance process. bad news
Date: Wed, 05 Dec 2007 04:52:30 -0700
Message-ID: <m13auhwe81.fsf@ebiederm.dsl.xmission.com>
References: <475680A2.2000907@sw.ru> <47568471.1060503@fr.ibm.com>
	<47568A09.7050305@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47568A09.7050305-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Wed, 05
	Dec 2007 14:22:49 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Kuznetsov <alexey-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Hello, All!
>>>
>>> We are completely bite to ground with the current Eric's patchset today
>>> by Dave Miller. flowi tagging considered wrong. The same opinion has
>>> been received from Alexey Kuznetsov :(
>>>
>>> So, it seems that we can't push this approach.
>> 
>> Argh !
>> 
>>>
>>> Daniel, Benjamin, should I merge your code to our git after this news or
>>> we should stop a bit and think? We have talked on OLS that if Dave stop
>>> us with current approach we could try global context as in OpenVz.
>> 
>> IMHO, doing netns switching has no sense now we are so far in the netns
>> implementation.
>> 
>>> I think I'll code this a bit and see a reaction, but we need to have
>>> some agreement here :)
>> 
>> I am more inclined to think about how to handle this problem before
>> doing anything.
>> 
>> Let's try to understand why flowi tagging is considered wrong first.
>> 
>> Alexey seems to disagree with this approach, is it possible to elaborate
>> a little bit ?
>> 
>>
> Here is a quote from Miller:
>
> | I'm not applying this, it's going to have a negative impact on routing
> | performance.
> |
> | It also changes the semantics of the flowi object in a way I very
> | much dislike, in that there is now non-clobberable state in there.
> |
> | Previously only addressing identifying objects were present in the
> | flow, you could use it any context, and there were no pointer
> | dereferencing or object references from this thing.  It was very
> | simple.
> |
> | That is no longer the case after your patch and I don't want us
> | to go down this path.
> |
> | Please find another way to implement this.
>
> flowi marking is a way to deliver the namespace into the routing code,
> as far as I can understand the implementation.

Ok.  Sounds like a reasonable technical objection that we need to look at,
and it is pretty significant.  I need to look at this and sleep on it
before I can address this.

Eric
