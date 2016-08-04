From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: why this behavior in 3.16 kernel ?
Date: Thu, 04 Aug 2016 09:15:29 -0500
Message-ID: <87h9b062ny.fsf@x220.int.ebiederm.org>
References: <CAJ5w2CmDcXzOKppojwN2F5H-mFu_OM-XUoTWnTuLKrdoPG9iQg@mail.gmail.com>
	<877fbxhhfi.fsf@x220.int.ebiederm.org>
	<20160804011401.GA20044@gmail.com> <20160804062150.GB14503@gmail.com>
	<CAJ5w2C=u_sNP4-ZHm1HH=stU-8ngbPDFuY7JimWqYPesPajkMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJ5w2C=u_sNP4-ZHm1HH=stU-8ngbPDFuY7JimWqYPesPajkMg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(cool linux's message of "Thu, 4 Aug 2016 12:49:36 +0530")
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

> Hi Eric/Andrew,
>
> Thanks for your response.
>
> I have commented out the synchronize_rcu() in namespace_unlock() which is
> located in /fs/namespace.c namespace_unlock() 
>
> now am able to see the result in fraction of seconds.

Interesting.   So it is just the fact you are serializing things in the
loop that makes things slow.

I would recommend syncrhonize_rcu_expidited but in this case since we
aren't holding a lock this is a case that looks like it will only show
up when testing (because things are needlessly serialized) and not in
the real world.

Eric
