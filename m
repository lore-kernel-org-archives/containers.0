From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 07 Mar 2013 10:18:44 -0800
Message-ID: <1362680324.15793.219.camel@edumazet-glaptop>
References: <611667212.10748821.1362649031475.JavaMail.root@redhat.com>
	<513860E8.4080807@huawei.com> <876213wmwt.fsf@xmission.com>
	<5138D001.8000409@oracle.com>
	<1362678371.15793.218.camel@edumazet-glaptop>
	<5138D377.6040406@oracle.com> <87boavrspd.fsf@xmission.com>
	<5138D8F2.5020900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5138D8F2.5020900-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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
Cc: CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2013-03-07 at 13:14 -0500, Sasha Levin wrote:

> Okay, I'm even more confused now.
> 
> The expression in question is:
> 
> 	hlist_entry_safe(rcu_dereference_bh(hlist_first_rcu(head)))
> 
> You're saying that "rcu_dereference_bh(hlist_first_rcu(head))" can change between
> the two evaluations we do. That would mean that 'head' has changed in between, right?
> 
> In that case, the list itself has changed - which means that RCU has changed the
> list underneath us.
> 
> hlist_first_rcu() doesn't have any side-effects, it doesn't modify the list whatsoever,
> so the only thing that can change is 'head'. Why is it allowed to change if the list
> is protected by RCU?

Thats the point of RCU ;)

Things can change under us.
