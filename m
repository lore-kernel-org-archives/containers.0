From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: namespace acceptance process. bad news
Date: Wed, 05 Dec 2007 13:31:00 +0100
Message-ID: <47569A04.7080908@bull.net>
References: <475680A2.2000907@sw.ru> <47568471.1060503@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47568471.1060503-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Kuznetsov <alexey-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
>> Hello, All!
>>
>> We are completely bite to ground with the current Eric's patchset today
>> by Dave Miller. flowi tagging considered wrong. The same opinion has
>> been received from Alexey Kuznetsov :(
>>
>> So, it seems that we can't push this approach.
> 
> Argh !

Re-Argh... 

>> Daniel, Benjamin, should I merge your code to our git after this news or
>> we should stop a bit and think? 

Um, on a pratical point of view, I think it could be good to merge the 
IPv6 patchset in your git, (if there aren't too much conflicts and if it 
doesn't take too long), to store it somewhere and be able to use it as 
a reference.

I also tend to think that we should think a bit more about the issue 
raised by Dave and try to find an alternative solution (if needed)
before dropping the current model for handling netns.

Benjamin

>> We have talked on OLS that if Dave stop
>> us with current approach we could try global context as in OpenVz.
> 
> IMHO, doing netns switching has no sense now we are so far in the netns
> implementation.
> 
>> I think I'll code this a bit and see a reaction, but we need to have
>> some agreement here :)
> 
> I am more inclined to think about how to handle this problem before
> doing anything.
> 
> Let's try to understand why flowi tagging is considered wrong first.
> 
> Alexey seems to disagree with this approach, is it possible to elaborate
> a little bit ?
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

   http://www.bull.com
