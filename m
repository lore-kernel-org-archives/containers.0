From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/11] cgroup: use kzalloc() and list_del_init()
Date: Thu, 13 Jun 2013 11:13:23 +0800
Message-ID: <51B938D3.4000605@huawei.com>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
	<1371070996-20613-5-git-send-email-tj@kernel.org>
	<51B93038.9010202@huawei.com> <20130613023831.GB10979@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130613023831.GB10979@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/13 10:38, Kent Overstreet wrote:
> On Thu, Jun 13, 2013 at 10:36:40AM +0800, Li Zefan wrote:
>> On 2013/6/13 5:03, Tejun Heo wrote:
>>> There's no point in using kmalloc() and list_del() instead of the
>>> clearing variants for trivial stuff.  We can live dangerously
>>> elsewhere.  Use kzalloc() and list_del_init() instead and drop 0
>>> inits.
>>>
>>
>> Do you mean we prefer list_del_init() than list_del() in general? Then
>> in which cases do we prefer list_del()?
> 
> IMO, list_del() is preferred when the object shouldn't be reused (i.e.
> it gets taken off a list and then it's freed).

yeah, this is what I have in my mind. I would wonder why list_del_init()
if I know that object won't be used anymore.

> list_del_init() could
> hide bugs.
> 

Same here. I do worry a bit about this.
