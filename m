From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] cgroup: Fixes the un-paired cgroup lock problem
Date: Wed, 04 Nov 2009 13:11:10 +0800
Message-ID: <4AF10CEE.5020807@cn.fujitsu.com>
References: <b741c2440911031740m52f8c11dt6e57b549cc6ce465@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750865AbZKDFME@vger.kernel.org>
In-Reply-To: <b741c2440911031740m52f8c11dt6e57b549cc6ce465@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Liu Aleaxander <aleaxander@gmail.com>
Cc: Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Liu Aleaxander wrote:
> From: Liu Aleaxander <Aleaxander@gmail.com>
> Date: Wed, 4 Nov 2009 09:27:06 +0800
> Subject: [PATCH] Fixes the un-paired cgroup lock problem
> 
> In cgroup_lock_live_group, it locks the cgroup by mutex_lock, while in the
> cgroup_tasks_write, it unlock it by cgroup_unlock. Even though they are
> equal, but I do think we should make it pair.
> 
> BTW, should we replace others with cgroup_lock and cgroup_unlock?
> Since we already have a wrapper one and it's meaningful.
> 

Before I read the email body, I thought there is a bug where
there is a lock without unlock or vise versa.

I agree the case here can be called "unpaired", but I'm not
convinced this patch is needed. The code is not buggy or
confusing. So the patch neither fixes a bug nor make the code
more readable.
