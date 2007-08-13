From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: containers mini-summit?
Date: Mon, 13 Aug 2007 12:59:44 +0400
Message-ID: <46C01D80.9020007@openvz.org>
References: <20070808174757.GB5559@vino.hallyn.com> <46BAD052.6040900@sw.ru>
	<20070809193109.GA1935@sergelap.austin.ibm.com>
	<46BC1EF6.4010706@openvz.org>
	<20070810131831.GA22740@vino.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070810131831.GA22740-4+H9nbzk0uAIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Paul H. Hargrove" <PHHargrove-/3juihCSby0@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, cpw-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>> Serge E. Hallyn wrote:
>>> Quoting Pavel Emelyanov (xemul-3ImXcnM4P+0@public.gmane.org):
>>>> Serge E. Hallyn wrote:
>>>>> I just sent the next (final) version of the containers development
>>>>> roadmap.  Eric Biederman and Paul Menage will be at kernel summit
>>>>> representing this work.
>>>>>
>>>>> We had planned on having a containers mini-summit the day before the
>>>>> kernel summit.  However interest in that appears as though it may be
>>>>> too low to justify having a real mini-summit.
>>>>>
>>>>> So we have a few options:
>>>>>
>>>>> 	1. we could have a mini-summit purely by phone.
>>>>> 	2. there is a possibility of using a part of a
>>>>> 	   conference room from LCE, if attendance will
>>>>> 	   be low.  However, having a phone line to include
>>>>> 	   those who cannot attend would be unlikely.
>>>>> 	3. if there is a large planned attendance, we could
>>>>> 	   continue to seek a separate venue for the
>>>>> 	   mini-summit.
>>>>>
>>>>> Who is interested in (a) attending the mini-summit in person, (b)
>>>>> attending the mini-summit by phone, or (c) not interested?
>>>> I will be there in person.
>>> Still waiting to hear whether anyone other than yourself, Eric, and Paul
>>> would be there...  If not, I assume you could meet in one of your hotel
>>> rooms and dial into the phone meeting?  :)
>> Well, actually, I'd prefer meeting in person even if there will be
> 
> That's what I meant - if there are <6 people, meet in person in
> someone's hotel room, and then you've got a phone right there so
> everyone else can dial in.
> 
>> only 4 people. Talking tete-a-tete is always better than phone-a-phone :)
>>
>> Except for to meet in some cafe/park in case not many people come.
>>
>>>>> For those interested in attending, what would you expect to happen at
>>>>> the mini-summit?  a) discuss the roadmap to ensure everyone is
>>>>> properly represented at the summit  b) go over pieces of functionality
>>>> >from the roadmap and discuss implementation options, who is
>>>>> interested in working on what, and possible timelines.  c) something
>>>>> else.
>>>> I think it would be good if someone makes a short presentation of
>>>> what is already done and what is being developed now so that we all
>>>> can have an overall picture in sight.
>>> Hmm, so in front of the current 'roadmap' you'd like to see a list of
>>> what's been accomplished so far?
>> Not exactly. The entire picture. E.g. I have no idea of what is going on
>> with network namespaces and checkpoint/restart. I'd also like to know what
>> people think about the kernel memory resource management that was discussed
>> long ago and some more questions.
> 
> We could certainly come up with a set of 'status updates' if people
> would like that.  I.e.
> 
> 	pidns updates - Pavel/suka
> 	netns updates - Eric/Daniel/Benjamin
> 	task containers - Paul
> 	memory container - Balbir
> 	memory checkpoint - Dave

Thanks. I will prepare some presentation. BTW, maybe we can organize
some kind of containers BoF on the conference itself to make other
people come and listen. Maybe this will attract more developers to the
virtualization? In this case the presentation may be more descriptive.

> 	what do vserver/openvz want to see upstream next - Herbert/Kirill
> etc
> 
> Also if people are interested we could try to do something like that
> every 1 or 2 months, presumably by phone most of the time, though we
> could try to always sync it with some conference or other and see
> whether a few people can meet in person just for fun.
> 
>>> I suppose that might be a good way of showing the community that this is
>>> all work in progress and going along nicely, not brand-new development.
>>> Pavel, do you mind writing that up?
>> I do not :) I do not even mind making a presentation and showing it up in
>> the mini-summit, but as I have told I haven't got a complete picture of
>> what's happening. Actually I admitted that everyone has some gaps in
>> their knowledges about the overall situation and thought that the person,
>> responsible for this presentation would spend some time collecting the
>> information from other people :)
>>
>>> Eric, do you mind at the mini-summit (or mini-summit phone call) going
>>> over what you were going to present at the kernel summit?
>>>
>>> thanks,
>>> -serge
> 
