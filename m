From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] introduce task cgroup (#task restrictioon for prevent fork bomb by cgroup)
Date: Thu, 5 Jun 2008 19:56:32 +0900
Message-ID: <2f11576a0806050356ua1d86fo3a46863d21f195f5@mail.gmail.com>
References: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080605142320.cdc8b21a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756558AbYFEK4n@vger.kernel.org>
In-Reply-To: <20080605142320.cdc8b21a.nishimura@mxp.nes.nec.co.jp>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

Hi Nishimura-san,

Thanks good point out.

>> +#include <linux/res_counter.h>
> I don't think it's needed.
> Or, are you planning to implement this feature by using res_counter?

your are right.
my early version use res_counter, but it isn't used currently.


>> +     spin_lock(&taskcg->lock);
>> +     if (max_tasks < taskcg->nr_tasks)
>> +             return -EBUSY;
> need spin_unlock().

Yes, of cource.
I'll fix it.

Thanks!
