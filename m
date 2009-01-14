From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Net containers config and usage
Date: Wed, 14 Jan 2009 20:53:58 +0100
Message-ID: <496E42D6.2080306@free.fr>
References: <496C4EB0.30203@free.fr> <20090113142925.GA11767@us.ibm.com>
	<20090113191837.GA29900@versecorp.net> <496CF11A.7090908@free.fr>
	<20090113214747.GA23742@versecorp.net>
	<1231887220.6398.73.camel@groeck-laptop> <496DA755.1040001@free.fr>
	<20090114172739.GA13581@versecorp.net>
	<496E23DA.9080402@free.fr> <20090114192633.GA8572@us.ibm.com>
	<20090114193944.GA14129@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090114193944.GA14129-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
> On Wed, Jan 14, 2009 at 01:26:34PM -0600, Serge E. Hallyn wrote:
>   
>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>>     
>>> chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
>>>       
>>>> On Wed, Jan 14, 2009 at 09:50:29AM +0100, Daniel Lezcano wrote:
>>>>   
>>>>         
>>>>> Guenter Roeck wrote:
>>>>>     
>>>>>           
>>>>>> As far as I recall, if you have sysfs active and use the sysfs patch to
>>>>>> let you configure both sysfs and network namespaces, you can only move
>>>>>> virtual interfaces into a network namespace.
>>>>>>
>>>>>> Guenter
>>>>>>  
>>>>>>       
>>>>>>             
>>>>> Ah ! yes, you are right :)
>>>>>
>>>>> The current upstream implementation allowing sysfs and netns to coexist 
>>>>> together has one restriction, the physical network devices can not be 
>>>>> moved if sysfs is enabled in the kernel. This is why Chris can not move 
>>>>> the physical network device with this version of the kernel.
>>>>> This restriction will be set until the sysfs per namespace is fully 
>>>>> supported.
>>>>>
>>>>> This restriction does not exist with with the previous kernel version 
>>>>> with the sysfs per namespace patchset.
>>>>>
>>>>> -- Daniel
>>>>>
>>>>>     
>>>>>           
>>>> Ah, great, thanks to all for your help on this.
>>>> Do you have any rough estimate when the support for sysfs per namespace will
>>>>   
>>>>         
>>> The sysfs per namespace has been rejected because of some design 
>>> problems related with the sysfs itself.
>>> Perhaps Eric can tell more about that...
>>>       
>> Chris, in the meantime, is using the physical device an absolute
>> necessity, or could you work around it for now using a veth tunnel?
>>
>> Even if Eric has been working on the sysfs locking rework quietly
>> the last few months, i'd expect several months of back-and-forth
>> trying to prove that the rework is correct...
>>
>> -serge
>>     
>
> Yes, ultimately we'll need the physical device inside the same namespace
> as our application.  Our application does a lot of management on the interface,
> monitoring things like the interface's link-pulse and such, and that wouldn't
> be available through a virtual interface.  We can always redesign things
> to have the management portion run in the namespace with the physical interface,
> but for performance reasons we'd eventually want the physical interface to be
> directly inside the namespace anyway - so that would probably be wasted effort.
>   
Did you tried with the macvlan ?
