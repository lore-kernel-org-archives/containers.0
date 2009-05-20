From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Thu, 21 May 2009 08:58:57 +0900
Message-ID: <20090521085857.d4b82cba.kamezawa.hiroyu@jp.fujitsu.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<4A13ABC8.2000907@cn.fujitsu.com>
	<d95d44a20905200335v6aabfc28qa3958e8404965775@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20905200335v6aabfc28qa3958e8404965775-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 20 May 2009 18:35:34 +0800
anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Thank you for answering.
> 
> >> # bash
> >> # echo $$
> >> 2253
> >>
> >
> I have checked again the experiment.
> And, the "2253" is typos, should be
> "2252" as the one written as follows.
> 
> I have retried the experiment and same
> result is given.
> 
> Any comment?  Does the limitation of
> physical memory not support in 2.6.29.3?
> Or, something missing maybe?
> 
> 
I wonder....

max_usage_in_bytes is not _reseted_ when you specified limit.
Then, please set limit before attaching task.

Sane sequence is.
1. mount
2. mkdir
3. set limit
4. attach.


Thanks,
-Kame
