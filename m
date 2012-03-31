From: Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] cgroup: make css->refcnt clearing on cgroup removal
	optional
Date: Sun, 1 Apr 2012 06:28:56 +0900
Message-ID: <CABEgKgpxidNfK4_A_TNPZvM8Dbm35QxGEGYbRH+roTU2zM7vNw__17922.2626532011$1333229349$gmane$org@mail.gmail.com>
References: <20120330223423.GJ28934@google.com>
	<20120330223606.GK28934@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120330223606.GK28934-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012年3月31日7:36 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> Currently, cgroup removal tries to drain all css references.  If there
> are active css references, the removal logic waits and retries
> ->pre_detroy() until either all refs drop to zero or removal is
> cancelled.
>
> This semantics is unusual and adds non-trivial complexity to cgroup
> core and IMHO is fundamentally misguided in that it couples internal
> implementation details (references to internal data structure) with
> externally visible operation (rmdir).  To userland, this is a behavior
> peculiarity which is unnecessary and difficult to expect (css refs is
> otherwise invisible from userland), and, to policy implementations,
> this is an unnecessary restriction (e.g. blkcg wants to hold css refs
> for caching purposes but can't as that becomes visible as rmdir hang).
>
> Unfortunately, memcg currently depends on ->pre_destroy() retrials and
> cgroup removal vetoing and can't be immmediately switched to the new
> behavior.  This patch introduces the new behavior of not waiting for
> css refs to drain and maintains the old behavior for subsystems which
> have __DEPRECATED_clear_css_refs set.
>
> Once, memcg is updated, we can drop the code paths for the old
> behavior as proposed in the following patch.  Note that the following
> patch is incorrect in that dput work item is in cgroup and may lose
> some of dputs when multiples css's are released back-to-back, and
> __css_put() triggers check_for_release() when refcnt reaches 0 instead
> of 1; however, it shows what part can be removed.
>
>  http://thread.gmane.org/gmane.linux.kernel.containers/22559/focus=75251
>
> Note that, in not-too-distant future, cgroup core will start emitting
> warning messages for subsys which require the old behavior, so please
> get moving.
>
Ok, I'll update memcg ASAP (after LSF/MM).
I'm now thinking to move all resources to root if use_hierarchy=0.

Thanks,
-Kame
