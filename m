From: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Fri, 25 Jan 2008 03:13:35 +0300
Message-ID: <479929AF.8070301@openvz.org>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>
	<47990BAB.4050106@openvz.org>
	<20080124225002.GC13819@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080124225002.GC13819-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Kir Kolyshkin (kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>   
>> Serge E. Hallyn wrote:
>>     
>>> Hi,
>>>
>>> here is a list of topics which I believe people are interested in
>>> writing papers on.  I'm listing names of those who I think are
>>> interested in writing them.  Sorry if I leave anyone off of a topic
>>> they're interested in.  However it seems to me it would be best if we
>>> can agree on one person or two people to drive each topic, so everyone
>>> doesn't sit around expecting someone else to submit the abstract.
>>>
>>> Am I missing any?
>>>
>>> mini-summit:
>>> 	I will submit for a 1-day mini-summit.  Some interesting
>>> 	remaining topics for the mini-summit would include device
>>> 	namespaces, ttys and syslog, and lots of checkpoint/restart.
>>>   
>>>       
>> That's right, obviously the title of the mini-summit would be something
>> like "Linux Kernel Containers".
>>     
>
> Attached is what I currently had for a proposal to send to the OLS
> committee.  (Please feel free to edit and add to the wiki)
>   

Looks really good from the first glance.

I put it to wiki as
http://wiki.openvz.org/Containers/Mini-summit_2008/Proposal and hope we
will take a closer look tomorrow (as it's 3am here now:)).

> I just took guesses at moderator names because the OLS CFP asks for
> them.  If someone else (Kir? Cedric?) wants to moderate the namespaces
> part that's fine with me.
>
>   
>>> 	Does anyone think we don't need one of these at ols?  Or that
>>> 	we do?
>>>
>>> 	Is anyone interested in organizing the summit - coming out
>>> 	with an agenda, sending out announcements, etc - either
>>> 	alone or with my help?
>>>   
>>>       
>> Guess I can help a bit with organizing this. To that effort, I have put
>> up a wiki page:
>> http://wiki.openvz.org/Containers/Mini-summit_2008
>>     
>
> Cool, thanks.
>
>   
>> We also need to have some kind of a list of attendees. So far I came
>> with 12 names listed on that page, please feel free to edit/add more.
>>     
>>> pidns: (Pavel and Suka)
>>> 	I've heard it called a tutorial, though I think some of the
>>> 	technical details are interesting in and of themselves.  Its
>>> 	also an important area to make sure other developers - i.e
>>> 	people working with flocks or kthreads - understand.
>>>   
>>>       
>> This is the proposal Pavel filed today, it is editable so we can improve
>> it, please send your suggestion/fixes.
>>
>>     
>>> PID namespaces in the Linux kernel
>>>
>>> PID namespaces is a relatively new Linux kernel feature merged in
>>>       
>
> Hmm...  "PID namespaces are a relatively new Linux kernel feature"
> sounds more normal.  Though I'm not sure which is more "correct"
>   
Thanks! Fixed.
>   
>>> 2.6.24 kernel. It is a "view" of a particular set of tasks on the
>>> system. PID namespaces work in a similar way to filesystem namespaces:
>>> a process can be accessed in multiple namespaces, but it may have a
>>> different name in each. It is one of the building blocks for
>>> containers virtualization, and a prerequisite for
>>> checkpointing/restart and live migration.
>>>
>>> The paper outlines some implementation details, explains user space
>>> constraints that may seem odd, and discusses the impact of the feature
>>> on the kernel APIs.
>>>
>>> In collaboration with Sukadev Bhattiprolu, IBM.
>>>       
>
> Looks good to me.
>   

Great, thanks!

>   
>>     
>>> 	netns: denis driving, daniel, benjamin
>>>   
>>>       
>> Right, Den Lunev, Daniel Lezcano, Pavel Emelyanov and Benjamin Thery.
>> Den already filed a proposal for a paper/talk, here is how it looks
>> like. Again, it is editable, so send your improvements.
>>
>>     
>>> Network namespace for Linux
>>>
>>> The paper outlines the effort to implement a network virtualization in
>>> the Linux kernel. This is a part of on-going effort to bring the
>>> containers functionality into Linux. A container is an isolated
>>> user-space partition, which performs like a stand-alone server, with
>>> multiple containers co-existing on a single Linux box. Containers can
>>> be used for resource management, network security and in
>>> high-performance computing.
>>>
>>> Making several instances of the Linux network stack, based on the
>>> namespace concept, is a big challenge, but it is required to build a
>>> full featured container. We will show how to configure and use a new
>>> instance of the network stack, how the feature is architectured and
>>> implemented, and what is the current state of the art.
>>>
>>> In collaboration with Daniel Lezcano, IBM, Benjamin Thery, Bull, and
>>> Pavel Emelyanov, OpenVZ.
>>>       
>>>>     
>>>>         
>>> namespaces status: Pavel and Cedric
>>> 	There was no ns status update last year it may be of
>>> 	interest.  Instead of a separate pidns paper, pidns could
>>> 	also be mentioned here.
>>>   
>>>       
>> What if we organise a BoF, outlining the current status and future
>> directions. Something like "Linux Kernel Containers development status"
>> or some better title. I'd say "Containers" here instead of "Namespaces"
>> (or use "Containers/Namespaces") because containers is easier term from
>> my PoV.
>>     
>
> That has a different effect.  A BoF would also be good, but if there are
> parts about the direction with namespaces about which we want some
> guidance from the community (which I think there are - sysfs, namespace
> entering, checkpoint/restart in general) then we may get more people at
> a paper talk than a bof.  A Bof will basically get people particularly
> interested in either using or developing the feature.
>   

Makes sense indeed.

My primary concern about talk vs. BoF was/is -- do we have enough
quality material/content to write a "minimum of 6 pages and a maximum of
15 pages (properly formatted)" paper which is required for a talk (but
not for a BoF). Well, a lot has happened since last year, maybe enough
for a paper.

>   
>>> namespace entering: Cedric and serge?
>>> 	This *probably* isn't enough for a full paper.  So it could
>>> 	go under namespace status paper.  But there is quite a bit
>>> 	to say just by listing the existing proposed solutions (at
>>> 	least 4 I can think of offhand) and their shortcomings.
>>>
>>> memory c/r: Dave Hansen, serge interested
>>> 	I suspect many people on this list have their own ideas on
>>> 	how to go about the checkpoint and restart.  I suppose they
>>> 	could each write their own paper, or work together on a single
>>> 	combined paper laying out the possibilities
>>>   
>>>       
>> Actually we already followed that way -- Andrey Mirkin has filed a
>> paper/talk proposal today, titled "Containers checkpointing and live
>> migration". Guess Dave (and/or Oren Laadan, and/or Cedric, maybe
>> somebody else as well) could come with their own talks/papers as well.
>>
>> Still can't make up my mind if we need a BoF on the subject or not.
>>     
>
> I figure at least a third of the mini-summit will be c/r.  Separate
> papers may actually be the way to go, so long as each paper presents a
> different approach.  OLS could put them all together in one block.  Then
> at a BoF or a beer bof, after all have been presented and everyone has
> heard all the arguments, we can discuss the way to go forward.
>   

Sounds like a plan, especially the beer part ;)
>   
>>> user namespace approaches: serge
>>>
>>> cgroups and containers: Paul Menage driving?, Balbir?
>>> 	A cgroups update could either be its own paper or joined
>>> 	with the namespaces status paper.
>>> 	
>>> 	Paul were you considering a separate paper to discuss
>>> 	the cgroups and namespace management as laid out in
>>> 	your Sep 03 2007 email "Thoughts on Namespace / Subsystem
>>> 	unification"?
>>>   
>>>       
>> Not too much stuff about resource management, i.e. user memory
>> controller, kernel memory controller, other per-namespace limits etc. Or
>> is it all covered by cgroups? Or it's not what we are currently targeting?
>>     
>
> I was figuring that each of those cgroups wouldn't have enough material
> for a paper and yes i figured one cgroup paper would be about the
> various cgroups.  But I'm pretty far out of touch with that work so
> coudl be completely off base.  The 'ns/cgroup
> unification'/administration topic is the one that interests me the most
> out of that block :)
>
> thanks,
> -serge
>   
