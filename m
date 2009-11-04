From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH] cgroup: Fixes the un-paired cgroup lock problem
Date: Wed, 04 Nov 2009 09:26:14 -0500
Message-ID: <4AF18F06.50807@tmr.com>
References: <b741c2440911031740m52f8c11dt6e57b549cc6ce465@mail.gmail.com> <4AF10CEE.5020807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756546AbZKDO05@vger.kernel.org>
In-Reply-To: <4AF10CEE.5020807@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Liu Aleaxander <aleaxander@gmail.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Liu Aleaxander wrote:
>> From: Liu Aleaxander <Aleaxander@gmail.com>
>> Date: Wed, 4 Nov 2009 09:27:06 +0800
>> Subject: [PATCH] Fixes the un-paired cgroup lock problem
>>
>> In cgroup_lock_live_group, it locks the cgroup by mutex_lock, while in the
>> cgroup_tasks_write, it unlock it by cgroup_unlock. Even though they are
>> equal, but I do think we should make it pair.
>>
>> BTW, should we replace others with cgroup_lock and cgroup_unlock?
>> Since we already have a wrapper one and it's meaningful.
>>
> 
> Before I read the email body, I thought there is a bug where
> there is a lock without unlock or vise versa.
> 
> I agree the case here can be called "unpaired", but I'm not
> convinced this patch is needed. The code is not buggy or
> confusing. So the patch neither fixes a bug nor make the code
> more readable.
> 
I would say it fixes a bug, the one that would be introduced when the two 
methods are no longer compatible and essentially two names for the same thing. 
And while you may know the code so well that you knew without looking that this 
was (currently) okay, there will be lots of eyes on this code over the years, I 
think most people would find use of cgroup_lock to lock the cgroup a LOT more 
readable.

While you can't go back in time to murder your grandfather, it creates no 
paradox to fix a bug before someone writes it.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
