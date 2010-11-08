From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/7] cgroups: Allow to bind a subsystem to a cgroup
	hierarchy
Date: Mon, 08 Nov 2010 13:26:13 +0800
Message-ID: <4CD789F5.4000208__2185.87346976182$1289193940$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146D4.7030009@cn.fujitsu.com>
	<AANLkTimCD90s+y_6y=LyOL1QqEOOAaT+b2b4guDrzo_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimCD90s+y_6y=LyOL1QqEOOAaT+b2b4guDrzo_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Fri, Oct 22, 2010 at 1:09 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> +       /*
>> +        * Indicate if this subsystem can be bound/unbound to/from a cgroup
>> +        * hierarchy which has child cgroups.
>> +        */
>> +       unsigned int can_bind:1;
> 
> Maybe call this "bindable"?
> 
> Basic idea looks great, it could do with a bunch more comments, and
> maybe locking rules.
> 
> Is there any chance of a lock inversion between dir->i_mutex and
> cgroup_lock in hierarchy_popuiate_dir() ?
> 

The lock order is:

mutex_lock(&dir->i_mutex)
  mutex_lock(&cgroup_mutex)
    mutex_lock(&dir->i_mutex, I_MUTEX_CHILD)

it should be safe.
