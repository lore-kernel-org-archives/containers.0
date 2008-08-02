From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: Per-instance devpts
Date: Sat, 02 Aug 2008 08:33:59 -0700
Message-ID: <48947E67.9060005@zytor.com>
References: <20080412172933.GA19295@us.ibm.com>	
	<1208027215.28187.17.camel@x61.ebiederm.org>	
	<48935205.3090807@zytor.com>	
	<f73f7ab80808020004j15b0d0e5x5fa911242641b34d@mail.gmail.com>
	<f73f7ab80808020006i7f0ac456ve9b9f73568c11294@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f73f7ab80808020006i7f0ac456ve9b9f73568c11294-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kyle Moffett <kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Kyle Moffett wrote:
> 
> Here's my suggestion:
> 
> By default, without any mount options, use the current "legacy"
> behavior.  The devpts filesystem would point to a "global" instance on
> the whole box, controlled by the traditional /dev/ptmx device node.
> There would *NOT* be a /dev/pts/ptmx node.
> 
> If the devpts filesystem is mounted with a special option ("permount"?
> "noglobal"?), then it will create a new devpts instance associated
> with the filesystem.  A devpts mounted that way *WILL* have a magic
> /dev/pts/ptmx node.
> 
> If the kernel is built with CONFIG_DEVPTS_FORCE_PERMOUNT then the
> traditional /dev/ptmx device node will be neutered (IE: always return
> -ENODEV) and the "permount" option will be forced for all devpts
> mounts.  This will also remove the static global devpts instance.
> 

Hm.  This might work if we can get the mount behaviour to work right. 
I'll think about it.  It definitely seems like a reasonable way to get 
from A to B.

	-hpa
