From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: Convert synchronize_rcu to call_rcu in
	cgroup_attach_task
Date: Wed, 24 Nov 2010 10:58:23 -0800
Message-ID: <AANLkTikhE-z7HuLimuj_pJLKd7FHq+w6PQCd85XuT0a8__15160.7181680903$1290625177$gmane$org@mail.gmail.com>
References: <AANLkTikx6d0_VFtZ4zWQucRCf=vFt7N2M6=0jpnKasEE@mail.gmail.com>
	<1290398767-15230-1-git-send-email-ccross@android.com>
	<AANLkTi=4-OgPUugnUBaqSU3oC=3wxTjAsOB_Ais3Or+i@mail.gmail.com>
	<4CEC7329.7070909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CEC7329.7070909-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 23, 2010 at 6:06 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> If we do this, it's not anymore safe to use get_css_set(), which just
> increments the refcount without checking if it's zero.

I don't believe that it's currently safe to use get_css_set() on a
zero-refcount css_set anyway - a css_set starts with refcount 1 and
can be freed the moment that its refcount reaches 0. You can only use
get_css_set() on a stable reference to an existing css_set, which by
definition has a refcount of at least 1. Were you thinking of any
particular existing uses?

Paul
