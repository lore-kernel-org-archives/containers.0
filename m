From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: why this behavior in 3.16 kernel ?
Date: Wed, 03 Aug 2016 12:48:49 -0500
Message-ID: <877fbxhhfi.fsf@x220.int.ebiederm.org>
References: <CAJ5w2CmDcXzOKppojwN2F5H-mFu_OM-XUoTWnTuLKrdoPG9iQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJ5w2CmDcXzOKppojwN2F5H-mFu_OM-XUoTWnTuLKrdoPG9iQg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(cool linux's message of "Wed, 3 Aug 2016 16:38:25 +0530")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cool linux <linux.cool.hot-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cool linux <linux.cool.hot-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hi,
>
> I have executed below script on 3.16 kernel and it took to finish almost
> 1.30sec to 2 minutes, where as in my older kernel(3.2.30) it took only 3
> secs.
>
> ================================================
> date
>
> for (( i=1; i <= 2000; i++ ))
> do
>  ip netns exec gmk ip link show > /dev/null
> done
>
> date
> ================================================
>
> Please guide me why this behavior in 3.16 kernel ?

Good question.  What happens on a modern kernel? 4.7 is the most recent
release, 3.16 was released two years ago.  My hunch is that you just
started using systemd and it has changed the defaults with all of the
mounts.  But shrug.  I don't recall how all of those relevant kernel
pieces operated two years ago.

Eric
