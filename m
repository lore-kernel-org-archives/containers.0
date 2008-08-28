From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Thu, 28 Aug 2008 20:09:38 +0800
Message-ID: <48B69582.4000208__28828.5936964259$1219925695$gmane$org@cn.fujitsu.com>
References: <48B360CE.2010501@cn.fujitsu.com>	
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>	
	<48B39319.7070403@cn.fujitsu.com>	
	<6599ad830808261544w308a850m865ac0c0a1552c77@mail.gmail.com>	
	<48B4D81D.2040200@cn.fujitsu.com>
	<6599ad830808270536i353e1807kaac4e9fb74301bb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830808270536i353e1807kaac4e9fb74301bb0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Aug 26, 2008 at 9:29 PM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> And vmalloc can malloc larger memory than kmalloc, is vmalloc() enough?
>> If not, I think using an array of pages is the best choice.
> 
> vmalloc would be simpler, certainly, but it has a higher overhead. And
> since we're dealing with arrays of integers here, it's not too hard to
> manage multiple arrays. Oh, except for sorting them, which would be
> more of a pain. So yes, maybe vmalloc() would be a better choice at
> first.
> 
Yep, these are hard. Which method is your favorite?

My original purpose was to fix a bug as I described. 
This bug and the problem that offering big enough array for a huge
cgroup are orthogonal!

Could you consider/test that is it a bug as I described(and is it as
critical as I described, maybe I was too nervous)?
And this is also a problem: opening a cgroup.tasks twice or will waste
a lot of _physical_ memory.

    Thanks! Lai
