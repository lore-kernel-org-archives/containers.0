From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [-mm PATCH 5/10] Memory controller task migration (v7)
Date: Mon, 27 Aug 2007 17:26:35 +0900 (JST)
Message-ID: <20070827082635.195471BFA2C@siro.lan>
References: <20070824152043.16582.37727.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753454AbXH0I0s@vger.kernel.org>
In-Reply-To: Your message of "Fri, 24 Aug 2007 20:50:43 +0530"
	<20070824152043.16582.37727.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

> Allow tasks to migrate from one container to the other. We migrate
> mm_struct's mem_container only when the thread group id migrates.

> +	/*
> +	 * Only thread group leaders are allowed to migrate, the mm_struct is
> +	 * in effect owned by the leader
> +	 */
> +	if (p->tgid != p->pid)
> +		goto out;

does it mean that you can't move a process between containers
once its thread group leader exited?

YAMAMOTO Takashi
