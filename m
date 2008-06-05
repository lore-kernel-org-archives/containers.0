From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] introduce task cgroup (#task restrictioon for prevent fork bomb by cgroup)
Date: Thu, 5 Jun 2008 19:53:50 +0900
Message-ID: <2f11576a0806050353y1c68c24co1584688eb348c690@mail.gmail.com>
References: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <48477DFB.5010906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756451AbYFEKyD@vger.kernel.org>
In-Reply-To: <48477DFB.5010906@cn.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

> You are not handling task migration between groups, i.e.:
>        # echo $$ > /cgroup/1/tasks
>        # echo $$ > /cgroup/2/tasks

Oh, nice point out.
Thanks!


> Maybe you need to add this in cgroup_init_subsys():
>
> -       need_forkexit_callback |= ss->fork || ss->exit;
> +       need_forkexit_callback |= ss->fork || ss->exit || ss->can_fork;
>
> and then we can do:
>
> if (need_forkexit_callback) {
>        for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {

good idea :)
I'll fix it at next post.
