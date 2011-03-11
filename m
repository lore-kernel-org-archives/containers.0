From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Does Linux-CR+LXC support FUSE
Date: Fri, 11 Mar 2011 12:29:41 -0600
Message-ID: <20110311182941.GA11570@peq.hallyn.com>
References: <AANLkTim-bB7c7=sb+g7sC7+MM-Z6uHLYFfFJf=c7Cd2a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim-bB7c7=sb+g7sC7+MM-Z6uHLYFfFJf=c7Cd2a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jon Zhu <jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jon Zhu (jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hi,
> 
> Just wondering if Linux-CR+LXC support FUSE or not, FUSE(
> http://fuse.sourceforge.net/) is a pupular file system development platform
> which is being widely used by lots of distributed file systems.
> 
> Can anyone shed some light on this?

No.  But there's nothing stopping it.  Each of the fuse filesystems
would have to define a fops->checkpoint() method.

-serge
