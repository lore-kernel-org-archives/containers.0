From: "Mukesh G" <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Write Error: No space left on device
Date: Mon, 15 Sep 2008 17:25:32 +0530
Message-ID: <c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080905080008.bf9748ab.pj-sJ/iWh9BUns@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Paul,
     How do I determine the no of memory nodes in shared systems (E.g: x86
based systems)? How do you define a memory node in the context of the shared
systems?

I figured that I need to increase the memory nodes but unable to do so...

Thanks

Mukesh


On Fri, Sep 5, 2008 at 6:30 PM, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:

> Mukesh wrote:
> > "Write Error: No space left on device".
>
> Search for
>
>     ENOSPC
>
> on the (brand new) cpuset(7) man page, such as at:
>
>     ftp://oss.sgi.com/projects/cpusets/download/cpuset.7
>
> --
>                  I won't rest till it's the best ...
>                  Programmer, Linux Scalability
>                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
>
