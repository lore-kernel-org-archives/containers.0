From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 11:22:53 +0100
Message-ID: <20090123102253.GF15188@elte.hu>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760815AbZAWKXz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090123004703.25103.29754.stgit@menage.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org


* Paul Menage <menage@google.com> wrote:

> cgroup: Fix root_count when mount fails due to busy subsystem
> 
> root_count was being incremented in cgroup_get_sb() after all error 
> checking was complete, but decremented in cgroup_kill_sb(), which can be 
> called on a superblock that we gave up on due to an error.  This patch 
> changes cgroup_kill_sb() to only decrement root_count if the root was 
> previously linked into the list of roots.
> 
> Signed-off-by: Paul Menage <menage@google.com>
> 
> ---
> 
> I was actually surprised to find that list_del() doesn't crash when
> run on an unattached list_head structure.
> 
>  kernel/cgroup.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index adcd0bb..9ce27e8 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1115,8 +1115,10 @@ static void cgroup_kill_sb(struct super_block *sb) {
>  	}
>  	write_unlock(&css_set_lock);
>  
> -	list_del(&root->root_list);
> -	root_count--;
> +	if (!list_empty(&root->root_list)) {
> +		list_del(&root->root_list);
> +		root_count--;
> +	}

That's ugly. It is _much_ cleaner to always keep the link head consistent 
- i.e. initialize it with INIT_LIST_HEAD() and then remove from it via 
list_del_init().

That way the error path will do the right thing automatically, and there's 
no need for that ugly "if !list_empty" construct either.

	Ingo
