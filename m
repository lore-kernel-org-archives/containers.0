From: william <william-FuVYq0B8HF8swF9hGuCkNA@public.gmane.org>
Subject: Re: cgroups and limit firefox processes cpu time
Date: Fri, 22 Jan 2010 14:06:30 +0100
Message-ID: <4B59A2D6.5000004@cobradevil.org>
References: <4B5938EB.3040809@cobradevil.org>	
	<4B5988DC.8020100@linux.vnet.ibm.com>	
	<4B598D0D.9080206@cobradevil.org>	
	<4B598DB2.2030709@linux.vnet.ibm.com>
	<8aa016e11001220400j5bc568e6vb9d087f4310203aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8aa016e11001220400j5bc568e6vb9d087f4310203aa-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, V Srivatsa <vsrivatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Bharata B Rao <bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Libcg Development list <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Dhaval Giani wrote:
> On Fri, Jan 22, 2010 at 12:36 PM, Balbir Singh
> <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>   
>> On Friday 22 January 2010 05:03 PM, william wrote:
>>     
>>> Balbir Singh wrote:
>>>       
>>>> On Friday 22 January 2010 11:04 AM, william wrote:
>>>>
>>>>         
>>>>> Hello list
>>>>>
>>>>> I have a question about how i can limit the cpu for a firefox process on
>>>>> a terminal server.
>>>>>
>>>>> We have 150 firefox processes running on a terminalserver but there are
>>>>> always people who take more cpu when they use flash or java.
>>>>> Some firefox processes take sometimes about 50 percent cpu time.
>>>>> Is there a way to give all firefox processes equal cpu shares so that
>>>>> other people who are using firefox for research have no issues (slow
>>>>> responding scrolling and menu)  because there are a few firefox
>>>>> processes eating all the cpu time?
>>>>>
>>>>>           
>>>> Are these running on behalf of different users? You can always create a
>>>> good hiearchy and organize. FAIR_USER scheduler option is going away
>>>> soon. Some more context on the firefox applications and whose behalf
>>>> they are running on, etc would help.
>>>>
>>>>
>>>>
>>>>         
>>> The terminal server only hosts firefox processes for different users
>>> (user is only allowed to login once) to provide internet access in a
>>> secure way.
>>>
>>> So i have 150 firefox processes for different users. So i cannot set one
>>> group, I have to put all those processes in a separate container if i
>>> get it right?
>>>       
>> If the kernel is compiled with fair users then you are set, but that
>> option might go away soon.
>>     
>
> I have already posted a patch to remove it, and it will go away in the
> next release of the kernel
>
>   
>> Yes, putthing them all in their own cgroup is
>> the best option. This can be done easily using libcgroup tools.
>>
>>     
>
> Right, libcgroup already has the ability to sort on the basis of
> username and process name. You should be able to use that. Though it
> might be impractical at the moment since you will need to list all the
> usernames/groups in a configuration file.
>   
So then i would have to create a config file with 65k users in it :(

Would it be possible to setup a specific application in libcgroup, so 
that the libcgroup will create a container for that firefox process?

say something like:
#applicationgroup firefox {
#    perm {
#        task {
#            application = /usr/bin/firefox;
#            gid = users;
#        }
#    }
#    cpu {
#        cpu.shares = 10;
#    }
#}

so every firefox process started should get the same cpu cycles.
And if i understood it correctly a process can take as much cpu cycles 
as he want till the hard limit , if another process requests more cycles 
and has not reached his soft limit then the process which is already 
over the softlimit will be cut back?


> Thanks,
> Dhaval
>   

Thank you for helping.

With kind regards
William
