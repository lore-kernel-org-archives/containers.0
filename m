From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] introduce task cgroup (#task restrictioon for prevent fork bomb by cgroup)
Date: Thu, 5 Jun 2008 19:51:35 +0900
Message-ID: <2f11576a0806050351o60dc1351q35f74d4e9836e20d@mail.gmail.com>
References: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080605092745.GA3734@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756313AbYFEKvp@vger.kernel.org>
In-Reply-To: <20080605092745.GA3734@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

Hi

Thank you for careful review.

>> +     struct task_cgroup *taskcg;
>> +
>> +     if ((max_tasks > INT_MAX) ||
>> +         (max_tasks < INT_MIN))
>
> It should be < -1 I think.

OK.
I'll fix it at next post.



>> +     spin_lock(&taskcg->lock);
>> +     if (max_tasks < taskcg->nr_tasks)
>> +             return -EBUSY;
>
> Shouldn't you drop the lock here?

you are right.
Thanks.


> How does this controller affect performance? Do you have some numbers?

No.
but I have plan to mesure it at nearly future.
Thanks.
