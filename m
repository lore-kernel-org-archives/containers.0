From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [PATCH 01/10] Task Containers(V11): Basic task container
 framework
Date: Fri, 27 Jul 2007 14:31:19 +0900 (JST)
Message-ID: <20070727053120.2EFAC1BF6B8@siro.lan>
References: <20070720191247.388947000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933805AbXG0Fbd@vger.kernel.org>
In-Reply-To: Your message of "Fri, 20 Jul 2007 11:31:53 -0700"
	<20070720191247.388947000@menage.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: menage@google.com
Cc: akpm@linux-foundation.org, dev@sw.ru, xemul@sw.ru, serue@us.ibm.com, vatsa@in.ibm.com, ebiederm@xmission.com, haveblue@us.ibm.com, svaidy@linux.vnet.ibm.com, balbir@in.ibm.com, pj@sgi.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, rohitseth@google.com
List-Id: containers.vger.kernel.org

> +Other fields in the container_subsys object include:

> +- hierarchy: an index indicating which hierarchy, if any, this
> +  subsystem is currently attached to. If this is -1, then the
> +  subsystem is not attached to any hierarchy, and all tasks should be
> +  considered to be members of the subsystem's top_container. It should
> +  be initialized to -1.

stale info?

> +struct container {

> +	struct containerfs_root *root;
> +	struct container *top_container;
> +};

can cont->top_container be different from than &cont->root.top_container?

YAMAMOTO Takashi
