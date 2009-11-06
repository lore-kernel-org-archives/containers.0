From: Bill Davidsen <davidsen-sQDSfeB7uhw@public.gmane.org>
Subject: Re: [PATCH] cgroup: Fixes the un-paired cgroup lock problem
Date: Thu, 05 Nov 2009 19:14:11 -0500
Message-ID: <4AF36A53.3080005@tmr.com>
References: <b741c2440911031740m52f8c11dt6e57b549cc6ce465@mail.gmail.com>
	<4AF10CEE.5020807@cn.fujitsu.com> <4AF18F06.50807@tmr.com>
	<4AF28695.7070806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AF28695.7070806-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Bill Davidsen wrote:
>   
>> Li Zefan wrote:
>>     
>>> Liu Aleaxander wrote:
>>>       
>>>> From: Liu Aleaxander <Aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>> Date: Wed, 4 Nov 2009 09:27:06 +0800
>>>> Subject: [PATCH] Fixes the un-paired cgroup lock problem
>>>>
>>>> In cgroup_lock_live_group, it locks the cgroup by mutex_lock, while
>>>> in the
>>>> cgroup_tasks_write, it unlock it by cgroup_unlock. Even though they are
>>>> equal, but I do think we should make it pair.
>>>>
>>>> BTW, should we replace others with cgroup_lock and cgroup_unlock?
>>>> Since we already have a wrapper one and it's meaningful.
>>>>
>>>>         
>>> Before I read the email body, I thought there is a bug where
>>> there is a lock without unlock or vise versa.
>>>
>>> I agree the case here can be called "unpaired", but I'm not
>>> convinced this patch is needed. The code is not buggy or
>>> confusing. So the patch neither fixes a bug nor make the code
>>> more readable.
>>>
>>>       
>> I would say it fixes a bug, the one that would be introduced when the
>> two methods are no longer compatible and essentially two names for the
>> same thing. And while you may know the code so well that you knew
>> without looking that this was (currently) okay, there will be lots of
>> eyes on this code over the years, I think most people would find use of
>> cgroup_lock to lock the cgroup a LOT more readable.
>>
>> While you can't go back in time to murder your grandfather, it creates
>> no paradox to fix a bug before someone writes it.
>>
>>     
>
> cgroup_lock() is not necessarily more readable than mutex_lock(&cgroup_mutex),
> at least the former doesn't tell you the lock is a spin_lock or a mutex.
>
>   
That's the point, cgroup_lock() is an abstraction, you want to lock the 
cgroup, you call the macro, the macro handles the details, and if 
thinking (or the most common cache configurations) change, the code 
still works.

> In fact, Ingo showed his distaste towards cgroup_lock():
> 	http://lkml.org/lkml/2009/1/18/39
>
> And I won't worry about the issue you mentioned above. If It does
> happen, the one, who makes the 2 mehtods no long compatible, will
> definitely find out all the places where cgroup_mutex is used and
> make proper change.
>
>   


-- 
Bill Davidsen <davidsen-sQDSfeB7uhw@public.gmane.org>
  Unintended results are the well-earned reward for incompetence.
