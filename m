From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: Does Linux-CR+LXC support FUSE
Date: Sun, 10 Apr 2011 12:18:42 -0400
Message-ID: <4DA1D862.3010505@cs.columbia.edu>
References: <AANLkTim-bB7c7=sb+g7sC7+MM-Z6uHLYFfFJf=c7Cd2a@mail.gmail.com>
	<20110311182941.GA11570@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110311182941.GA11570-BtbdaCaBcfOTUehee3IRJA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Jon Zhu <jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 03/11/2011 01:29 PM, Serge E. Hallyn wrote:
> Quoting Jon Zhu (jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> Hi,
>>
>> Just wondering if Linux-CR+LXC support FUSE or not, FUSE(
>> http://fuse.sourceforge.net/) is a pupular file system development platform
>> which is being widely used by lots of distributed file systems.
>>
>> Can anyone shed some light on this?
> 
> No.  But there's nothing stopping it.  Each of the fuse filesystems
> would have to define a fops->checkpoint() method.

In fact, I suspect for many if not most of the FUSE filesystems, the
all-purpose "generic_file_checkpoint()" would be sufficient. 

The only problem with doing that by default, is that it break silently
when used with those few that need more; i.e. checkpoint will work but
restart may not succeed later.

Oren.
