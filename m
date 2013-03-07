From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 7 Mar 2013 10:04:17 -0800
Message-ID: <20130307180417.GV3268@linux.vnet.ibm.com>
References: <611667212.10748821.1362649031475.JavaMail.root@redhat.com>
	<513860E8.4080807@huawei.com> <876213wmwt.fsf@xmission.com>
	<5138D001.8000409@oracle.com>
	<1362678371.15793.218.camel@edumazet-glaptop>
	<5138D377.6040406@oracle.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5138D377.6040406-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 07, 2013 at 12:50:47PM -0500, Sasha Levin wrote:
> On 03/07/2013 12:46 PM, Eric Dumazet wrote:
> > On Thu, 2013-03-07 at 12:36 -0500, Sasha Levin wrote:
> > 
> >> Looks like the hlist change is probably the issue, though it specifically
> >> uses:
> >>
> >> 	#define hlist_entry_safe(ptr, type, member) \
> >>         	(ptr) ? hlist_entry(ptr, type, member) : NULL
> >>
> >> I'm still looking at the code in question and it's assembly, but I can't
> >> figure out what's going wrong. I was also trying to see what's so special
> >> about this loop in find_pid_ns as opposed to the rest of the kernel code
> >> that uses hlist_for_each_entry_rcu() but couldn't find out why.
> >>
> >> Is it somehow possible that if we rcu_dereference_raw() the same thing twice
> >> inside the same rcu_read_lock() section we'll get different results? That's
> >> really the only reason for this crash that comes to mind at the moment, very
> >> unlikely - but that's all I have right now.
> > 
> > Yep
> > 
> > #define hlist_entry_safe(ptr, type, member) \
> > 	(ptr) ? hlist_entry(ptr, type, member) : NULL
> > 
> > Is not safe, as ptr can be evaluated twice, and thats not good at all...
> 
> ptr is being evaluated twice, but in this case this is an
> rcu_dereference_raw() value within the same rcu_read_lock() section.
> 
> Is it still problematic?

Sigh!  Eric is right -- if "ptr" involves side effects, evaluating
it twice is completely broken.

							Thanx, Paul
