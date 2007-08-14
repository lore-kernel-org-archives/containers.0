From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/20] Introduce struct upid
Date: Tue, 14 Aug 2007 13:05:58 -0700
Message-ID: <20070814130558.4b5e5e3f.akpm@linux-foundation.org>
References: <46BC506F.mailGJ711PNHE@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935427AbXHNULn@vger.kernel.org>
In-Reply-To: <46BC506F.mailGJ711PNHE@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: xemul@openvz.org
Cc: devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, oleg@tv-sign.ru, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On Fri, 10 Aug 2007 15:47:59 +0400
xemul@openvz.org wrote:

>  struct pid
>  {
>  	atomic_t count;
> @@ -50,6 +50,8 @@ struct pid
>  	/* lists of tasks that use this pid */
>  	struct hlist_head tasks[PIDTYPE_MAX];
>  	struct rcu_head rcu;
> +	int level;
> +	struct upid numbers[1];

You can make this have size [0] now.  It's a gcc extension and
is used elsewhere in the kernel.
