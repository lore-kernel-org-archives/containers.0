From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Naming the "Task containers" framework
Date: Tue, 11 Sep 2007 17:04:42 +0200
Message-ID: <46E6AE8A.7080405@fr.ibm.com>
References: <6599ad830709042254t2d5c4f54y964c74e3c6d9a6ab@mail.gmail.com>
	<20070911135739.GA15217@sergelap.austin.ibm.com>
	<6599ad830709110738n5e754e91qa549e13e2d7a27b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830709110738n5e754e91qa549e13e2d7a27b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On 9/11/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>> Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
>>> At the mini-summit, and at other times, I've heard the repeated
>>> complaint that having the word "container" in the name of the "task
>>> container" framework leads to ambiguity. And separately from the
>>> complaints, I've seen the awkwardness that people end up with when
>>> they feel they have to distinguish between the "containers" abstract
>>> concept, and "Paul's containers" ...
>>>
>>> With the hope/prospect of having the framework merged some time after
>>> the kernel summit, I guess now's a good time to bow to the pressure
>>> and find some compromise that everyone likes, before we actually hit
>>> mainline. (Maybe earlier would have been even better, but ...)
>>>
>>> Of the various possible names that have been suggested, there are a
>>> couple that (to me) stand out as good options:
>>>
>>> - control groups
>>> - task sets
>>>
>>> The former (coined by Eric during a brainstorming session yesterday)
>>> seems to capture the enforcement aspect of the framework (sysadmin can
>>> use it to control the behaviour of processes, processes can't escape
>>> from groups), without suggesting that it can only be used for resource
>>> controllers (as some alternative names such as "resource groups"
>>> imply) and would be a choice that I could be happy with.
>>>
>>> Does anyone have strong views on other alternative names (or even the
>>> idea of keeping "task containers")?
>> Purely subjectively I prefer control groups, but task sets is more
>> descriptive about the implementation.
> 
> I described it as "control groups" during the kernel summit
> presentation and no-one seemed to object to that name.
> 
> As far as I can tell, the general mood seems to be in favour of
> "control groups" - no-one else has expressed a preference for "task
> sets".
>
> I think it's more important to express the overall intention of the
> feature rather than the implementation. Ted T'so (I think) asked at
> the summit whether things other than tasks could be first-class
> members of control groups - I said that currently they can't, but
> people may find interesting ways to conveniently make non-task objects
> first-class members in the future (rather than just holding reference
> counts the way pages do currently).
> 
>> So I'd have to vote for task sets.
>>
>> I like 'task containers', but it really is a pain trying to keep clear
>> which containers I'm talking about from one sentence to the next.
> 
> Right, enough people have said this to me now, and I've seen the
> awkwardness that it entails - I don't want to add a subsystem to the
> kernel that's forever referred to as "Paul's containers" :-)

That's how I've been calling them for a while :)

Now that LWN has announced the name rebrand in the article : 

	http://lwn.net/Articles/249080/

I hope we can close the topic.

C.
