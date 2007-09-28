From: "Denis V. Lunev" <dlunev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [NETNS45] network namespace locking rules
Date: Fri, 28 Sep 2007 21:02:53 +0400
Message-ID: <46FD33BD.9070305@gmail.com>
References: <20070928143654.GA14129@iris.sw.ru>
	<m1d4w2d92m.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1d4w2d92m.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>> Current locking for network namespace list/initialization is broken.
>> for_each_net is called under single rtnl_lock in
>> register_netdevice_notifier.
> 
> As of  984e617a3e1974022b8f671427a76ffbe886f75b this issue has
> been addressed in net-2.6.24
> 
> The only remaining part to address is rtnl_unlock().
> 
> My current hypothesis is that rtnl_unlock() only needs to process
> the packets that are queued while we had the rtnl_lock held,
> to maintain the current semantics.
> 
> So the retry may not be necessary as it may be possible to prove
> that the only extra packets that could come in come from another
> thread taking the rtnl_lock and they will those packets in their
> rtnl_unlock() if we don't.
> 
> I will review this later today, and add the retry if necessary.
> 
> One way or another I think we agree on how to get the locking correct.
> The other details are a bit tricky but look usable.
> 
> Eric
> 

Unfortunately, the answer is 'no'. data_ready callback takes rtnl
inside, so we can have new packets from other namespaces during the
processing.

No way, but restart :(

Regards,
	Den
