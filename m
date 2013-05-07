From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [Suggestion] kernel/cgroup.c: about kfree after 'get_new_cssid'
Date: Tue, 7 May 2013 19:01:59 +0800
Message-ID: <5188DF27.4080000@huawei.com>
References: <5188DB93.2080504@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5188DB93.2080504-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/5/7 18:46, Chen Gang wrote:
> Hello Maintainers:
> 
> After call get_new_cssid(), I can not find the related free function
> (it seems free_css_id() is for that, but not used).
> 
> The memory location is:
>   get_new_cssid() --> kzalloc() for 'struct css_id'
>   get_new_cssid() --> idr_alloc() for 'ss->idr'
> 
> One work flow:
>   cgroup_load_subsys() --> cgroup_init_idr() --> get_new_cssid()
>   when get_new_cssid() fails, it will:
>   cgroup_load_subsys() --> cgroup_unload_subsys() --> idr_destroy(),
>   and also:
>   cgroup_load_subsys() --> cgroup_unload_subsys() --> ss->css_free();
>     ('css_free' may 'debug_css_free', or 'freezer_css_free' ...)
> 
> It seems the work flow above is not 'kfree' 'struct css_id', is it true?
> 
> BTW: I also guess, for cgroup_init_idr() in cgroup_init(), need check
> the return value.
> 
> Please help check.
> 

It's the specific cgroup subsystem that calls free_css_id() in it's subsys->css_free()
callback. See __mem_cgroup_free() for example.

There's a bug in cgroup_unload_subsys() that idr_destroy() should be called after
ss->css_free(). That said, given there's no modular cgroup subsystem using css_id,
and the whole css_id thing will be eliminated in 3.11, why bother fixing it.
